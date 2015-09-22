//
//  IJTLLMNRResultTableViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/9/22.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTLLMNRResultTableViewController.h"
#import "IJTMDNSTaskInfoTableViewCell.h"
#import "IJTMDNSHostnameTableViewCell.h"
#import "IJTDNSIPTableViewCell.h"

@interface IJTLLMNRResultTableViewController ()

@property (nonatomic, strong) UIBarButtonItem *queryButton;
@property (nonatomic, strong) NSMutableDictionary *taskInfoDict;
@property (nonatomic, strong) Reachability *wifiReachability;
@property (nonatomic, strong) IJTLLMNR *llmnr;
@property (nonatomic, strong) NSMutableArray *replyArray;
@property (nonatomic, strong) NSThread *requestThread;
@property (nonatomic, strong) NSTimer *updateProgressViewTimer;
@property (nonatomic) BOOL cancle;
@property (nonatomic, strong) ASProgressPopUpView *progressView;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) BOOL requerying;

@end

@implementation IJTLLMNRResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self size
    self.tableView.estimatedRowHeight = 45;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.title = @"LLMNR";
    
    self.dismissButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"left.png"]
                          style:UIBarButtonItemStylePlain
                          target:self action:@selector(dismissVC)];
    
    self.queryButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"LLMNRNav.png"]
                        style:UIBarButtonItemStylePlain
                        target:self action:@selector(query)];
    
    
    [self.stopButton setTarget:self];
    [self.stopButton setAction:@selector(stopQuery)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.dismissButton, self.multiToolButton, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_queryButton, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVC {
    [self.llmnr close];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IJTNotificationObserver reachabilityAddObserver:self selector:@selector(reachabilityChanged:)];
    if([IJTNetowrkStatus supportWifi]) {
        self.wifiReachability = [IJTNetowrkStatus wifiReachability];
        [self.wifiReachability startNotifier];
        [self reachabilityChanged:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [IJTNotificationObserver reachabilityRemoveObserver:self];
    if([IJTNetowrkStatus supportWifi])
        [self.wifiReachability stopNotifier];
}

- (void)stopQuery {
    if(self.requestThread || self.updateProgressViewTimer) {
        [self.stopButton setEnabled:NO];
        [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
            if(![self.requestThread isFinished]) {
                self.cancle = YES;
                while(self.requestThread) {
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

- (void)query {
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.stopButton, nil];
    self.replyArray = [[NSMutableArray alloc] init];
    self.requerying = YES;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.dismissButton setEnabled:NO];
    self.messageLabel.text = @"Querying...";
    self.cancle = NO;
    
    self.requestThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryThread) object:nil];
    
    if(self.typeSelectedIndex == 0) {
        if(self.targetSelectedIndex == 0) {
            [self.llmnr setOneTarget:self.target];
            
            [self.requestThread start];
        }
        else if(self.targetSelectedIndex == 1) {
            [self.llmnr setLAN];
            self.progressView = [IJTProgressView baseProgressPopUpView];
            self.progressView.dataSource = self;
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:
                                              CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_progressView.frame))];
            [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
            [self.tableView.tableHeaderView addSubview:self.progressView];
            [self.tableView setUserInteractionEnabled:NO];
            
            
            [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
                self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(60, 0, 0, 0);
                self.updateProgressViewTimer =
                [NSTimer scheduledTimerWithTimeInterval:0.05
                                                 target:self
                                               selector:@selector(updateProgressView:)
                                               userInfo:nil repeats:YES];
                
                [self.requestThread start];
            }];
        }//end if set lan
    }
    else if(self.typeSelectedIndex == 1 || self.typeSelectedIndex == 2) {
        [self.requestThread start];
    }
}

- (void)queryThread {
    if(self.typeSelectedIndex == 0) {
        u_int64_t amount = [self.llmnr getTotalInjectCount];
        for(_currentIndex = 0 ; _currentIndex < amount ; _currentIndex++) {
            if(self.cancle)
                break;
            int ret =
            [self.llmnr injectWithInterval:_interval];
            
            if(ret == -1) {
                [self showErrorMessage:[NSString stringWithFormat:@"%s.", strerror(self.llmnr.errorCode)]];
                if(self.llmnr.errorCode == ENOBUFS) {
                    sleep(1);
                }
                else
                    break;
            }
        }//end for inject
        
        [self.llmnr readTimeout:_timeout
                         target:self
                       selector:LLMNR_PTR_CALLBACK_SEL
                         object:_replyArray];
        
        if(self.llmnr.errorHappened) {
            [self showErrorMessage:[NSString stringWithFormat:@"%s.", strerror(self.llmnr.errorCode)]];
        }
        
        if(self.typeSelectedIndex == 0 && self.targetSelectedIndex == 1) {
            [self.updateProgressViewTimer invalidate];
            self.updateProgressViewTimer = nil;
        }
    }
    else if(self.typeSelectedIndex == 1 || self.typeSelectedIndex == 2) {
        sa_family_t family = self.typeSelectedIndex == 1 ? AF_INET :
        (self.typeSelectedIndex == 2) ? AF_INET6 : 0;
        int ret =
        [self.llmnr hostname2IpAddress:_target
                                family:family
                               timeout:_timeout
                                target:self
                              selector:LLMNR_CALLBACK_SEL
                                object:_replyArray];
        
        if(ret == -1) {
            [self showErrorMessage:[NSString stringWithFormat:@"%s.", hstrerror(self.llmnr.errorHappened)]];
        }
    }
    
    self.requerying = NO;
    [IJTDispatch dispatch_main:^{
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_queryButton, nil];
        [self.dismissButton setEnabled:YES];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if(self.replyArray.count == 0) {
            self.messageLabel.text = @"No Answer";
        }
        
        if(self.typeSelectedIndex == 0 && self.targetSelectedIndex == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.tableView setUserInteractionEnabled:YES];
            [self.progressView removeFromSuperview];
            
            [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        }
    }];
    
    self.requestThread = nil;
}

