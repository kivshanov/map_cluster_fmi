//
//  ViewController.h
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 12/16/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

@property (nonatomic , weak) IBOutlet UIImageView *logoImg;
@property (nonatomic , weak) IBOutlet UIImageView *swipeImg;
@property (nonatomic , weak) IBOutlet UIButton *button1;
@property (nonatomic , weak) IBOutlet UIButton *button2;
@property (nonatomic , weak) IBOutlet UIButton *button3;

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender;
- (IBAction)menuTapped:(UIButton *)sender;

@end
