//
//  ACParallaxTableViewController.m
//  ACParallaxTableViewController
//
//  Created by albert on 13-8-12.
//  Copyright (c) 2013年 albert. All rights reserved.
//

#import "ACParallaxTableViewController.h"

#import <QuartzCore/QuartzCore.h>


#define C_BG        \
[UIColor colorWithRed:(226 / 255.f) green:(239 / 255.f) blue:(255 / 255.f) alpha:1.f]

#define Window_Height       200.f
#define Image_Height        320.f


@interface ACParallaxTableViewController () <UITableViewDataSource, UITableViewDelegate>
{
    /** 图片头顶部背景 */
    UIImageView     *imageViewTopBG_;
    
    UIImageView     *imageView_;
    UIScrollView    *imageScroller_;
    UITableView     *tableView_;
    
    /** 导航栏 按钮 加号 图片 */
    UIImageView     *plusIV_;
    
    UIImageView     *refreshIV_;
    
    /** 是否正在刷新 */
    BOOL            refreshing_;
    
    /** 旋转定时器 */
    NSTimer         *timer_;
    
    /** 旋转弧度 */
    CGFloat         radian_;
}

@end


@implementation ACParallaxTableViewController

#pragma mark - Button Event Handlers

- (void)barLeftBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navPlusBtnTouchDown:(UIButton *)sender
{
    plusIV_.highlighted = YES;    
}

- (void)navPlusBtnPressed:(UIButton *)sender
{
    plusIV_.highlighted = NO;
    DLog(@"+ touch up inside");

}

- (void)navPlusBtnTouchUpOutSide:(UIButton *)sender
{
    plusIV_.highlighted = NO;
    DLog(@"out side");
}

- (void)theSomeButtonPressed:(UIButton *)sender
{
    DLog(@"\r\n o-{====> Twitter、Weibo @码农白腩肚");
}


