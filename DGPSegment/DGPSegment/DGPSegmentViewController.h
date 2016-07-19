//
//  DGPSegmentViewController.h
//  DGPSegment
//
//  Created by 戴国平 on 16/7/19.
//  Copyright © 2016年 dgp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGPSegmentViewController : UINavigationController <UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (nonatomic, strong) UIView *selectionBar;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) NSArray *buttonText;
@end
