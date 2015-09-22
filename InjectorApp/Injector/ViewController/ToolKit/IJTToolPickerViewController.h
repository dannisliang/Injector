//
//  IJTToolPickerViewController.h
//  Injector
//
//  Created by 聲華 陳 on 2015/7/9.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJTBaseViewController.h"
typedef NS_ENUM(NSInteger, IJTToolPickerViewControllerType) {
    IJTToolPickerViewControllerTypeSystem = 0,
    IJTToolPickerViewControllerTypeNetwork
};

@interface IJTToolPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) IJTToolPickerViewControllerType type;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
