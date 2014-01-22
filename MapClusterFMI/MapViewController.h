//
//  MapViewController.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "REMarkerClusterer.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, REMarkerClusterDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *menu;
@property (nonatomic) NSInteger selectedType;
@property (strong, readonly, nonatomic) REMarkerClusterer *clusterer;

@end
