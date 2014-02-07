//
//  MapViewController.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "MapViewController.h"
#import "MapObject.h"

@interface MapViewController () {
    NSInteger shownItems;
}
@property BOOL isMenuOpen;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnnotations;
@property (strong, nonatomic) NSArray *allTypes;
@property (strong, readwrite, nonatomic) FMIClusterManager *clusterer;

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
    self.numberOfAnnotations.text = @"0";
    self.allTypes = [NSArray arrayWithObjects:@"Park", @"Restaurant", @"Cafe", nil];
    
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
    
    
    // Create clusterer, assign a map view and delegate (MKMapViewDelegate)
    self.clusterer = [[FMIClusterManager alloc] initWithMapView:self.mapView delegate:self];
    
    // Set smaller grid size for an iPad
    self.clusterer.size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 25 : 20;
    self.clusterer.clusterName = @"%i items";
    
    shownItems +=20;
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomMapObjectsFromDB:shownItems]];
    
    for (MapObject *object in randomLocations) {
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:object.latitude.floatValue longitude:object.longtitude.floatValue];
        
        FMISingleMapObject *singleObject = [[FMISingleMapObject alloc] init];
        singleObject.coordinate = loc.coordinate;
        
        singleObject.title = [NSString stringWithFormat:@"%@", [self.allTypes objectAtIndex:[object.type intValue]]];
//        singleObject.title = [NSString stringWithFormat:@"%@", self.placeType];
        
        singleObject.type = [NSNumber numberWithInt:[object.type intValue]];
        
        [self.clusterer addSingleObject:singleObject];
        
    }

    self.numberOfAnnotations.text = [NSString stringWithFormat:@"%d", (int)randomLocations.count];
    

    // Create clusters (without animations on view load)
    [self.clusterer doClustering:NO];
    
    // Zoom to show all clusters/singleObjects on the map
    [self.clusterer zoomToAnnotationsBounds:self.clusterer.singleObjects];
    
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
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

#pragma mark - MKMapView methods 
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(FMIClusterObject *)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *pinID;
    static NSString *defaultPinID = @"REDefaultPin";
    pinID = defaultPinID;

    
	MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    
	if (pinView == nil) {
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
        pinView.canShowCallout = YES;
    }
    
    pinView.image = [UIImage imageNamed:annotation.singleObjects.count == 1 ? [NSString stringWithFormat:@"%@.png", [self.allTypes objectAtIndex:[annotation.type intValue]]] : [NSString stringWithFormat:@"%@s.png", [self.allTypes objectAtIndex:[annotation.type intValue]]]];
//    pinView.image = [UIImage imageNamed:annotation.singleObjects.count == 1 ? [NSString stringWithFormat:@"%@.png", self.placeType] : [NSString stringWithFormat:@"%@s.png", self.placeType]];
    
    return pinView;
}


// ==============================
#pragma mark - UI actions

- (IBAction)addButton:(id)sender
{
    if(isWithReal && shownItems > 50) {
        return;
    }
    shownItems +=20;
    
//    [self.mapView removeOverlays:self.mapView.overlays];
    
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomMapObjectsFromDB:shownItems]];
    
    for (MapObject *object in randomLocations) {
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:object.latitude.floatValue longitude:object.longtitude.floatValue];
        
        FMISingleMapObject *singleObject = [[FMISingleMapObject alloc] init];
        singleObject.coordinate = loc.coordinate;
        
//        singleObject.title = [NSString stringWithFormat:@"%@", self.placeType];
        singleObject.title = [NSString stringWithFormat:@"%@", [self.allTypes objectAtIndex:[object.type intValue]]];
        
        singleObject.type = [NSNumber numberWithInt:[object.type intValue]];
        
        [self.clusterer addSingleObject:singleObject];
        
    }
    
    self.numberOfAnnotations.text = [NSString stringWithFormat:@"%d",(int) shownItems];
    
    // Zoom to show all clusters/singleObjects on the map
    [self.clusterer doClustering:YES];
    [self.clusterer zoomToAnnotationsBounds:self.clusterer.singleObjects];
}

- (IBAction)removeButton:(id)sender
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.clusterer removeAllSingleObjects];
    shownItems = 0;
    self.numberOfAnnotations.text = @"0";
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
        self.selectedType = buttonIndex;
    }
}


// TODO: fetch objects from self.selectedType type
- (NSArray *)randomMapObjectsFromDB:(NSInteger)count
{

        return  [MapObject getObjectsForMaxIndex:count andType:self.selectedType];

    
}

@end
