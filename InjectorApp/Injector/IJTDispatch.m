//
//  IJTDispatch.m
//  Injector
//
//  Created by 聲華 陳 on 2015/7/20.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTDispatch.h"

@implementation IJTDispatch

+ (void)dispatch_main_after: (NSTimeInterval)delay block:(void (^)(void))block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

+ (void)dispatch_global: (IJTDispatchPriority)priority block:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(priority, 0), block);
}

+ (void)dispatch_main: (void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
