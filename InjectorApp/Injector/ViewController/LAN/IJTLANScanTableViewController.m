//
//  IJTLANScanTableViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/9/3.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTLANScanTableViewController.h"
#import "IJTLANDetailTableViewController.h"
#import "IJTLANOnlineTableViewCell.h"
#import "IJTLANTaskTableViewCell.h"

#define TIMEOUT 1000
struct bits {
    uint16_t	b_mask;
    char	b_val;
} lan_bits[] = {
    { IJTLANStatusFlagsMyself,	'M' },
    { IJTLANStatusFlagsGateway,	'G' },
    { IJTLANStatusFlagsArping,	'A' },
    { IJTLANStatusFlagsDNS,     'D' },
    { IJTLANStatusFlagsMDNS,	'N' },
    { IJTLANStatusFlagsNetbios,	'B' },
    { IJTLANStatusFlagsPing,	'P' },
    { IJTLANStatusFlagsSSDP,	'S' },
    { IJTLANStatusFlagsLLMNR,   'L'  },
    { 0 }
};

@interface IJTLANScanTableViewController ()

@property (nonatomic) BOOL scanning;
@property (nonatomic) BOOL cancle;
@property (nonatomic) BOOL arpScanning;

@property (nonatomic, strong) ASProgressPopUpView *progressView;
@property (nonatomic, strong) NSTimer *updateProgressViewTimer;

@property (nonatomic, strong) IJTArp_scan *arpScan;
@property (nonatomic, strong) NSThread *scanThread;
@property (nonatomic, strong) NSThread *mdnsThread;
@property (nonatomic, strong) NSThread *netbiosThread;
@property (nonatomic, strong) NSThread *pingThread;
@property (nonatomic, strong) NSThread *ssdpThread;
@property (nonatomic, strong) NSThread *dnsThread;
@property (nonatomic, strong) NSThread *llmnrThread;
@property (nonatomic, strong) NSThread *arpReadThread;

@property (nonatomic, strong) NSString *gatewayAddress;
@property (nonatomic, strong) NSString *currentAddress;

@property (nonatomic, strong) NSMutableDictionary *taskInfoDict;
@property (atomic, strong) NSMutableArray *onlineArray;
@property (nonatomic, strong) NSThread *postThread;

@end

