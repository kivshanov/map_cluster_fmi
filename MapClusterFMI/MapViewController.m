//
//  MapViewController.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MapViewController.h"
#import "SingleAnnotation.h"
#import "Algorithms.h"
#import "PinAnnotation.h"
#import "MapObject.h"

@interface MapViewController () {
    NSInteger shownItems;
}
@property BOOL isMenuOpen;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnnotations;
@property (strong, nonatomic) NSString *placeType;
@property (strong, nonatomic) NSArray *allTypes;
@end

static CGFloat kDEFAULTCLUSTERSIZE = 0.2;

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

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(shownItems < 1) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        [mapView setRegion:mapRegion animated: YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    shownItems = 0;
    self.mapView.delegate = self;
    self.isMenuOpen = YES;
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    self.numberOfAnnotations.text = @"0";
    self.allTypes = [NSArray arrayWithObjects:@"Park", @"Restaurant", @"Cafe", nil];
    self.placeType = [self.allTypes objectAtIndex:self.selectedType];
    
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

- (IBAction)tapAction:(UITapGestureRecognizer *)sender
{
    
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

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender
{
    
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



- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    // if it's a cluster
    if ([annotation isKindOfClass:[PinAnnotation class]]) {
        
        PinAnnotation *clusterAnnotation = (PinAnnotation *)annotation;
        
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        //calculate cluster region
        CLLocationDistance clusterRadius = self.mapView.region.span.longitudeDelta * self.mapView.clusterSize * 111000 / 2.0f; //static circle size of cluster
//        CLLocationDistance clusterRadius = self.mapView.region.span.longitudeDelta/log(self.mapView.region.span.longitudeDelta*self.mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * self.mapView.clusterSize * 50000; //circle size based on number of annotations in cluster
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [self.mapView addOverlay:circle];
        
        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circleLine setTitle:@"line"];
        [self.mapView addOverlay:circleLine];
        
        // set title
        clusterAnnotation.title = @"Cluster";
        clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %d", (int)[clusterAnnotation.annotationsInCluster count]];
        
        // set its image
        annotationView.image = [UIImage imageNamed:@"regular.png"];
        
        // change pin image for group
        if (self.mapView.makeGroups) {
            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@s.png", clusterAnnotation.groupTag]];
            clusterAnnotation.title = [NSString stringWithFormat:@"%@s", clusterAnnotation.groupTag];
        }
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[SingleAnnotation class]]){
        SingleAnnotation *singleAnnotation = (SingleAnnotation *)annotation;
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"singleAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:@"singleAnnotationView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        singleAnnotation.title = singleAnnotation.groupTag;
        annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", singleAnnotation.groupTag]];
    }
    // Error
    else{
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [UIColor redColor];
        circleView.alpha = 0.25;
    } else
    {
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 0.8;
    }
    
    return circleView;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView divideElementsIntoClusters];
}



// ==============================
#pragma mark - UI actions

- (IBAction)addButton:(id)sender
{
    shownItems +=20;
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomMapObjectsFromDB:shownItems]];
    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
    
    for (CLLocation *loc in randomLocations) {
        SingleAnnotation *annotation = [[SingleAnnotation alloc] initWithCoordinate:loc.coordinate];
        [annotationsToAdd addObject:annotation];
        
        // add to group if specified
        annotation.groupTag = self.placeType;
        
    }
    
    [self.mapView addAnnotations:[annotationsToAdd allObjects]];
    self.numberOfAnnotations.text = [NSString stringWithFormat:@"%d", (int)[self.mapView.annotations count]];
}

- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.mapView.clusterMethodType == ClusteringBubbleMethod) {
        [sender setTitle:@"Bubble cluster" forState:UIControlStateNormal];
        self.mapView.clusterMethodType = ClusteringGridMethod;
    }
    else{
        [sender setTitle:@"Grid cluster" forState:UIControlStateNormal];
        self.mapView.clusterMethodType = ClusteringBubbleMethod;
    }
    [self.mapView divideElementsIntoClusters];
}

- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.mapView.enableClustering) {
        [sender setTitle:@"Turn clustering on" forState:UIControlStateNormal];
        self.mapView.enableClustering = NO;
    }
    else{
        [sender setTitle:@"Turn clustering off" forState:UIControlStateNormal];
        self.mapView.enableClustering = YES;
    }
    [self.mapView divideElementsIntoClusters];
}

- (IBAction)removeButton:(id)sender
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.numberOfAnnotations.text = @"0";
}

- (IBAction)buttonGroup:(UIButton *)sender
{
    self.mapView.makeGroups = ! self.mapView.makeGroups;
    if(self.mapView.makeGroups){
        [sender setTitle:@"Turn groups off" forState:UIControlStateNormal];
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE * 2.0;
    }
    else{
        [sender setTitle:@"Turn groups on" forState:UIControlStateNormal];
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView divideElementsIntoClusters];
}

- (IBAction)changeGroup:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select another group:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"City Parks",
                            @"Restaurants",
                            @"Cafes",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];

}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < self.allTypes.count) {
        self.placeType = [self.allTypes objectAtIndex:buttonIndex];
    }
    
}

- (NSArray *)randomMapObjectsFromDB:(NSInteger)count
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *objects = [MapObject getObjectsForMaxIndex:count];
    
    for(MapObject *object in objects) {
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:object.latitude.floatValue longitude:object.longtitude.floatValue];
        [result addObject:loc];
    }

    return  result;
}

@end
