//
//  ViewController.m
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 12/16/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [self animateSwipeAction];
}

- (void)animateSwipeAction {
    CAKeyframeAnimation *animatePosition = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animatePosition.values = @[@245,@45];
    animatePosition.duration = 1.0;
    animatePosition.autoreverses = NO;
    animatePosition.delegate = self;
    animatePosition.repeatCount = 1;
    [self.swipeImg.layer addAnimation:animatePosition forKey:@"position.x"];
    
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.swipeImg.alpha = 0.0;
}

@end
