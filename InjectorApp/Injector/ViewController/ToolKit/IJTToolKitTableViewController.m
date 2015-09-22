//
//  IJTToolKitTableViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/7/8.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTToolKitTableViewController.h"
#import "IJTSystemToolTableViewCell.h"
#import "IJTNetworkToolTableViewCell.h"
#import "IJTToolPickerViewController.h"
#import "IJTMultiSelectTableViewController.h"
@interface IJTToolKitTableViewController ()

@property (nonatomic, strong) NSArray *systemToolArray;
@property (nonatomic, strong) NSArray *networkToolArray;
@property (nonatomic, strong) UIImageView *systemBackgroundImageView;
@property (nonatomic, strong) UIImageView *networkBackgroundImageView;

@end

@implementation IJTToolKitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.systemToolArray = [IJTBaseViewController getSystemToolArray];
    self.systemBackgroundImageView = [[UIImageView alloc]
                                      initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/1.3, SCREEN_WIDTH/1.3)];
    self.systemBackgroundImageView.alpha = 0.4f;
    self.systemBackgroundImageView.image = [UIImage imageNamed:@"SystemToolIcon.png"];
    self.systemBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.systemBackgroundImageView addMotionEffect:[IJTMotionEffect parallax]];
    
    self.networkToolArray = [IJTBaseViewController getNetworkToolArray];
    self.networkBackgroundImageView = [[UIImageView alloc]
                                       initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/1.3, SCREEN_WIDTH/1.3)];
    self.networkBackgroundImageView.alpha = 0.3f;
    self.networkBackgroundImageView.image = [UIImage imageNamed:@"NetworkToolIcon.png"];
    self.networkBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.networkBackgroundImageView addMotionEffect:[IJTMotionEffect parallax]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(backgroundAnimation:)
                                                    userInfo:nil repeats:YES];
    
    [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
        [self backgroundAnimation:timer];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gotoSystemToolVC {
    IJTToolPickerViewController *toolPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ToolPickerVC"];
    toolPickerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    toolPickerVC.type = IJTToolPickerViewControllerTypeSystem;
    [self.navigationController presentViewController:toolPickerVC animated:YES completion:nil];
}

- (void)gotoNetworkToolVC {
    IJTToolPickerViewController *toolPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ToolPickerVC"];
    toolPickerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    toolPickerVC.type = IJTToolPickerViewControllerTypeNetwork;
    [self.navigationController presentViewController:toolPickerVC animated:YES completion:nil];
}

- (void)gotoMultiSelectVC {
    IJTMultiSelectTableViewController *multiSelectVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiSelectNavVC"];
    
    multiSelectVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:multiSelectVC animated:YES completion:nil];
}

- (void)backgroundAnimation: (NSTimer *)timer {
    [UIImageView animateWithDuration:1.5f animations:^{
        self.systemBackgroundImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.networkBackgroundImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }
                          completion:^(BOOL finished){
                              [UIImageView animateWithDuration:1.5f animations:^{
                                  self.systemBackgroundImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                  self.networkBackgroundImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                              }
                                                    completion:nil];
                          }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0) {
        IJTSystemToolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemToolCell" forIndexPath:indexPath];
        
        [[cell.iconBackgroundView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [cell.iconBackgroundView addSubview:self.systemBackgroundImageView];
        cell.iconBackgroundView.backgroundColor = [UIColor clearColor];
        cell.titleLabel.text = @"System";
        cell.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        //cell.subTitleTextView.font = [UIFont systemFontOfSize:14];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:25];
        }
        else {
            if([[UIDeviceHardware platformString] containsString:@"iPhone 4"] ||
               [[UIDeviceHardware platformString] containsString:@"iPhone 5"] ||
               [[UIDeviceHardware platformString] isEqualToString:@"Simulator"]) {
                cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
            }
            else
                cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
        }
        cell.subTitleTextView.editable = NO;
        cell.subTitleTextView.selectable = NO;
        
        [cell.iconButton addTarget:self action:@selector(gotoSystemToolVC) forControlEvents:UIControlEventTouchUpInside];
        
        cell.subTitleTextView.text = [NSString stringWithFormat:@"Currently available(%lu) :", (unsigned long)self.systemToolArray.count];
        for(NSString *s in self.systemToolArray) {
            cell.subTitleTextView.text =
            [cell.subTitleTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n  ● %@", s]];
        }
        
        [cell.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        //color button
        UIImage *image = [cell.dismissButton.currentImage imageWithColor:IJTIconWhiteColor];
        [cell.dismissButton setImage:image forState:UIControlStateNormal];
        
        [cell.multiSelectButton addTarget:self action:@selector(gotoMultiSelectVC) forControlEvents:UIControlEventTouchUpInside];
        
        cell.titleLabel.textColor = IJTWhiteColor;
        cell.subTitleTextView.textColor = IJTWhiteColor;
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.subTitleTextView.backgroundColor = [UIColor clearColor];
        
        CGRect frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y,
                                  CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds)+1);

        [cell.backgroundColorView.layer insertSublayer:
         [IJTGradient verticallyGradientColors:
          [NSArray arrayWithObjects:(id)[[IJTColor darker:IJTToolsColor times:1] CGColor],
           (id)[[IJTColor lighter:IJTToolsColor times:1] CGColor], nil]
                                         frame:frame]
                                               atIndex:0];
        
        [cell layoutIfNeeded];
        [cell.subTitleTextView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        
        return cell;
    }
    else if(indexPath.row == 1) {
        IJTNetworkToolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkToolCell" forIndexPath:indexPath];
        
        [[cell.iconBackgroundView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [cell.iconBackgroundView addSubview:self.networkBackgroundImageView];
        cell.iconBackgroundView.backgroundColor = [UIColor clearColor];
        cell.titleLabel.text = @"Network";
        cell.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        //cell.subTitleTextView.font = [UIFont systemFontOfSize:14];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:25];
        }
        else {
            if([[UIDeviceHardware platformString] containsString:@"iPhone 4"] ||
               [[UIDeviceHardware platformString] containsString:@"iPhone 5"] ||
               [[UIDeviceHardware platformString] isEqualToString:@"Simulator"]) {
                cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
            }
            else
                cell.subTitleTextView.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
        }
        cell.subTitleTextView.editable = NO;
        cell.subTitleTextView.selectable = NO;
        
        [cell.iconButton addTarget:self action:@selector(gotoNetworkToolVC) forControlEvents:UIControlEventTouchUpInside];
        
        cell.subTitleTextView.text = [NSString stringWithFormat:@"Currently available(%lu) :", (unsigned long)self.networkToolArray.count];
        for(NSString *s in self.networkToolArray) {
            cell.subTitleTextView.text =
            [cell.subTitleTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n  ● %@", s]];
        }
        
        cell.titleLabel.textColor = IJTWhiteColor;
        cell.subTitleTextView.textColor = IJTWhiteColor;
        cell.backgroundColor = [UIColor blackColor];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.subTitleTextView.backgroundColor = [UIColor clearColor];
        
        CGRect frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y,
                                  CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds)+1);
        
        [cell.backgroundColorView.layer insertSublayer:
         [IJTGradient verticallyGradientColors:
          [NSArray arrayWithObjects:(id)[[IJTColor lighter:IJTToolsColor times:1] CGColor],
           (id)[[IJTColor lighter:IJTToolsColor times:3] CGColor], nil]
                                         frame:frame]
                                               atIndex:0];
        
        [cell layoutIfNeeded];
        [cell.subTitleTextView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        
        return cell;
    }
    else
        return nil;
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        self.tableView.scrollEnabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_HEIGHT/2.0f;
}

@end
