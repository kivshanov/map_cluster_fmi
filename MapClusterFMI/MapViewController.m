//
//  MapViewController.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property BOOL isMenuOpen;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnnotations;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.isMenuOpen = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect rect = self.menu.frame;
        
        if (self.isMenuOpen) {
            rect.origin.y += 100.0f;
        } else {
            rect.origin.y -= 100.0f;
        }
        self.menu.frame = rect;
        self.isMenuOpen = !self.isMenuOpen;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender {
    
    if(sender.direction == UISwipeGestureRecognizerDirectionDown) {
        if (self.isMenuOpen) {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect rect = self.menu.frame;
                rect.origin.y += 100.0f;
                self.menu.frame = rect;
                self.isMenuOpen = !self.isMenuOpen;
                
            } completion:^(BOOL finished) {
                
            }];
        }
        
    } else if(sender.direction == UISwipeGestureRecognizerDirectionUp) {
        if (!self.isMenuOpen) {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect rect = self.menu.frame;
                rect.origin.y -= 100.0f;
                self.menu.frame = rect;
                self.isMenuOpen = !self.isMenuOpen;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

@end
