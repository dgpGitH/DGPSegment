//
//  DGPSegmentViewController.m
//  DGPSegment
//
//  Created by 戴国平 on 16/7/19.
//  Copyright © 2016年 dgp. All rights reserved.
//

#import "DGPSegmentViewController.h"

CGFloat X_Buffer = 0.0;
CGFloat Y_Buffer = 14.0;
CGFloat SegHeight = 30.0;
CGFloat Bounce_Buffer = 10.0;
CGFloat Animation_Speed = 0.2;
CGFloat Selector_Y_Buffer = 42.0;
CGFloat Selector_Height = 2.0;
CGFloat X_Offset = 8.0;

@interface DGPSegmentViewController ()

@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) BOOL isPageScrollingFlag;
@property (nonatomic, assign) BOOL hasAppearedFlag;
@end

@implementation DGPSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:0.01 green:0.05 blue:0.06 alpha:1];
    self.navigationBar.translucent = NO;
    _viewControllerArray = [[NSMutableArray alloc] init];
    self.currentPageIndex = 0;
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //    return UIStatusBarStyleDefault;
}

- (void)setupSegmentButtons {
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height)];
    NSInteger numControllers = [_viewControllerArray count];
    if(!_buttonText) {
        _buttonText = [[NSArray alloc] initWithObjects:@"菜单1",@"菜单2",@"菜单3",@"菜单4",nil];
    }
    for (int i = 0; i<numControllers; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(X_Buffer+i*(self.view.frame.size.width - 2*X_Buffer)/numControllers - X_Offset, Y_Buffer, (self.view.frame.size.width - 2*X_Buffer)/numControllers, SegHeight)];
        [_navigationView addSubview:button];
        button.tag = i;
        button.backgroundColor = [UIColor colorWithRed:0.03 green:0.07 blue:0.08 alpha:1];
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[_buttonText objectAtIndex:i] forState:UIControlStateNormal];
    }
    _pageController.navigationController.navigationBar.topItem.titleView = _navigationView;
    [self setupSelector];
}

- (void)setupSelector {
    _selectionBar = [[UIView alloc] initWithFrame:CGRectMake(X_Buffer-X_Offset, Selector_Y_Buffer, (self.view.frame.size.width - 2*X_Buffer)/[_viewControllerArray count], Selector_Height)];
    _selectionBar.backgroundColor = [UIColor greenColor];
    _selectionBar.alpha = 0.8;
    [_navigationView addSubview:_selectionBar];
}

#pragma  mark Setup

- (void)viewWillAppear:(BOOL)animated {
    if (!_hasAppearedFlag) {
        [self setupPageViewController];
        [self setupSegmentButtons];
        _hasAppearedFlag = YES;
    }
}

- (void)setupPageViewController {
    _pageController = (UIPageViewController*)self.topViewController;
    _pageController.delegate = self;
    _pageController.dataSource = self;
    [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

-(void)syncScrollView {
    for (UIView *view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

- (void)tapSegmentButtonAction:(UIButton *)button {
    if (!_isPageScrollingFlag) {
        NSInteger temIndex = self.currentPageIndex;
        __weak typeof(self) weakSelf = self;
        
        if (button.tag > temIndex) {
            for (int i = (int)temIndex+1; i<=button.tag; i++) {
                [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
        else if (button.tag < temIndex) {
            for (int i = (int)temIndex-1; i >= button.tag; i--) {
                [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
}
- (void)updateCurrentPageIndex:(int)newIndex {
    self.currentPageIndex = newIndex;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xFromCenter = self.view.frame.size.width - scrollView.contentOffset.x;
    NSInteger xCoor = X_Buffer + _selectionBar.frame.size.width * self.currentPageIndex - X_Offset;
    _selectionBar.frame = CGRectMake(xCoor-xFromCenter/[_viewControllerArray count], _selectionBar.frame.origin.y, _selectionBar.frame.size.width, _selectionBar.frame.size.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pageViewController

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_viewControllerArray indexOfObject:viewController];
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    index--;
    return [_viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [_viewControllerArray indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [_viewControllerArray count]) {
        return nil;
    }
    return [_viewControllerArray objectAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentPageIndex = [_viewControllerArray indexOfObject:[pageViewController.viewControllers lastObject]];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
}


@end
