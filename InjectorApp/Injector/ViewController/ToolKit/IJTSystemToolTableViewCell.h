//
//  IJTSystemToolTableViewCell.h
//  Injector
//
//  Created by 聲華 陳 on 2015/7/8.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJTSystemToolTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UIView *iconBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *subTitleTextView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundColorView;
@property (weak, nonatomic) IBOutlet UIButton *multiSelectButton;

@end
