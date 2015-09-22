//
//  IJTHTTP.m
//  Injector
//
//  Created by 聲華 陳 on 2015/3/12.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTHTTP.h"

#define BASEURL @"https://nrl.cce.mcu.edu.tw/injector/dbAccess/"

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end

@implementation IJTHTTP

+ (NSString *)retrieveFrom: (NSString *)path post:(NSString *)post timeout: (NSTimeInterval)timeout
{
    path = [NSString stringWithFormat:@"%@%@", BASEURL, path];
    NSURL *url = [NSURL URLWithString: path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url cachePolicy:
                                    NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:3];
    [NSURLRequest allowsAnyHTTPSCertificateForHost: path]; //可以使用https網站
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timeout];
    
    //設定参数
    NSData *data = [post dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[post length]]
                              forHTTPHeaderField:@"Content-Length"];
    
    //上傳資料
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
}

+ (NSString *)string2post: (NSString *)string {
    //http://en.wikipedia.org/wiki/Percent-encoding
    NSString *output = [NSString stringWithString:string];
    NSArray *key = @[@"!", @"#", @"&", @"\'", @"(", @")", @"*", @"+", @",", @"/", @":", @";", @"=", @"?", @"@", @"[", @"]"];
    NSArray *value = @[@"%21", @"%23", @"%26", @"%27", @"%28", @"%29", @"%2A", @"%2B", @"%2C", @"%2F", @"%3A", @"%3B", @"%3D", @"%3F", @"%40", @"%5B", @"%5D"];
    for(int i = 0 ; i < key.count ; i++) {
        output = [output stringByReplacingOccurrencesOfString:key[i] withString:value[i]];
    }
    
    return output;
}

+ (NSString *)getFrom: (NSString *)path timeout: (NSTimeInterval)timeout
{
    NSURL *url = [NSURL URLWithString: path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url cachePolicy:
                                    NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:3];
    [NSURLRequest allowsAnyHTTPSCertificateForHost: path]; //可以使用https網站
    [request setTimeoutInterval:timeout];
    
    //設定参数
    
    //上傳資料
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
}
/*
+ (NSString *)getHtmlPath: (NSString *)path
{
    path = [NSString stringWithFormat:@"%@%@", BASEURL, path];
    NSURL *url = [NSURL URLWithString: path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url cachePolicy:
                                    NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:3];
    [NSURLRequest allowsAnyHTTPSCertificateForHost: path]; //可以使用https網站
    
    //上傳資料
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
}
 */
@end
