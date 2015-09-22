//
//  AppDelegate.m
//  Injector
//
//  Created by 聲華 陳 on 2015/2/27.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "AppDelegate.h"
#import <sys/types.h>
#import <sys/stat.h>
#import "IJTBaseViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

static void handleUncaughtException(NSException *exception) {
    NSLog(@"Exception - %@",[exception description]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSSetUncaughtExceptionHandler(handleUncaughtException);
    
    //status bar color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //set navigationbar style
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    NSMutableDictionary *navBarTextAttributes =
    [[NSMutableDictionary alloc] init];
    [navBarTextAttributes setObject:IJTWhiteColor forKey: NSForegroundColorAttributeName];
    [navBarTextAttributes setObject:[UIFont boldSystemFontOfSize:18] forKey:NSFontAttributeName];
    
    //off translucent
    navigationBar.translucent = NO;
    //set title text color
    navigationBar.titleTextAttributes = navBarTextAttributes;
    //set back button colot
    navigationBar.tintColor = IJTLightBlueColor;
    
    //set tab bar style
    UITabBar *tabBar = [UITabBar appearance];
    //background color
    tabBar.barTintColor = IJTTabBarBackgroundColor;
    //text color
    tabBar.tintColor = IJTTabBarTextColor;
    
    //set activity style
    UIActivityIndicatorView *activity = [UIActivityIndicatorView appearance];
    activity.color = IJTLoadColor;
    
    //tableview header footer style
    //UITableViewHeaderFooterView *headerFooter = [UITableViewHeaderFooterView appearance];
    //headerFooter.backgroundColor = [IJTColor darker:[UIColor cloudsColor] times:1 level:5];

    //tableview style
    UITableView *tableview = [UITableView appearance];
    //tableview.backgroundColor = IJTTableViewBackgroundColor;
    //empty cell hide separator line
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableview.backgroundColor = IJTTableViewBackgroundColor;
    
    //switch style
    //UISwitch *uiSwitch = [UISwitch appearance];
    //uiSwitch.onTintColor = IJTValueColor;
    FUISwitch *uiSwitchF = [FUISwitch appearance];
    uiSwitchF.onColor = [UIColor turquoiseColor];
    uiSwitchF.offColor = [UIColor cloudsColor];
    uiSwitchF.onBackgroundColor = [UIColor midnightBlueColor];
    uiSwitchF.offBackgroundColor = [UIColor silverColor];
    
    //segmentedCtl style
    //UISegmentedControl *segmetedCtl = [UISegmentedControl appearance];
    //segmetedCtl.tintColor = IJTValueColor;
    FUISegmentedControl *segmetedCtlF = [FUISegmentedControl appearance];
    segmetedCtlF.selectedFont = [UIFont boldFlatFontOfSize:16];
    segmetedCtlF.selectedFontColor = [UIColor cloudsColor];
    segmetedCtlF.deselectedFont = [UIFont flatFontOfSize:16];
    segmetedCtlF.deselectedFontColor = [UIColor cloudsColor];
    segmetedCtlF.selectedColor = IJTValueColor;
    segmetedCtlF.deselectedColor = [UIColor silverColor];
    segmetedCtlF.disabledColor = IJTDarkGreyColor;
    segmetedCtlF.dividerColor = [UIColor asbestosColor];
    segmetedCtlF.cornerRadius = 5.0;
    
    //collection view style
    UICollectionView *collectionView = [UICollectionView appearance];
    collectionView.backgroundColor = IJTCollectionViewBackgroundColor;
    collectionView.bounces = NO;
    collectionView.scrollEnabled = NO;
    
    //collection cell style
    UICollectionViewCell *collectionViewCell = [UICollectionViewCell appearance];
    collectionViewCell.backgroundColor = IJTCollectionViewCellBackgroundColor;
    
    //flat uibutton
    FUIButton *buttonF = [FUIButton appearance];
    //buttonF.buttonColor = [UIColor turquoiseColor];
    //buttonF.shadowColor = [UIColor greenSeaColor];
    buttonF.cornerRadius = 10.0f;
    [buttonF setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [buttonF setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    buttonF.shadowHeight = 5.0f;
    [buttonF.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    //flat uitextfield
    FUITextField *textfieldF = [FUITextField appearance];
    textfieldF.backgroundColor = [UIColor whiteColor];
    textfieldF.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    textfieldF.textFieldColor = [UIColor cloudsColor];
    textfieldF.borderColor = [UIColor turquoiseColor];
    textfieldF.borderWidth = 3.0f;
    textfieldF.cornerRadius = 4.0f;
    textfieldF.textColor = [UIColor midnightBlueColor];
    textfieldF.adjustsFontSizeToFitWidth = YES;
    textfieldF.textAlignment = NSTextAlignmentCenter;
    textfieldF.clearButtonMode = UITextFieldViewModeAlways;
    //it will crash
    //textfielfF.autocorrectionType = UITextAutocorrectionTypeNo;
    //textfielfF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    //uitextfield
    UITextField *textfield = [UITextField appearance];
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.textColor = [UIColor midnightBlueColor];
    textfield.adjustsFontSizeToFitWidth = YES;
    textfield.textAlignment = NSTextAlignmentCenter;
    textfield.clearButtonMode = UITextFieldViewModeAlways;
    
    //bar button item
    UIBarButtonItem *barButton = [UIBarButtonItem appearance];
    barButton.tintColor = IJTLightBlueColor;
    
    //search bar
    UISearchBar *searchBar = [UISearchBar appearance];
    searchBar.translucent = NO;
    searchBar.backgroundImage = [UIImage imageWithCGImage:(__bridge CGImageRef)([UIColor clearColor])];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.barTintColor = IJTTableViewBackgroundColor;
    
    //register local notification
    [IJTLocalNotification registerLocalNotification];
    [IJTLocalNotification setBadgeNumber:0];
    
    //enable shake
    application.applicationSupportsShakeToEdit = YES;
    
    
    //facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [IJTDispatch dispatch_global:IJTDispatchPriorityDefault block:^{
        [IJTHTTP retrieveFrom:@"UpdateSystemVersion.php"
                         post:[NSString stringWithFormat:@"SerialNumber=%@&SystemVersion=%@", [IJTID serialNumber], [ALHardware systemVersion]]
                      timeout:5];
    }];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if([url.scheme isEqualToString:@"fb279166458950120"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if(state == UIApplicationStateBackground) {
        FUIAlertView *alertView = [IJTShowMessage baseAlertViewWithTitle:notification.alertAction
                                                                 message:notification.alertBody
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
        
        [alertView show];
        [IJTLocalNotification setBadgeNumber:0];
    }//end if
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [IJTLocalNotification setBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "tw.edu.mcu.cce.nrl.Injector" in the application's documents directory.
    if(getegid()) {
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }
    else {//root
        struct stat st = {0};
        //create dir
        if (stat("/var/root/Injector/", &st) == -1) {
            mkdir("/var/root/Injector/", 0755);
        }
        
        return [NSURL fileURLWithPath:@"/var/root/Injector/"];
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Injector" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Injector.sqlite"];

    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
