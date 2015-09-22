//
//  IJTBaseViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/8/11.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTBaseViewController.h"

@interface IJTBaseViewController () <JFMinimalNotificationDelegate>

@property (nonatomic, strong) JFMinimalNotification *minimalNotification;

@end

@implementation IJTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithTitle:@""
     style:UIBarButtonItemStylePlain
     target:nil
     action:nil];
    
    self.stopButton = [[UIBarButtonItem alloc]
                       initWithImage:[UIImage imageNamed:@"stop.png"]
                       style:UIBarButtonItemStylePlain
                       target:nil action:nil];
    [self.stopButton setTintColor:IJTStopRecordColor];
    
    self.messageLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(self.view.center.x - SCREEN_WIDTH/2 + 8,
                                                  SCREEN_HEIGHT/2 - CGRectGetHeight(self.navigationController.navigationBar.frame)/2 - CGRectGetHeight(self.tabBarController.tabBar.frame)/2 - 60,
                                                  SCREEN_WIDTH - 16, 120)];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.textColor = IJTSupportColor;
    self.messageLabel.font = [UIFont boldFlatFontOfSize:30];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    
    self.tableView.backgroundColor = IJTTableViewBackgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.delegate = nil;
}

+ (NSArray *)getSystemToolArray {
    NSArray *array = @[@"ARP Table", @"Interface Configure", @"Connection", @"Route Table"];
    return [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSArray *)getSystemImageNameArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray: [IJTBaseViewController getSystemToolArray]];
    for(int i = 0 ; i < array.count; i++) {
        NSString *name = array[i];
        array[i] = [name stringByAppendingString:@".png"];
    }
    
    return [NSArray arrayWithArray:array];
}

+ (NSArray *)getNetworkToolArray {
    NSArray *array = @[@"ACK Scan",
                       @"ARP-scan", @"arping", @"arpoison",
                       @"Connect Scan",
                       @"DNS", @"FIN Scan", @"LLMNR", @"Maimon Scan",
                       @"mDNS", @"NetBIOS", @"NULL Scan", @"ping",
                       @"SSDP", @"SYN Flood", @"SYN Scan",
                       @"tracepath", @"UDP Scan", @"Wake-on-LAN", @"WHOIS", @"Xmas Scan"];

    return [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSArray *)getNetworkImageNameArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray: [IJTBaseViewController getNetworkToolArray]];
    for(int i = 0 ; i < array.count; i++) {
        NSString *name = array[i];
        array[i] = [name stringByAppendingString:@".png"];
    }
    
    return [NSArray arrayWithArray:array];
}

+ (NSArray *)getLANSupportToolArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[IJTBaseViewController getNetworkToolArray]];
    [array removeObject:@"ARP-scan"];
    
    return array;
}

+ (NSArray *)getLANSupportToolImageNameArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray: [IJTBaseViewController getLANSupportToolArray]];
    for(int i = 0 ; i < array.count; i++) {
        NSString *name = array[i];
        array[i] = [name stringByAppendingString:@".png"];
    }
    
    return [NSArray arrayWithArray:array];
}

- (void)minimalNotificationDidDismissNotification:(JFMinimalNotification*)notification {
    if(self.minimalNotification != nil) {
        [self.minimalNotification removeFromSuperview];
        self.minimalNotification = nil;
    }
}