@implementation IJTLANScanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self size
    self.tableView.estimatedRowHeight = 84;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.title = @"LAN";
    
    self.dismissButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"left.png"]
                          style:UIBarButtonItemStylePlain
                          target:self action:@selector(dismissVC)];
    
    self.navigationItem.leftBarButtonItem = self.dismissButton;
    
    [self.stopButton setTarget:self];
    [self.stopButton setAction:@selector(stopScan)];
    
    self.taskInfoDict = [[NSMutableDictionary alloc] init];
    [self.taskInfoDict setValue:[NSString stringWithFormat:@"%@ - %@", _startIp, _endIp] forKey:@"Range"];
    [self.taskInfoDict setValue:_bssid forKey:@"BSSID"];
    [self.taskInfoDict setValue:_ssid forKey:@"SSID"];
    
    [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
        if(self.startScan) {
            [self scan];
        }
        else {
            self.onlineArray = [[NSMutableArray alloc] init];
            NSMutableArray *insertArray = [[NSMutableArray alloc] init];
            for(NSInteger i = 0 ; i < _historyArray.count; i++) {
                NSDictionary *dict = _historyArray[i];
                [self.onlineArray addObject:dict];
                [insertArray addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVC {
    if(_arpScan != nil) {
        [_arpScan close];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)stopScan {
    if(_scanThread != nil || _mdnsThread != nil || _netbiosThread != nil ||
       _pingThread != nil || _ssdpThread != nil || _dnsThread != nil ||
       _llmnrThread != nil ||
       _updateProgressViewTimer != nil ) {
        [self.stopButton setEnabled:NO];
        self.cancle = YES;
        [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
            if(![_scanThread isFinished]) {
                while(_scanThread) {
                    usleep(100);
                }
            }
            if(![_mdnsThread isFinished]) {
                while(_mdnsThread) {
                    usleep(100);
                }
            }
            if(![_netbiosThread isFinished]) {
                while(_netbiosThread) {
                    usleep(100);
                }
            }
            if(![_pingThread isFinished]) {
                while(_pingThread) {
                    usleep(100);
                }
            }
            if(![_ssdpThread isFinished]) {
                while(_ssdpThread) {
                    usleep(100);
                }
            }
            if(![_llmnrThread isFinished]) {
                while(_llmnrThread) {
                    usleep(100);
                }
            }
            if(self.updateProgressViewTimer) {
                [self.updateProgressViewTimer invalidate];
                self.updateProgressViewTimer = nil;
            }
            [self.stopButton setEnabled:YES];
        }];
    }
}

- (void)postToDatabaseStore: (id)object {
    NSDate *date = object;
    NSString *json = [IJTJson array2string:_onlineArray];
    json = [IJTHTTP string2post:json];
    NSString *result =
    [IJTHTTP retrieveFrom:@"ReceiveLANScanHistory.php"
                     post:[NSString stringWithFormat:@"SerialNumber=%@&StartIpAddress=%@&EndIpAddress=%@&BSSID=%@&SSID=%@&Date=%ld&Data=%@", [IJTID serialNumber], _startIp, _endIp, _bssid, [IJTHTTP string2post:_ssid], (time_t)[date timeIntervalSince1970], json]
                  timeout:5];
    if([result integerValue] != IJTStatusServerSuccess) {
        [self showErrorMessage:@"Fail to store to online database."];
    }
    self.postThread = nil;
}

#pragma mark arp scan
- (void)scan {
    if(_arpScan == nil) {
        _arpScan = [[IJTArp_scan alloc] initWithInterface:@"en0"];
        if(_arpScan.errorHappened) {
            [self showErrorMessage:[NSString stringWithFormat:@"%s.", strerror(_arpScan.errorCode)]];
            return;
        }
    }//end if
    
    self.scanning = YES;
    self.cancle = NO;
    
    self.currentAddress = [IJTNetowrkStatus currentIPAddress:@"en0"];
    [_arpScan setLAN];
    if(_arpScan.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"ARP-scan : %s.", strerror(_arpScan.errorCode)]];
        return;
    }
    
    self.onlineArray = [[NSMutableArray alloc] init];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.stopButton, nil];
    [self.dismissButton setEnabled:NO];
    [self.tableView setUserInteractionEnabled:NO];
    
    //add progress view
    
    self.progressView = [IJTProgressView baseProgressPopUpView];
    self.progressView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:
                                      CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_progressView.frame))];
    [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self.tableView.tableHeaderView addSubview:self.progressView];
    
    //read inject and read
    [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(60, 0, 0, 0);
        self.scanThread = [[NSThread alloc] initWithTarget:self selector:@selector(scanLANThread) object:nil];
        [self.scanThread start];
        self.updateProgressViewTimer =
        [NSTimer scheduledTimerWithTimeInterval:0.05
                                         target:self
                                       selector:@selector(updateProgressView:)
                                       userInfo:nil repeats:YES];
    }];
    
}

