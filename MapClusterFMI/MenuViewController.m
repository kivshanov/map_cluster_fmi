//
//  ViewController.m
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 12/16/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MenuViewController.h"
#import "ObjectChoiceViewController.h"
#import "MapViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (IBAction)menuTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            NSLog(@"parks");
            break;
        case 1:
            NSLog(@"restaurants");
            break;
        case 2:
            NSLog(@"cafes");
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.button1.frame = CGRectMake(-320, self.button1.frame.origin.y, self.button1.frame.size.width, self.button1.frame.size.height);
                         self.button2.frame = CGRectMake(-320, self.button2.frame.origin.y, self.button2.frame.size.width, self.button2.frame.size.height);
                         self.button3.frame = CGRectMake(-320, self.button3.frame.origin.y, self.button3.frame.size.width, self.button3.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         MapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
                         [self presentViewController:vc animated:NO completion:^{
                             //
                         }];
                         
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gr];
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

- (void)showObjectOption {
    [UIView animateWithDuration:0.8
                     animations:^{
                         self.button1.alpha = 1.0;
                         self.button2.alpha = 1.0;
                         self.button3.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.swipeImg.alpha = 0.0;
}


- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender {
    NSLog(@"swipe");
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if(!self.logoImg.hidden) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.logoImg.frame = CGRectMake(-320, self.logoImg.frame.origin.y, self.logoImg.frame.size.width, self.logoImg.frame.size.height);
                             }
                             completion:^(BOOL finished) {
                                 self.logoImg.hidden = YES;
                                 [self showObjectOption];
                             }];
        }
    }
}

@end
