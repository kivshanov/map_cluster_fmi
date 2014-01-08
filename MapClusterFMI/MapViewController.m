//
//  MapViewController.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MapViewController.h"
#import "SingleAnnotation.h"

@interface MapViewController ()
@property BOOL isMenuOpen;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnnotations;
@end

static NSString *const kTYPE1 = @"test1";
static NSString *const kTYPE2 = @"test2";
static int kMax = 2147483647;

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.isMenuOpen = YES;
    self.numberOfAnnotations.text = @"0";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        for (UIButton *button in self.view.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
            }
        }
        [self.view performSelector:@selector(setTintColor:) withObject:[UIColor cyanColor]];
        self.mapView.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
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






// ==============================
#pragma mark - UI actions

- (IBAction)addButtonTouchUpInside:(id)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:100]];
    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
    
    for (CLLocation *loc in randomLocations) {
        SingleAnnotation *annotation = [[SingleAnnotation alloc] initWithCoordinate:loc.coordinate];
        [annotationsToAdd addObject:annotation];
        
        // add to group if specified
        if (annotationsToAdd.count < (randomLocations.count)/2) {
            annotation.groupTag = kTYPE1;
        }
        else{
            annotation.groupTag = kTYPE2;
        }
        
    }
    
    [self.mapView addAnnotations:[annotationsToAdd allObjects]];
    self.numberOfAnnotations.text = [NSString stringWithFormat:@"%lu", [self.mapView.annotations count]];
}


- (NSArray *)randomCoordinatesGenerator:(int) numberOfCoordinates
{
    MKCoordinateRegion visibleRegion = self.mapView.region;
    visibleRegion.span.latitudeDelta *= 0.8;
    visibleRegion.span.longitudeDelta *= 0.8;
    
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = visibleRegion.center.longitude - visibleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = visibleRegion.center.latitude + visibleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        longitude += (arc4random()%kMax)/(CGFloat)kMax * visibleRegion.span.longitudeDelta;
        latitude  -= (arc4random()%kMax)/(CGFloat)kMax * visibleRegion.span.latitudeDelta;
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}

@end