#pragma mark - View lifecycle

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        imageScroller_  = [[UIScrollView alloc] initWithFrame:CGRectZero];
        imageScroller_.backgroundColor                  = C_BG;
        imageScroller_.showsHorizontalScrollIndicator   = NO;
        imageScroller_.showsVerticalScrollIndicator     = NO;
        
        imageView_ = [[UIImageView alloc] initWithImage:image];
        [imageScroller_ addSubview:imageView_];
        
        UIImage *topBGImg = PNGIMAGE(@"top_bg");
        imageViewTopBG_ = [[UIImageView alloc] initWithImage:topBGImg];
        [imageScroller_ addSubview:imageViewTopBG_];
        
        
        tableView_ = [[UITableView alloc] init];
        tableView_.backgroundColor              = [UIColor clearColor];
        tableView_.dataSource                   = self;
        tableView_.delegate                     = self;
        tableView_.separatorStyle               = UITableViewCellSeparatorStyleNone;
        tableView_.showsVerticalScrollIndicator = YES;
        
        [self.view addSubview:imageScroller_];
        [self.view addSubview:tableView_];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"视差表视图";
    
    //-- 返回按钮 -----------------------------------------------------------------------------------
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0.f, (44.f - 20.f) / 2.f, 40.f, 20.f)];
    [backBtn setBackgroundImage:IMAGE(@"nav_back", @"png") forState:UIControlStateNormal];
    
    backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    
    [backBtn addTarget:self action:@selector(barLeftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backBarItem;
    //---------------------------------------------------------------------------------------------;
    
    
    //** navBar rightButton ************************************************************************
    CGFloat navRightBtn_w = 40.f;
    CGFloat navRightBtn_h = 30.f;
    CGFloat navRightBtn_x = 320.f - 10.f;
    CGFloat navRightBtn_y = (44.f - navRightBtn_h) / 2.f;
    
    UIButton *navRightBtn = [[UIButton alloc] init];
    [navRightBtn setFrame:CGRectMake(navRightBtn_x,
                                     navRightBtn_y,
                                     navRightBtn_w,
                                     navRightBtn_h)];
    
    // 按钮背景图片
    UIImage *navRightBtnBGImg = PNGIMAGE(@"nav_item_empty");
    [navRightBtn setBackgroundImage:navRightBtnBGImg forState:UIControlStateNormal];
    
    
    //-- 按钮上的图片 --------------------------------------------------------------------------------
    CGFloat plusIV_w = 20.f;
    CGFloat plusIV_h = 20.f;
    CGFloat plusIV_x = (navRightBtn.bounds.size.width - plusIV_w) / 2.f;
    CGFloat plusIV_y = (navRightBtn.bounds.size.height - plusIV_h) / 2.f;
    
    // 加号图标
    plusIV_ = [[UIImageView alloc] init];
    [plusIV_ setFrame:CGRectMake(plusIV_x,
                                 plusIV_y,
                                 plusIV_w,
                                 plusIV_h)];
    
    [plusIV_ setImage:IMAGE(@"nav_plus", @"png")];
    
    [plusIV_ setHighlightedImage:IMAGE(@"nav_plus_highlighted", @"png")];
            
    [navRightBtn addSubview:plusIV_];
    
    
    // 刷新图标
    refreshIV_ = [[UIImageView alloc] initWithImage:IMAGE(@"nav_refresh", @"png")];
    [refreshIV_ setFrame:CGRectMake(plusIV_x,
                                 plusIV_y,
                                 plusIV_w,
                                 plusIV_h)];
        
    [navRightBtn addSubview:refreshIV_];
    refreshIV_.hidden = YES;
    
    //---------------------------------------------------------------------------------------------;
    
    
    // 设置按钮点击时调用的方法
    [navRightBtn addTarget:self action:@selector(navPlusBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    [navRightBtn addTarget:self action:@selector(navPlusBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navRightBtn addTarget:self action:@selector(navPlusBtnTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:navRightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    //*********************************************************************************************;
    
        
    radian_ = 0.f;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    imageScroller_.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    tableView_.backgroundView   = nil;
    tableView_.frame            = bounds;
    
    [self layoutImage];
    [self updateOffsets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Parallax effect

- (void)updateOffsets
{
    CGFloat yOffset   = tableView_.contentOffset.y;
    CGFloat threshold = Image_Height - Window_Height;
    
    if (yOffset > -threshold && yOffset < 0)
    {
        imageScroller_.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    }
    else if (yOffset < 0)
    {
        imageScroller_.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    }
    else
    {
        imageScroller_.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout

- (void)layoutImage
{
    CGFloat imageWidth   = imageScroller_.frame.size.width;
    CGFloat imageYOffset = floorf((Window_Height  - Image_Height) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    imageViewTopBG_.frame        = CGRectMake(imageXOffset, imageYOffset - Image_Height, 320.f, 320.f);
    
    imageView_.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, Image_Height);
    imageScroller_.contentSize   = CGSizeMake(imageWidth, self.view.bounds.size.height);
    imageScroller_.contentOffset = CGPointMake(0.0, 0.0);
}



#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 16;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return Window_Height;
    }
    else
    {
        return 70.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier   = @"ACParallaxTableViewCell";
    static NSString *windowReuseIdentifier = @"ACParallaxTableViewWindow";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
        if ( nil == cell )
        {
            cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:windowReuseIdentifier];
            
            cell.backgroundColor             = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle              = UITableViewCellSelectionStyleNone;
            
            //** 顶栏视图 ****************************************************************************
            //-- 头像 -------------------------------------------------------------------------------
            UIImage *avatarImage = IMAGE(@"guitar", @"png");
                        
            UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
            [avatarImageView sizeToFit];
            
            avatarImageView.layer.cornerRadius = avatarImage.size.width/2.0;
            
            avatarImageView.clipsToBounds = YES;
            avatarImageView.frame = CGRectMake(30, 120, avatarImageView.frame.size.width, avatarImageView.frame.size.height);
            
            // 边框
            avatarImageView.layer.borderWidth = 1.f;
            avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            
            [cell addSubview:avatarImageView];
            //-----------------------------------------------------------------------------------------;
            
            
            //-- Name -------------------------------------------------------------------------------
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont systemFontOfSize:16.f];
            
            
            NSString *nameStr = @"码农白腩肚";
            
            // 字符串显示的宽高
            CGSize lableSize = [nameStr sizeWithFont:[UIFont boldSystemFontOfSize:16.f]
                                   constrainedToSize:CGSizeMake(100.f, 20.f)
                                       lineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"lableSize%f", lableSize.width);
            [nameLabel setFrame:CGRectMake(95.f, 124.f, lableSize.width, 20.f)];
            
            nameLabel.text = nameStr;
            
            [cell addSubview:nameLabel];
            //-----------------------------------------------------------------------------------------;
            
            
            //-- sex -------------------------------------------------------------------------------
            UIImageView *sexIV = [[UIImageView alloc] init];
            
            UIImage *sexIcon = IMAGE(@"sex_male", @"png");
            
            [sexIV setImage:sexIcon];
            
            [sexIV setFrame:CGRectMake(lableSize.width + 105.f, 127.f, 14.f, 15.f)];
            
            [cell addSubview:sexIV];
            //-----------------------------------------------------------------------------------------;
            
            
            //-- some button -------------------------------------------------------------------------------
            UIButton *someButton =
            [[UIButton alloc] initWithFrame:CGRectMake(95.f,
                                                       146.f,
                                                       48.f,
                                                       20.f)];
            
            someButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
            
            [someButton setTitle:@"关注" forState:UIControlStateNormal];
            
            UIImage *someButtonBGI = IMAGE(@"btn_some", @"png");
            [someButton setBackgroundImage:someButtonBGI forState:UIControlStateNormal];
            
            [someButton addTarget:self action:@selector(theSomeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:someButton];
            //-----------------------------------------------------------------------------------------;
            
            
            //-- 阴影 -----------------------------------------------------------------------------
            cell.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
            cell.layer.shadowRadius = 2.0f;
            cell.layer.shadowOpacity = 0.8f;
            cell.layer.masksToBounds = NO;
            //-----------------------------------------------------------------------------------------;
                        
            //**************************************************************************************
            
        }
        // config
        
        
    }
    
    // 其他行
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if ( nil == cell )
        {
            cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellReuseIdentifier];
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            //cell.selectionStyle              = UITableViewCellSelectionStyleNone;
            
            
            //-- style -----------------------------------------------------------------------------
            // 设置单元背景图片
            UIImageView *imageView =
            [[UIImageView alloc] initWithImage:IMAGE(@"cell_bg", @"png")];
            
            cell.backgroundView = imageView;
            
            // 设置单元 选中时 背景图片
            UIImageView *imageView_selected =
            [[UIImageView alloc] initWithImage:IMAGE(@"cell_bg_selected", @"png")];

            cell.selectedBackgroundView = imageView_selected;
            
            cell.textLabel.highlightedTextColor = [UIColor grayColor];
            //-------------------------------------------------------------------------------------;
        }
        
        // config
        cell.textLabel.text = @"      Some Text";
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 6.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = C_BG;
        
        // 阴影
        CALayer *headerShadow = [[CALayer alloc] init];
        [headerShadow setFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
        headerShadow.backgroundColor = C_BG.CGColor;
        
        headerShadow.shadowColor = [UIColor grayColor].CGColor;
        headerShadow.shadowOpacity = 0.8f;
        headerShadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
        headerShadow.shadowRadius = 2.0f;
        headerShadow.masksToBounds = NO;
        
        [headerView.layer addSublayer:headerShadow];
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateOffsets];
    
    CGFloat move = scrollView.contentOffset.y;
    
    //DLog(@"%f", scrollView.contentOffset.y);
    
    if ( refreshing_ == NO )
    {
        if ( move >= 0 )
        {
            refreshIV_.hidden = YES;
            plusIV_.hidden = NO;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            refreshIV_.hidden = NO;
            plusIV_.hidden = YES;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
        refreshIV_.transform = CGAffineTransformMakeRotation(scrollView.contentOffset.y / 16.f);
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( refreshing_ == NO )
    {
        // 向下拖动距离大于 多少 像素，触发刷新事件
        if ( scrollView.contentOffset.y < -80.f )
        {
            DLog(@"滚动距离%f，触发下拉刷新", scrollView.contentOffset.y);
            
            [self begingRefresh];
        }
    }

}


#pragma mark - 下拉刷新

/** 开始刷新 */
- (void)begingRefresh
{
    plusIV_.hidden = YES;
    refreshIV_.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    refreshing_ = YES;
    
// 这样 会导致 scrollView 被拖动时，timer 事件停止，且第一次执行时会卡住直到 scrollViewDidEndDecelerating
//            timer_ =
//            [NSTimer scheduledTimerWithTimeInterval:0.01
//                                             target:self
//                                           selector:@selector(refreshMethod:)
//                                           userInfo:nil
//                                            repeats:YES];
    
    timer_ = [NSTimer timerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(refreshMethod:)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer_ forMode:NSRunLoopCommonModes];
    
    
    /** 四秒后结束 (模拟实际应用中加载完成) */
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self resetMethod];
        
    });

}

/** 转圈动画 */
- (void)refreshMethod:(NSTimer*)timer
{
    radian_ += 0.1f;
    
    refreshIV_.transform = CGAffineTransformMakeRotation(radian_);
    
}

/** 重置 */
- (void)resetMethod
{
    DLog(@"done");
    refreshing_ = NO;
    
    [timer_ invalidate];
    timer_ = nil;
    
    refreshIV_.hidden = YES;
    plusIV_.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    radian_ = 0.f;
}


@end
