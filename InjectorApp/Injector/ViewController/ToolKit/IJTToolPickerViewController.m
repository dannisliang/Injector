//
//  IJTToolPickerViewController.m
//  Injector
//
//  Created by 聲華 陳 on 2015/7/9.
//  Copyright (c) 2015年 Qbsuran Alang. All rights reserved.
//

#import "IJTToolPickerViewController.h"
#import "IJTToolPickerCollectionViewCell.h"

@interface IJTToolPickerViewController ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, strong) NSMutableArray *iconImageViewArray;

@end

@implementation IJTToolPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    if(self.type == IJTToolPickerViewControllerTypeSystem) {
        self.titleArray = [IJTBaseViewController getSystemToolArray];
        self.imageNameArray = [IJTBaseViewController getSystemImageNameArray];
        self.titleLabel.text = @"System Tools";
    }
    else if(self.type == IJTToolPickerViewControllerTypeNetwork) {
        self.titleArray = [IJTBaseViewController getNetworkToolArray];
        self.imageNameArray = [IJTBaseViewController getNetworkImageNameArray];
        self.titleLabel.text = @"Network Tools";
    }
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = IJTWhiteColor;
    
    [(EBCardCollectionViewLayout *)_collectionView.collectionViewLayout setOffset:UIOffsetMake(10, 10)];
    [(EBCardCollectionViewLayout *)_collectionView.collectionViewLayout setLayoutType:EBCardCollectionLayoutHorizontal];
    
    self.collectionView.pagingEnabled = NO;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.scrollEnabled = YES;
    //self.collectionView.showsHorizontalScrollIndicator = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    if(self.type == IJTToolPickerViewControllerTypeSystem) {
        [self.view.layer insertSublayer:
         [IJTGradient verticallyGradientColors:
          [NSArray arrayWithObjects:(id)[[IJTColor darker:IJTSnifferColor times:1] CGColor], (id)[[IJTColor lighter:IJTSnifferColor times:2] CGColor], nil]
                                         frame:self.view.frame]
                                atIndex:0];
    }
    else if(self.type == IJTToolPickerViewControllerTypeNetwork) {
        [self.view.layer insertSublayer:
         [IJTGradient verticallyGradientColors:
          [NSArray arrayWithObjects:(id)[[IJTColor darker:IJTLANColor times:0] CGColor], (id)[[IJTColor lighter:IJTLANColor times:2] CGColor], nil]
                                         frame:self.view.frame]
                                atIndex:0];
    }
    
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    //color button image
    UIImage *image = [self.dismissButton.currentImage imageWithColor:IJTIconWhiteColor];
    [self.dismissButton setImage:image forState:UIControlStateNormal];
    
    self.iconImageViewArray = [[NSMutableArray alloc] init];
    for(NSString *name in self.imageNameArray) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 140 - 20, SCREEN_WIDTH - 140 - 20);
        [self.iconImageViewArray addObject:imageView];
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(iconAnimation:)
                                                    userInfo:nil repeats:YES];
    
    //page control
    self.pageControl.numberOfPages = self.titleArray.count;
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.transform = CGAffineTransformMakeScale(0.85, 0.85);
    
    [IJTDispatch dispatch_main_after:DISPATCH_DELAY_TIME block:^{
        [self iconAnimation:timer];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickTool: (id)sender {
    FUIButton *button = (FUIButton *)sender;
    NSString *vcID = [NSString stringWithFormat:@"%@NavVC", self.titleArray[button.tag]];
    UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:vcID];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)iconAnimation: (NSTimer *)timer {
    for(UIImageView *imageView in self.iconImageViewArray) {
        [UIImageView animateWithDuration:1.5f animations:^{
            imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }
                              completion:^(BOOL finished){
                                  [UIImageView animateWithDuration:1.5f animations:^{
                                      imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                  }
                                                        completion:nil];
                              }];
    }
}

#pragma mark page control

- (void)changePage:(id)sender {
    [self.collectionView scrollToItemAtIndexPath:
     [NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = [(EBCardCollectionViewLayout *)_collectionView.collectionViewLayout currentPage];
    [self.pageControl setCurrentPage:index];
}

#pragma mark collection

static NSString * const reuseIdentifier = @"ToolCell";

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IJTToolPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [[cell.iconView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = self.iconImageViewArray[indexPath.row];
    [cell.iconView addSubview:imageView];
    cell.iconView.backgroundColor = [UIColor clearColor];
    
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.titleLabel.textColor = IJTBlockColor;
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.numberOfLines = 1;
    
    cell.pickButton.tag = indexPath.row;
    [cell.pickButton addTarget:self action:@selector(pickTool:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell layoutIfNeeded];
    
    [IJTFormatUILabel text:[NSString stringWithFormat:@"%ld", (long)indexPath.row + 1]
                     label:cell.numberLabel
                     color:IJTBlockColor
                      font:[UIFont fontWithName:@"OldLondon" size:30]];
    
    
    [IJTFormatUILabel sizeLabel:cell.numberLabel
                         toRect:cell.numberLabel.frame];
    
    cell.numberLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.layer.cornerRadius = 15;
    
    [cell layoutIfNeeded];
    return cell;
}

- (BOOL)shouldAutorotate {
    [_collectionView.collectionViewLayout invalidateLayout];
    
    return [super shouldAutorotate];
}

@end