LLMNR_PTR_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        NSMutableArray *list = (NSMutableArray *)object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:resolveHostname forKey:@"ResolveHostname"];
        [dict setValue:name forKey:@"Hostname"];
        [dict setValue:ipAddress forKey:@"IpAddress"];
        [list addObject:dict];
        
        [self updateTableView];
    }];
}

LLMNR_CALLBACK_METHOD {
    [IJTDispatch dispatch_main:^{
        NSMutableArray *list = (NSMutableArray *)object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:hostname forKey:@"Hostname"];
        [dict setValue:ipAddress forKey:@"IpAddress"];
        [list addObject:dict];
        
        [self updateTableView];
    }];
}

- (void)updateTableView {
    NSArray *addArray = @[[NSIndexPath indexPathForRow:self.replyArray.count - 1 inSection:1]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:addArray withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - ASProgressPopUpView dataSource

- (void)updateProgressView: (id)sender {
    float value = self.currentIndex/(float)[self.llmnr getTotalInjectCount];
    [self.progressView setProgress:value animated:YES];
}

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if(progress < 0.99) {
        u_int64_t count = [self.llmnr getTotalInjectCount] - (u_int64_t)self.currentIndex;
        s = [NSString stringWithFormat:@"Left : %lu(%2d%%)", (unsigned long)count, (int)(progress*100)%100];
    }
    else {
        s =@"Reading...";
    }
    return s;
}

#pragma mark Reachability
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note {
    
    NSString *target = @"";
    if(self.wifiReachability.currentReachabilityStatus == NotReachable) {
        [self showWiFiOnlyNoteWithToolName:@"LLMNR"];
        if(self.llmnr != nil) {
            [self.llmnr close];
            self.llmnr = nil;
        }
        [self.queryButton setEnabled:NO];
    }
    else if(self.wifiReachability.currentReachabilityStatus == ReachableViaWiFi) {
        [self.queryButton setEnabled:YES];
        if(self.llmnr == nil) {
            self.llmnr = [[IJTLLMNR alloc] init];
        }
    }
    
    if(self.typeSelectedIndex == 0) {
        if(self.targetSelectedIndex == 0) {
            target = self.target;
            if(self.llmnr != nil) {
                [self.llmnr setOneTarget:self.target];
            }
        }
        else if(self.targetSelectedIndex == 1) {
            if(self.llmnr != nil) {
                [self.llmnr setLAN];
                target = [NSString stringWithFormat:@"%@ - %@",
                          [self.llmnr getStartIpAddress], [self.llmnr getEndIpAddress]];
            }
        }
    }
    else if(self.typeSelectedIndex == 1 || self.typeSelectedIndex == 2) {
        target = self.target;
    }
    
    self.taskInfoDict = [[NSMutableDictionary alloc] init];
    [self.taskInfoDict setValue:target forKey:@"Target"];
    [self.taskInfoDict setValue:self.type forKey:@"Type"];
    
    self.messageLabel.text = [NSString stringWithFormat:@"Target : %@\nType : %@", target, self.type];
    
    [IJTDispatch dispatch_main:^{
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(self.replyArray.count == 0) {
        [self.tableView addSubview:self.messageLabel];
    }
    else {
        [self.messageLabel removeFromSuperview];
    }
    
    if(section == 0)
        return 1;
    else if(section == 1) {
        return self.replyArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        IJTMDNSTaskInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
        
        [IJTFormatUILabel dict:_taskInfoDict
                           key:@"Target"
                         label:cell.targetLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [IJTFormatUILabel dict:_taskInfoDict
                           key:@"Type"
                         label:cell.typeLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [cell.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.font = [UIFont systemFontOfSize:11];
        }];
        
        [cell layoutIfNeeded];
        return cell;
    }
    else if(indexPath.section == 1 && self.typeSelectedIndex == 0) {
        IJTMDNSHostnameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HostnameCell" forIndexPath:indexPath];
        
        NSDictionary *dict = self.replyArray[indexPath.row];
        
        [IJTFormatUILabel dict:dict
                           key:@"ResolveHostname"
                         label:cell.resolveHostnameLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [IJTFormatUILabel dict:dict
                           key:@"Hostname"
                         label:cell.hostnameLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [IJTFormatUILabel dict:dict
                           key:@"IpAddress"
                         label:cell.ipAddressLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [cell.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.font = [UIFont systemFontOfSize:11];
        }];
        
        [cell layoutIfNeeded];
        return cell;
    }
    else if(indexPath.section == 1 && (self.typeSelectedIndex == 1 || self.typeSelectedIndex == 2)) {
        IJTDNSIPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPCell" forIndexPath:indexPath];
        
        NSDictionary *dict = self.replyArray[indexPath.row];
        
        [IJTFormatUILabel dict:dict
                           key:@"IpAddress"
                         label:cell.ipAddressLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        [IJTFormatUILabel dict:dict
                           key:@"Hostname"
                         label:cell.hostnameLabel
                         color:IJTValueColor
                          font:[UIFont systemFontOfSize:11]];
        
        [cell.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.font = [UIFont systemFontOfSize:11];
        }];
        
        [cell layoutIfNeeded];
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Task Information";
    else if(section == 1) {
        if(self.requerying)
            return @"Answer";
        else
            return [NSString stringWithFormat:@"Answer(%lu)", (unsigned long)self.replyArray.count];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
