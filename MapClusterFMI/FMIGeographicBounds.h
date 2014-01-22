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

@property (assign, readwrite, nonatomic) CLLocationCoordinate2D northEast;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D northWest;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D southWest;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D southEast;
@property (weak, readwrite, nonatomic) MKMapView *mapView;

- (id)initWithMapView:(MKMapView *)mapView;
- (void)setSouthWest:(CLLocationCoordinate2D)sw northEast:(CLLocationCoordinate2D)ne;
- (void)setExtendedBounds:(NSInteger)gridSize;
- (bool)contains:(CLLocationCoordinate2D)coordinate;

@end