- (void)scanLANThread {
    IJTRoutetable *route = [[IJTRoutetable alloc] init];
    if(route.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"%s.", strerror(route.errorCode)]];
        self.cancle = YES;
    }
    [route getGatewayByDestinationIpAddress:@"0.0.0.0"
                                     target:self
                                   selector:ROUTETABLE_SHOW_CALLBACK_SEL
                                     object:nil];
    [route close];
    
    //add my self
    if(_currentAddress) {
        NSString *macAddress = [IJTNetowrkStatus wifiMacAddress];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:_currentAddress forKey:@"IpAddress"];
        [dict setValue:macAddress forKey:@"MacAddress"];
        [dict setValue:@(IJTLANStatusFlagsMyself | IJTLANStatusFlagsArping) forKey:@"Flags"];
        [dict setValue:[ALHardware deviceName] forKey:@"Self"];
        [self.onlineArray addObject:dict];
        [IJTDispatch dispatch_main:^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_onlineArray.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
    }//end if
    
    self.arpScanning = YES;
    self.arpReadThread = [[NSThread alloc] initWithTarget:self selector:@selector(arpReadTimeout) object:_onlineArray];
    [self.arpReadThread start];
    
    while([_arpScan getRemainInjectCount] != 0) {
        if(self.cancle)
            break;
        [_arpScan injectWithInterval:1000];
        
        if(_arpScan.errorHappened) {
            if(_arpScan.errorCode == ENOBUFS) {
                sleep(1);
            }
            else {
                [self showErrorMessage:[NSString stringWithFormat:@"ARP-scan : %s.", strerror(_arpScan.errorCode)]];
                break;
            }
        }
    }//end while arp scan
    self.arpScanning = NO;
    while(self.arpReadThread != nil)
        usleep(100);
    
    [_arpScan close];
    
    //sort
    for(int i = 0 ; i < _onlineArray.count ; i++) {
        for(int j = 0 ; j < i ; j++) {
            NSMutableDictionary *dict1 = _onlineArray[i];
            NSMutableDictionary *dict2 = _onlineArray[j];
            NSString *ipAddress1 = [dict1 valueForKey:@"IpAddress"];
            NSString *ipAddress2 = [dict2 valueForKey:@"IpAddress"];
            in_addr_t addr1, addr2;
            inet_pton(AF_INET, [ipAddress1 UTF8String], &addr1);
            inet_pton(AF_INET, [ipAddress2 UTF8String], &addr2);
            addr1 = ntohl(addr1);
            addr2 = ntohl(addr2);
            if(addr1 < addr2) {
                [_onlineArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }//end swap
        }//end for
    }//end for
    [IJTDispatch dispatch_main:^{
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
    
    //mdns
    self.mdnsThread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(mdnsInjectAndReadThread:)
                                                object:_onlineArray];
    [self.mdnsThread start];
    
    //netbios
    self.netbiosThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(netbiosInjectAndReadThread:)
                                                   object:_onlineArray];
    [self.netbiosThread start];
    
    self.pingThread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(pingInjectAndReadThread:)
                                                object:_onlineArray];
    [self.pingThread start];
    
    self.ssdpThread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(ssdpInjectAndReadThread:)
                                                object:_onlineArray];
    [self.ssdpThread start];
    
    self.dnsThread = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(dnsInjectAndReadThread:)
                                               object:_onlineArray];
    [self.dnsThread start];
    
    self.llmnrThread = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(llmnrInjectAndReadThread:)
                                               object:_onlineArray];
    [self.llmnrThread start];
    
    while(_mdnsThread != nil || _netbiosThread != nil ||
          _pingThread != nil || _ssdpThread != nil ||
          _dnsThread != nil || _llmnrThread != nil)
        usleep(100);
    
DONE:
    self.scanning = NO;
    [self.updateProgressViewTimer invalidate];
    self.updateProgressViewTimer = nil;
    
    [IJTDispatch dispatch_main:^{
        [self.stopButton setEnabled:NO];self.scanning = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if(self.onlineArray.count > 0) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSString *path = nil;
            if(geteuid()) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                path = [NSString stringWithFormat:@"%@/%@", basePath, @"LANHistory"];
            }
            else {
                path = @"/var/root/Injector/LANHistory";
            }
            NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
            if(array == nil) {
                array = [[NSMutableArray alloc] init];
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:_startIp forKey:@"StartIP"];
            [dict setValue:_endIp forKey:@"EndIP"];
            [dict setValue:_bssid forKey:@"BSSID"];
            [dict setValue:_ssid forKey:@"SSID"];
            [dict setValue:date forKey:@"Date"];
            [dict setValue:_onlineArray forKey:@"Data"];
            [array addObject:dict];
            [array writeToFile:path atomically:YES];
            
            [self.delegate callback];
            self.postThread = [[NSThread alloc] initWithTarget:self selector:@selector(postToDatabaseStore:) object:date];
            [self.postThread start];
        }
        
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.dismissButton setEnabled:YES];
        [self.stopButton setEnabled:YES];
        [self.tableView setUserInteractionEnabled:YES];
        self.navigationItem.rightBarButtonItems = nil;
        [self.progressView setProgress:1.0 animated:YES];
        [self.progressView removeFromSuperview];
        
        [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }];
    }];
    self.scanThread = nil;
}

