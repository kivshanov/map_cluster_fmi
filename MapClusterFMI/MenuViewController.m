//
//  ViewController.m
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 12/16/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MenuViewController.h"
#import "MapViewController.h"
#import "CoreDataManager.h"
#import "MapObject.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (IBAction)menuTapped:(UIButton *)sender {
    MapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    vc.selectedType = sender.tag;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.button1.frame = CGRectMake(-320, self.button1.frame.origin.y, self.button1.frame.size.width, self.button1.frame.size.height);
                         self.button2.frame = CGRectMake(-320, self.button2.frame.origin.y, self.button2.frame.size.width, self.button2.frame.size.height);
                         self.button3.frame = CGRectMake(-320, self.button3.frame.origin.y, self.button3.frame.size.width, self.button3.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         
                         [self presentViewController:vc animated:NO completion:^{
                             //
                         }];
                         
                     }];
}
static inline NSInteger random_between(NSInteger min, NSInteger max) {
    return min + arc4random() % ((max+1) - min);
}

- (void)downlaodPlaces {
    FMIRequest *request = [[FMIRequest alloc] init];
    request.method = @"GET";
    request.requestName = COFFES;
    request.getParams = @{@"client_id":@"JAC4GBJU5MHR1RTC01FASQBJ0TSWYFC0C1TSC3135ROCFWS1",
                          @"client_secret":@"3SCM2YPDKY4VVQ1YHPG1SCAEIYGT35HXCAO33OW3U0VW0XMH",
                          @"v":@"20130815",
                          @"ll":@"42.66,23.33",
                          @"query":@"coffee",
                          @"radius":@10000,
                          @"limit":@500,
                          @"intent":@"browse"};
    request.postParams = nil;
    request.delegate = self;
    [request send];
    

}

- (void)request:(enum FMI_Request)name didReceiveData:(id)response {
    
    if(name == COFFES) {
        NSArray *arr = [[response objectForKey:@"response"] objectForKey:@"venues"];
        NSManagedObjectContext *context = [CoreDataManager instance].managedObjectContext;
        int i = 0;
        for(NSDictionary *dict in arr) {
            MapObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"MapObject" inManagedObjectContext:context];
            object.latitude = [[dict objectForKey:@"location"] objectForKey:@"lat"];
            object.longtitude = [[dict objectForKey:@"location"] objectForKey:@"lng"];
            object.name = [dict objectForKey:@"name"];
            object.index = @(i);
            i++;
            
            // TODO: change it
            object.type = @0;
        }
        [[CoreDataManager instance] saveContext];
        
        //after we got the coffes send for parks
        FMIRequest *request2 = [[FMIRequest alloc] init];
        request2.method = @"GET";
        request2.requestName = PARKS;
        request2.getParams = @{@"client_id":@"JAC4GBJU5MHR1RTC01FASQBJ0TSWYFC0C1TSC3135ROCFWS1",
                               @"client_secret":@"3SCM2YPDKY4VVQ1YHPG1SCAEIYGT35HXCAO33OW3U0VW0XMH",
                               @"v":@"20130815",
                               @"ll":@"42.66,23.33",
                               @"query":@"park",
                               @"radius":@10000,
                               @"limit":@500,
                               @"intent":@"browse"};
        request2.postParams = nil;
        request2.delegate = self;
        [request2 send];
        
        
    }
    else if (name == PARKS) {
        NSArray *arr = [[response objectForKey:@"response"] objectForKey:@"venues"];
        NSManagedObjectContext *context = [CoreDataManager instance].managedObjectContext;
        int i = 0;
        for(NSDictionary *dict in arr) {
            MapObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"MapObject" inManagedObjectContext:context];
            object.latitude = [[dict objectForKey:@"location"] objectForKey:@"lat"];
            object.longtitude = [[dict objectForKey:@"location"] objectForKey:@"lng"];
            object.name = [dict objectForKey:@"name"];
            object.index = @(i);
            i++;
            
            // TODO: change it
            object.type = @1;
        }
        [[CoreDataManager instance] saveContext];
        
        //after we got the coffes send for parks
        FMIRequest *request2 = [[FMIRequest alloc] init];
        request2.method = @"GET";
        request2.requestName = RESTAURANTS;
        request2.getParams = @{@"client_id":@"JAC4GBJU5MHR1RTC01FASQBJ0TSWYFC0C1TSC3135ROCFWS1",
                               @"client_secret":@"3SCM2YPDKY4VVQ1YHPG1SCAEIYGT35HXCAO33OW3U0VW0XMH",
                               @"v":@"20130815",
                               @"ll":@"42.66,23.33",
                               @"query":@"restaurant",
                               @"radius":@10000,
                               @"limit":@500,
                               @"intent":@"browse"};
        request2.postParams = nil;
        request2.delegate = self;
        [request2 send];
        
    }
    else if (name == RESTAURANTS) {
        NSArray *arr = [[response objectForKey:@"response"] objectForKey:@"venues"];
        NSManagedObjectContext *context = [CoreDataManager instance].managedObjectContext;
        int i = 0;
        for(NSDictionary *dict in arr) {
            MapObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"MapObject" inManagedObjectContext:context];
            object.latitude = [[dict objectForKey:@"location"] objectForKey:@"lat"];
            object.longtitude = [[dict objectForKey:@"location"] objectForKey:@"lng"];
            object.name = [dict objectForKey:@"name"];
            object.index = @(i);
            i++;
            
            // TODO: change it
            object.type = @2;
        }
        [[CoreDataManager instance] saveContext];
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(isWithReal) {
        [self downlaodPlaces];
    }
    else {
        [MapObject insertCoordinatesinDB];
    }
    // ili random ili ot forsquare
    
    //[MapObject insertCoordinatesinDB]; tova e random
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gr];
    [CoreDataManager instance];
    
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
