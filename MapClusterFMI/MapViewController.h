//
//  MapViewController.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *menu;
@property (nonatomic) NSInteger selectedType;

@end