- (void)arpReadTimeout {
    while(_arpScanning) {
        //read who reply
        [_arpScan readTimeout:TIMEOUT
                       target:self
                     selector:ARPSCAN_CALLBACK_SEL
                       object:_onlineArray];
    }
    self.arpReadThread = nil;
}

ARPSCAN_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        NSMutableArray *list = [(NSMutableArray *)object copy];
        
        //dont dup
        for(int i = 0 ; i < [list count] ; i++) {
            NSDictionary *dict = [list objectAtIndex:i];
            if([[dict valueForKey:@"IpAddress"] isEqualToString:ipAddress])
                return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:ipAddress forKey:@"IpAddress"];
        [dict setValue:macAddress forKey:@"MacAddress"];
        if([ipAddress isEqualToString:_gatewayAddress]) {
            [dict setValue:@(IJTLANStatusFlagsGateway | IJTLANStatusFlagsArping) forKey:@"Flags"];
        }
        else if([ipAddress isEqualToString:_currentAddress]) {
            ;//skip my self
        }
        else {
            [dict setValue:@(IJTLANStatusFlagsArping) forKey:@"Flags"];
        }
        
        [_onlineArray addObject:dict];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:list.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}

ROUTETABLE_SHOW_CALLBACK_METHOD {
    if(![interface isEqualToString:@"en0"])
        return;
    
    if(type == IJTRoutetableTypeInet4 && [destinationIpAddress isEqualToString:@"0.0.0.0"]) {
        self.gatewayAddress = [NSString stringWithString:gateway];
    }
}

#pragma mark llmnr scan
- (void)llmnrInjectAndReadThread: (id)object {
    NSArray *list = object;
    
    IJTLLMNR *llmnr = [[IJTLLMNR alloc] init];
    if(llmnr.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"LLMNR : %s.", strerror(llmnr.errorCode)]];
        self.mdnsThread = nil;
        return;
    }
    
    [llmnr setReadUntilTimeout:YES];
    
    for(NSDictionary *dict in [list copy] ) {
        if(self.cancle)
            break;
        NSString *ipAddress = [dict valueForKey:@"IpAddress"];
        
        [llmnr setOneTarget:ipAddress];
        [llmnr injectWithInterval:100];
        if(llmnr.errorHappened) {
            [self showErrorMessage:[NSString stringWithFormat:@"LLMNR : %s.", strerror(llmnr.errorCode)]];
            if(llmnr.errorCode == ENOBUFS) {
                sleep(1);
            }
            else
                break;
        }
    }
    
    [llmnr readTimeout:TIMEOUT
                target:self
              selector:LLMNR_PTR_CALLBACK_SEL
                object:_onlineArray];
    [llmnr close];
    self.llmnrThread = nil;
}

LLMNR_PTR_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        [self setValue:resolveHostname forKey:@"LLMNRName" ipAddress:ipAddress flags:IJTLANStatusFlagsLLMNR withObject:object];
    }];
}

#pragma mark dns
- (void)dnsInjectAndReadThread: (id)object {
    NSArray *list = object;
    NSMutableArray *dnsServer = [[NSMutableArray alloc] init];
    [IJTDNS getDNSListRegisterTarget:self selector:DNS_LIST_CALLBACK_SEL object:dnsServer];
    if(dnsServer.count <= 0) {
        self.dnsThread = nil;
        return;
    }
    IJTDNS *dns = [[IJTDNS alloc] init];
    if(dns.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"DNS : %s.", strerror(dns.errorCode)]];
        self.dnsThread = nil;
        return;
    }
    [dns setReadUntilTimeout:YES];
    
    NSString *server = [dnsServer firstObject];
    for(NSDictionary *dict in [list copy] ) {
        if(self.cancle)
            break;
        
        NSString *ipAddress = [dict valueForKey:@"IpAddress"];
        
        [dns injectWithInterval:100 server:server ipAddress:ipAddress];
    }
    [dns readTimeout:TIMEOUT target:self selector:DNS_PTR_CALLBACK_SEL object:_onlineArray];
    [dns close];
    self.dnsThread = nil;
}

