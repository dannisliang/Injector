//
//  IJTMainTableViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/5/12.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTMainTableViewController.h"
#import "IJTMainTableViewCell.h"
@interface IJTMainTableViewController ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, strong) NSArray *storyBoardIdsArray;


@end

@implementation IJTMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.titleArray = @[@"FLOW", @"SNIFFER", @"LAN", @"TOOL KIT", @"FIREWALL", @"SUPPORT"];
    self.iconArray = @[[UIImage imageNamed:@"Flow.png"],
                       [UIImage imageNamed:@"Sniffer.png"],
                       [UIImage imageNamed:@"LAN.png"],
                       [UIImage imageNamed:@"ToolKit.png"],
                       [UIImage imageNamed:@"Firewall.png"],
                       [UIImage imageNamed:@"Support.png"]
                       ];
    self.storyBoardIdsArray = @[@"FlowStoryboard", @"SnifferStoryboard", @"LANStoryboard", @"ToolKitStoryboard", @"FirewallStoryboard", @"SupportStoryboard"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark Table view delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_HEIGHT/6.0f;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        self.tableView.scrollEnabled = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IJTMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainFunctionCell" forIndexPath:indexPath];
    
    // Configure the cell...

    CGRect frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y,
                              CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds)+1);
    NSArray *colors = nil;
    //color
    switch (indexPath.row) {
        case 0: {
            colors = [NSArray arrayWithObjects:(id)[IJTFlowColor CGColor], (id)[[IJTColor lighter:IJTFlowColor times:2] CGColor], nil];
            [cell.backgroundImageView.layer insertSublayer:
             [IJTGradient verticallyGradientColors:colors frame:frame] atIndex:0];
        }
            break;
            
        case 1: {
            UIColor *transBgColor = [IJTColor lighter:IJTSnifferColor times:4 level:10];
            colors = [NSArray arrayWithObjects:(id)IJTSnifferColor.CGColor, (id)transBgColor.CGColor, (id)transBgColor.CGColor, (id)IJTSnifferColor.CGColor, nil];
            
            [cell.backgroundImageView.layer insertSublayer:
             [IJTGradient horizontalGradientColors:colors
                                             frame:frame
                                        startPoint:CGPointMake(0.0, 0.5)
                                          endPoint:CGPointMake(1.0, 0.5)
                                         locations:@[@(0), @(0.7), @(1.0)]]
                                                   atIndex:0];
        }
            
            break;
        case 2: {
            cell.backgroundImageView.image =
            [IJTGradient radialGradientImage:frame
                                       outer:IJTLANColor
                                       inner:[IJTColor darker:IJTLANColor times:2 level:15]
                                      center:CGPointMake(frame.size.width/10.0f*9.0, frame.size.height/5.0f*3.0)
                                      radius:frame.size.width/2.0f];
            cell.backgroundImageView.backgroundColor = IJTLANColor;
        }
            break;
        case 3: {
            cell.backgroundImageView.image =
            [IJTGradient radialGradientImage:frame
                                       outer:[IJTColor lighter:IJTToolsColor times:1]
                                       inner:[IJTColor lighter:IJTToolsColor times:4]
                                      center:CGPointMake(frame.size.width/2.0f, frame.size.height)
                                      radius:frame.size.width/1.5f];
            [cell.backgroundView addSubview:cell.backgroundImageView];
            cell.backgroundImageView.backgroundColor = [IJTColor lighter:IJTToolsColor times:1];
        }
            break;
            
        case 4: {
            UIColor *transBgColor = [IJTColor lighter:IJTFirewallColor times:1];
            colors = [NSArray arrayWithObjects:(id)IJTFirewallColor.CGColor, (id)transBgColor.CGColor, (id)transBgColor.CGColor, (id)IJTFirewallColor.CGColor, nil];
            
            [cell.backgroundImageView.layer insertSublayer:
             [IJTGradient horizontalGradientColors:colors
                                             frame:frame
                                        startPoint:CGPointMake(0.0, 0.5)
                                          endPoint:CGPointMake(1.0, 0.5)
                                         locations:@[@(0), @(0.7), @(1.0)]]
                                                   atIndex:0];
            
        }
            break;
            
        case 5: {
            colors = [NSArray arrayWithObjects:(id)[[IJTColor lighter:IJTSupportColor times:2] CGColor], (id)[IJTSupportColor CGColor], nil];
            [cell.backgroundImageView.layer insertSublayer:
             [IJTGradient verticallyGradientColors:colors frame:frame] atIndex:0];
        }
            break;
        default:
            break;
    }
    
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.titleLabel.textColor = IJTWhiteColor;
    
    cell.iconImageView.image = self.iconArray[indexPath.row];
    
    //draw text on image view
    cell.backgroundTitleImageView.image =
    [UIImage drawText:cell.titleLabel.text
              inImage:[UIImage blankImage:cell.backgroundTitleImageView.frame.size]
              atPoint:CGPointMake(0, 0)];
    cell.backgroundTitleImageView.backgroundColor = [UIColor clearColor];
    
    [cell.backgroundTitleImageView blurWithAlpha:0.7f radius:1.0f];

    [cell.backgroundTitleImageView addMotionEffect:[IJTMotionEffect parallax]];
    
    [cell layoutIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *colors = nil;
    FUIButton *buttonF = [FUIButton appearance];
    switch (indexPath.row) {
        case 0:
            colors = [NSArray arrayWithObjects:IJTFlowColor, [IJTColor lighter:IJTFlowColor times:2], nil];
            buttonF.buttonColor = [IJTColor lighter:IJTFlowColor times:2];
            buttonF.shadowColor = IJTFlowColor;
            break;
            
        case 1:
            colors = [NSArray arrayWithObjects:IJTSnifferColor, [IJTColor lighter:IJTSnifferColor times:1], nil];
            buttonF.buttonColor = [IJTColor lighter:IJTSnifferColor times:1];
            buttonF.shadowColor = [IJTColor darker:IJTSnifferColor times:1];
            break;
            
        case 2:
            colors = [NSArray arrayWithObjects:[IJTColor darker:IJTLANColor times:1], [IJTColor lighter:IJTLANColor times:1], nil];
            buttonF.buttonColor = IJTLANColor;
            buttonF.shadowColor = [IJTColor darker:IJTLANColor times:2];
            break;
            
        case 3:
            colors = [NSArray arrayWithObjects:[IJTColor darker:IJTToolsColor times:1], [IJTColor lighter:IJTToolsColor times:1], nil];
            buttonF.buttonColor = [IJTColor lighter:IJTToolsColor times:1];
            buttonF.shadowColor = [IJTColor darker:IJTToolsColor times:1];
            break;
            
        case 4:
            colors = [NSArray arrayWithObjects:IJTFirewallColor, [IJTColor lighter:IJTFirewallColor times:2], nil];
            buttonF.buttonColor = [IJTColor lighter:IJTFirewallColor times:1];
            buttonF.shadowColor = [IJTColor darker:IJTFirewallColor times:1];
            break;
            
        case 5:
            colors = [NSArray arrayWithObjects:[IJTColor darker:IJTSupportColor times:1], [IJTColor lighter:IJTSupportColor times:1], nil];
            buttonF.buttonColor = IJTSupportColor;
            buttonF.shadowColor = [IJTColor darker:IJTSupportColor times:2];
            break;
            
        default:
            colors = [NSArray arrayWithObjects:IJTNavigationBarBackgroundColor, [IJTColor lighter:IJTNavigationBarBackgroundColor times:2], nil];
            buttonF.buttonColor = IJTNavigationBarBackgroundColor;
            buttonF.shadowColor = [IJTColor darker:IJTNavigationBarBackgroundColor times:2];
            break;
    }
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.storyBoardIdsArray[indexPath.row] bundle:nil];
    UINavigationController *controller = [storyboard instantiateInitialViewController];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