- (void)showInfoMessage: (NSString *)message title: (NSString *)title {
    @try {
        if([self topMostController] == self) {
            [IJTDispatch dispatch_main:^{
                if(self.minimalNotification == nil) {
                    [self baseNotificationViewWithTitle:title
                                               subTitle:message
                                                  style:JFMinimalNotificationStyleDefault];
                    self.minimalNotification.delegate = self;
                    /**
                     * Add the notification to a view
                     */
                    if(self.tabBarController.viewControllers.count != 0)
                        [self.tabBarController.view addSubview:self.minimalNotification];
                    else
                        [self.navigationController.view addSubview:self.minimalNotification];
                    [self.minimalNotification show];
                }
            }];
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)showInfoMessage: (NSString *)message {
    [self showInfoMessage:message title:@"Information"];
}

- (void)showErrorMessage: (NSString *)message {
    [self showErrorMessage:message title:@"Error"];
}

- (void)showErrorMessage: (NSString *)message title: (NSString *)title {
    @try {
        if([self topMostController] == self) {
            [IJTDispatch dispatch_main:^{
                if(self.minimalNotification == nil) {
                    [self baseNotificationViewWithTitle:title
                                               subTitle:message
                                                  style:JFMinimalNotificationStyleError];
                    self.minimalNotification.delegate = self;
                    /**
                     * Add the notification to a view
                     */
                    if(self.tabBarController.viewControllers.count != 0)
                        [self.tabBarController.view addSubview:self.minimalNotification];
                    else
                        [self.navigationController.view addSubview:self.minimalNotification];
                    [self.minimalNotification show];
                }
            }];
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)showWarningMessage: (NSString *)message {
    [self showWarningMessage:message title:@"Warning"];
}

- (void)showWarningMessage: (NSString *)message title: (NSString *)title {
    @try {
        if([self topMostController] == self) {
            [IJTDispatch dispatch_main:^{
                if(self.minimalNotification == nil) {
                    [self baseNotificationViewWithTitle:title
                                               subTitle:message
                                                  style:JFMinimalNotificationStyleWarning];
                    self.minimalNotification.delegate = self;
                    /**
                     * Add the notification to a view
                     */
                    if(self.tabBarController.viewControllers.count != 0)
                        [self.tabBarController.view addSubview:self.minimalNotification];
                    else
                        [self.navigationController.view addSubview:self.minimalNotification];
                    [self.minimalNotification show];
                }
            }];
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)showSuccessMessage: (NSString *)message {
    [self showSuccessMessage:message title:@"Success"];
}

- (void)showSuccessMessage: (NSString *)message title: (NSString *)title {
    @try {
        if([self topMostController] == self) {
            [IJTDispatch dispatch_main:^{
                if(self.minimalNotification == nil) {
                    [self baseNotificationViewWithTitle:title
                                               subTitle:message
                                                  style:JFMinimalNotificationStyleSuccess];
                    self.minimalNotification.delegate = self;
                    /**
                     * Add the notification to a view
                     */
                    if(self.tabBarController.viewControllers.count != 0)
                        [self.tabBarController.view addSubview:self.minimalNotification];
                    else
                        [self.navigationController.view addSubview:self.minimalNotification];
                    [self.minimalNotification show];
                }
            }];
        }
    }
    @catch (NSException *exception) {
    }
}


- (void)baseNotificationViewWithTitle: (NSString *)title
                             subTitle: (NSString *)subTitle
                                style: (JFMinimalNotificationStyle)style {
    NSTimeInterval dismissDelay = 2;
    if(style == JFMinimalNotificationStyleSuccess)
        dismissDelay = 0.8;
    self.minimalNotification =
    [JFMinimalNotification notificationWithStyle:style
                                           title:title subTitle:subTitle
                                  dismissalDelay:dismissDelay
                                    touchHandler:^{
                                        [self.minimalNotification dismiss];
                                    }];
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
    [self.minimalNotification setSubTitleFont:subTitleFont];
    
    /**
     * Set any necessary edge padding as needed
     */
    self.minimalNotification.edgePadding = UIEdgeInsetsMake(0, 0, 10, 0);
}

- (void)showWiFiOnlyNoteWithToolName: (NSString *)toolName {
    if([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable) {
        [self showWarningMessage:
         [NSString stringWithFormat:@"%@ must running via Wi-Fi.", toolName]];
    }
}

- (UIViewController*)topMostController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark AMWaveTransition

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        // Return your preferred transition operation
        return [AMWaveTransition transitionWithOperation:operation];
    }
    return nil;
}
@end
