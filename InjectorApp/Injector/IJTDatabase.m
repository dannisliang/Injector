//
//  IJTDatabase.m
//  Injector
//
//  Created by 聲華 陳 on 2015/8/24.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTDatabase.h"
#import "IJTJson.h"
#import <net/ethernet.h>
@implementation IJTDatabase

+ (NSString *)oui: (NSString *)macAddress {
    
    NSString *path = nil;
    if(geteuid()) {
        path = [[NSBundle mainBundle] pathForResource:@"oui" ofType:@"json"];
    }
    else {
        path = @"/Applications/Injector.app/oui.json";
    }
    
    NSDictionary *ouiDatabase = [IJTJson file2dictionary:path];
    NSDictionary *list = [ouiDatabase valueForKey:@"db"];
    struct ether_addr *ether = ether_aton([macAddress UTF8String]);
    NSString *oui = nil;
    if(ether == NULL)
        return @"Unknown";
    
    macAddress = [NSString stringWithFormat:@"%02X%02X%02X", ether->octet[0], ether->octet[1], ether->octet[2]];
    
    oui = [list valueForKey:macAddress];
    return oui == nil ? @"Unknown" : oui;
}

+ (NSString *)port: (NSString *)portName {
    NSString *path = nil;
    if(geteuid()) {
        path = [[NSBundle mainBundle] pathForResource:@"port" ofType:@"json"];
    }
    else {
        path = @"/Applications/Injector.app/port.json";
    }
    
    NSDictionary *portDatabase = [IJTJson file2dictionary:path];
    NSDictionary *list = [portDatabase valueForKey:@"names"];
    NSString *name = [list valueForKey:portName];
    
    return name == nil ? @"Unknown" : name;
}
@end
