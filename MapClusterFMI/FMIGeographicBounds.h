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

@property (assign, readwrite, nonatomic) CLLocationCoordinate2D topRight;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D topLeft;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D bottomLeft;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D bottomRight;
@property (weak, readwrite, nonatomic) MKMapView *mapView;

- (id)initBoundsWithMapView:(MKMapView *)mapView;
- (void)setBottomLeft:(CLLocationCoordinate2D)bl topRight:(CLLocationCoordinate2D)tr;
- (void)setExtendedBounds:(NSInteger)gridSize;
- (bool)contains:(CLLocationCoordinate2D)coordinate;

@end