DNS_PTR_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        [self setValue:resolveHostname forKey:@"DNSName" ipAddress:ipAddress flags:IJTLANStatusFlagsDNS withObject:object];
    }];
}

DNS_LIST_CALLBACK_METHOD {
    NSMutableArray *list = (NSMutableArray *)object;
    [list addObject:ipAddress];
}

#pragma mark ssdp scan
- (void)ssdpInjectAndReadThread: (id)object {
    if(self.cancle) {
        self.ssdpThread = nil;
        return;
    }
    
    IJTSSDP *ssdp = [[IJTSSDP alloc] init];
    if(ssdp.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"SSDP : %s.", strerror(ssdp.errorCode)]];
        self.ssdpThread = nil;
        return;
    }
    [ssdp injectTargetIpAddress:SSDP_MULTICAST_ADDR
                        timeout:TIMEOUT
                         target:self
                       selector:SSDP_CALLBACK_SEL
                         object:_onlineArray];
    if(ssdp.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"SSDP : %s.", strerror(ssdp.errorCode)]];
    }
    [ssdp close];
    self.ssdpThread = nil;
}

SSDP_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        [self setValue:product forKey:@"SSDPName" ipAddress:sourceIpAddress flags:IJTLANStatusFlagsSSDP withObject:object];
    }];
}

#pragma mark ping scan
- (void)pingInjectAndReadThread: (id)object {
    NSArray *list = object;
    IJTPing *ping = [[IJTPing alloc] init];
    if(ping.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"ping : %s.", strerror(ping.errorCode)]];
        self.pingThread = nil;
        return;
    }
    for(NSDictionary *dict in [list copy] ) {
        if(self.cancle)
            break;
        
        NSString *ipAddress = [dict valueForKey:@"IpAddress"];
        [ping setTarget:ipAddress];
        
        int ret =
        [ping injectWithInterval:100];
        if(ret == -1) {
            [self showErrorMessage:[NSString stringWithFormat:@"ping : %s.", strerror(ping.errorCode)]];
            if(ping.errorCode == ENOBUFS) {
                sleep(1);
            }
            else
                break;
        }
    }//end for
    
    [ping readTimeout:TIMEOUT
               target:self
             selector:PING_CALLBACK_SEL
               object:_onlineArray];
    
    [ping close];
    self.pingThread = nil;
}

PING_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        [self setValue:@(YES) forKey:@"Ping" ipAddress:replyIpAddress flags:IJTLANStatusFlagsPing withObject:object];
    }];
}

#pragma mark netbios scan
- (void)netbiosInjectAndReadThread: (id)object {
    NSArray *list = object;
    IJTNetbios *netbios = [[IJTNetbios alloc] init];
    if(netbios.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"NetBIOS : %s.", strerror(netbios.errorCode)]];
        self.netbiosThread = nil;
        return;
    }
    [netbios setReadUntilTimeout:YES];
    
    for(NSDictionary *dict in [list copy] ) {
        if(self.cancle)
            break;
        NSString *ipAddress = [dict valueForKey:@"IpAddress"];
        
        [netbios setOneTarget:ipAddress];
        [netbios injectWithInterval:100];
        if(netbios.errorHappened) {
            [self showErrorMessage:[NSString stringWithFormat:@"NetBIOS : %s.", strerror(netbios.errorCode)]];
            if(netbios.errorCode == ENOBUFS) {
                sleep(1);
            }
            else
                break;
        }
    }//end for
    
    
    [netbios readTimeout:TIMEOUT
                  target:self
                selector:NETBIOS_CALLBACK_SEL
                  object:_onlineArray];
    [netbios close];
    self.netbiosThread = nil;
}

