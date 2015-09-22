//
//  IJTHTTP.h
//  Injector
//
//  Created by 聲華 陳 on 2015/3/12.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface IJTHTTP : NSObject

//+ (NSString *)post: (NSString *)post path: (NSString *)path;

/**
 * 從伺服器取回資料
 * @param retrieveFrom ~/dbAccess/之後的路徑
 * @param post 要post的資料
 * @param timeout
 * @return 取回的資料
 */
+ (NSString *)retrieveFrom: (NSString *)path post:(NSString *)post timeout: (NSTimeInterval)timeout;

/**
 * 把字串轉成可post字串
 */
+ (NSString *)string2post: (NSString *)string;

/**
 * 送出get請求
 */
+ (NSString *)getFrom: (NSString *)path timeout: (NSTimeInterval)timeout;
@end
