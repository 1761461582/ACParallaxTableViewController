//
//  ViewController.m
//  ACParallaxTableViewController
//
//  Created by albert on 13-8-12.
//  Copyright (c) 2013年 albert. All rights reserved.
//

#import "ViewController.h"

#import "ACParallaxTableViewController.h"


@interface ViewController ()

@end


@implementation ViewController

- (IBAction)goBtnPressed:(id)sender
{
    // Creat VC
    UIImage *topImage = [UIImage imageNamed:@"cover_02"];
    ACParallaxTableViewController *nextVC = [[ACParallaxTableViewController alloc] initWithImage:topImage];
    
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:nextVC];
    

    UIImage *navBarBgImg = [IMAGE(@"nav_bar", @"png") stretchableImageWithLeftCapWidth:5.f topCapHeight:22.f];
    [nc.navigationBar setBackgroundImage:navBarBgImg forBarMetrics:UIBarMetricsDefault];
    
    nc.navigationBar.tintColor = [UIColor  blackColor];
    nc.navigationBar.translucent = YES;
//    nc.navigationBar.alpha = 0.5f;
    
    nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