NETBIOS_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        NSString *nameString = @"";
        for(NSString *name in netbiosNames) {
            if(nameString.length <= 0) {
                nameString = [NSString stringWithString:name];
            }
            else {
                nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@"\n%@", name]];
            }
        }//end for
        [self setValue:nameString forKey:@"netbiosName" ipAddress:sourceIpAddress flags:IJTLANStatusFlagsNetbios withObject:object];
    }];
}

#pragma mark mdns scan
- (void)mdnsInjectAndReadThread: (id)object {
    NSArray *list = object;
    
    IJTMDNS *mdns = [[IJTMDNS alloc] init];
    if(mdns.errorHappened) {
        [self showErrorMessage:[NSString stringWithFormat:@"mDNS : %s.", strerror(mdns.errorCode)]];
        self.mdnsThread = nil;
        return;
    }
    
    [mdns setReadUntilTimeout:YES];
    
    for(NSDictionary *dict in [list copy] ) {
        if(self.cancle)
            break;
        NSString *ipAddress = [dict valueForKey:@"IpAddress"];
        
        [mdns setOneTarget:ipAddress];
        [mdns injectWithInterval:100];
        if(mdns.errorHappened) {
            [self showErrorMessage:[NSString stringWithFormat:@"mDNS : %s.", strerror(mdns.errorCode)]];
            if(mdns.errorCode == ENOBUFS) {
                sleep(1);
            }
            else
                break;
        }
    }
    
    [mdns readTimeout:TIMEOUT
               target:self
             selector:MDNS_PTR_CALLBACK_SEL
               object:_onlineArray];
    [mdns close];
    self.mdnsThread = nil;
}

MDNS_PTR_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        [self setValue:resolveHostname forKey:@"mDNSName" ipAddress:ipAddress flags:IJTLANStatusFlagsMDNS withObject:object];
    }];
}

