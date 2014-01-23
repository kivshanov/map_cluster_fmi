//
// FMIGeographicBounds
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocation.h>

@interface FMIGeographicBounds : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D topRight;
@property (nonatomic, assign) CLLocationCoordinate2D topLeft;
@property (nonatomic, assign) CLLocationCoordinate2D bottomLeft;
@property (nonatomic, assign) CLLocationCoordinate2D bottomRight;
@property (nonatomic, weak) MKMapView *mapView;

- (id)initManagerWithMapView:(MKMapView *)mapView;
- (void)setBottomLeft:(CLLocationCoordinate2D)bl upRight:(CLLocationCoordinate2D)tr;
- (void)setExtendedBounds:(NSInteger)gridSize;
- (bool)contains:(CLLocationCoordinate2D)coordinate;

@end