- (void)setValue: (id)value forKey: (NSString *)key ipAddress: (NSString *)ipAddress flags: (IJTLANStatusFlags)flag withObject: (id)object {
    int index = 0;
    NSMutableArray *list = (NSMutableArray *)object;
    NSMutableDictionary *dict = nil;
    for(index = 0; index < list.count ; index++) {
        dict = list[index];
        if([[dict valueForKey:@"IpAddress"] isEqualToString:ipAddress]) {
            break;
        }
    }//end for search array
    
    if(index == list.count)
        return;
    
    NSNumber *flagNumber = [dict valueForKey:@"Flags"];
    
    [dict setValue:value forKey:key];
    [dict setValue:[NSNumber numberWithUnsignedShort:[flagNumber unsignedShortValue] | flag] forKey:@"Flags"];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - ASProgressPopUpView dataSource

- (void)updateProgressView: (id)sender {
    u_int64_t total = [_arpScan getTotalInjectCount];
    u_int64_t remain = [_arpScan getRemainInjectCount];
    float value = (total - remain)/(float)total;
    
    [self.progressView setProgress:value animated:YES];
}

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if(progress == 0.0)
        return @"Initializing...";
    else if(progress < 0.99) {
        u_int64_t count = [_arpScan getRemainInjectCount];
        s = [NSString stringWithFormat:@"Left : %lu(%2d%%)", (unsigned long)count, (int)(progress*100)%100];
    }
    else {
        s = @"Querying with tool...";
    }
    return s;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0)
        return 1;
    else
        return _onlineArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        IJTLANTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
        
        [IJTFormatUILabel dict:_taskInfoDict
                           key:@"Range"
                         label:cell.rangeLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        
        [IJTFormatUILabel dict:_taskInfoDict
                           key:@"BSSID"
                         label:cell.bssidLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        
        [IJTFormatUILabel dict:_taskInfoDict
                           key:@"SSID"
                         label:cell.ssidLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [cell layoutIfNeeded];
        return cell;
    }
    else if(indexPath.section == 1) {
        IJTLANOnlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlineCell" forIndexPath:indexPath];
        NSDictionary *dict = _onlineArray[indexPath.row];
        NSString *nameKey = @"None";
        UIColor *nameColor = IJTValueColor;
        NSNumber *flagsNumner = [dict valueForKey:@"Flags"];
        
        if([dict valueForKey:@"DNSName"]) {
            nameKey = @"DNSName";
        }
        else if([dict valueForKey:@"LLMNRName"]) {
            nameKey = @"LLMNRName";
        }
        else if([dict valueForKey:@"mDNSName"]) {
            nameKey = @"mDNSName";
        }
        else if([dict valueForKey:@"netbiosName"]) {
            nameKey = @"netbiosName";
        }
        else if([dict valueForKey:@"SSDPName"]) {
            nameKey = @"SSDPName";
        }
        else if([dict valueForKey:@"Self"]) {
            nameKey = @"Self";
        }
        else {
            nameColor = [UIColor lightGrayColor];
        }
        
        [IJTFormatUILabel dict:dict
                           key:nameKey
                         label:cell.nameLabel
                         color:nameColor
                          font:[UIFont systemFontOfSize:11]];
        
        [IJTFormatUILabel dict:dict
                           key:@"IpAddress"
                         label:cell.ipAddressLabel
                         color:[UIColor darkGrayColor]
                          font:[UIFont systemFontOfSize:11]];
        
        [IJTFormatUILabel dict:dict
                           key:@"MacAddress"
                         label:cell.macAddressLabel
                         color:[UIColor darkGrayColor]
                          font:[UIFont systemFontOfSize:11]];
        
        if([dict valueForKey:@"OUI"] == nil) {
            NSString *macAddress = [dict valueForKey:@"MacAddress"];
            [dict setValue:[IJTDatabase oui:macAddress] forKey:@"OUI"];
        }
        
        [IJTFormatUILabel dict:dict
                           key:@"OUI"
                         label:cell.ouiLabel
                         color:[UIColor lightGrayColor]
                          font:[UIFont systemFontOfSize:11]];
        
        [self drawStatusAtView:cell.statusView flags:[flagsNumner unsignedShortValue]];

        [cell layoutIfNeeded];
        return cell;
    }
    return nil;
}

- (void)drawStatusAtView: (UIView *)view flags:(IJTLANStatusFlags)flags {
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat height = CGRectGetHeight(view.frame);
    CGFloat width = CGRectGetHeight(view.frame)*4./5.;
    CGFloat xposition = 0;
    struct bits *p = NULL;
    for (p = lan_bits; p->b_mask; p++) {
        if (p->b_mask & flags) {
            FUIButton *button = [[FUIButton alloc] initWithFrame:CGRectMake(xposition, 0, width, height)];
            [button setTitle:[NSString stringWithFormat:@"%c", p->b_val] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            button.buttonColor = [self statusColor:p->b_mask];
            button.shadowColor = [IJTColor darker:[self statusColor:p->b_mask] times:1];
            button.cornerRadius = 3.0f;
            button.shadowHeight = 2.0f;
            [view addSubview:button];
            xposition += width + 1;
        }
    }//end for each bits
}

- (UIColor *)statusColor: (IJTLANStatusFlags)flag {
    switch (flag) {
        case IJTLANStatusFlagsMyself: return [UIColor sunflowerColor];
        case IJTLANStatusFlagsGateway: return [UIColor carrotColor];
        case IJTLANStatusFlagsArping: return [UIColor alizarinColor];
        case IJTLANStatusFlagsDNS: return [UIColor amethystColor];
        case IJTLANStatusFlagsMDNS: return [UIColor peterRiverColor];
        case IJTLANStatusFlagsNetbios: return [UIColor brownColor];
        case IJTLANStatusFlagsPing: return [UIColor nephritisColor];
        case IJTLANStatusFlagsSSDP: return [UIColor wetAsphaltColor];
        case IJTLANStatusFlagsLLMNR: return [UIColor asbestosColor];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Target LAN Information";
    }
    else if(section == 1) {
        if(self.scanning)
            return @"Online";
        else
            return [NSString stringWithFormat:@"Online(%lu)", (unsigned long)_onlineArray.count];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1) {
        IJTLANDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LANDetailVC"];
        vc.dict = [NSMutableDictionary dictionaryWithDictionary:_onlineArray[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
