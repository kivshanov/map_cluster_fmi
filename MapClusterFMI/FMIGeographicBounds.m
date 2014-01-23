//
// FMIGeographicBounds
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "FMIGeographicBounds.h"

@implementation FMIGeographicBounds


- (void)setSouthWest:(CLLocationCoordinate2D)sw northEast:(CLLocationCoordinate2D)ne
{
    _southWest = sw;
    _northEast = ne;
    _southEast = CLLocationCoordinate2DMake(sw.latitude, ne.longitude);
    _northWest = CLLocationCoordinate2DMake(ne.latitude, sw.longitude);
}

- (id)initWithMapView:(MKMapView *)mapView
{
    if ((self = [super init])) {
        _mapView = mapView;
    }
    return self;
}


- (bool)contains:(CLLocationCoordinate2D)coordinate
{
    CGPoint point = [_mapView convertCoordinate:coordinate toPointToView:_mapView];
    CGPoint topLeft = [_mapView convertCoordinate:_northWest toPointToView:_mapView];
    CGPoint bottomRight = [_mapView convertCoordinate:_southEast toPointToView:_mapView];
    CGPoint topRight = [_mapView convertCoordinate:_northEast toPointToView:_mapView];
    
    if (point.x >= topLeft.x && point.x <= topRight.x)
        if (point.y >= topLeft.y && point.y <= bottomRight.y)
            return YES;
    
    return NO;
}

- (void)setExtendedBounds:(NSInteger)gridSize
{
    CLLocationCoordinate2D tr = CLLocationCoordinate2DMake(_northEast.latitude, _northEast.longitude);
    CLLocationCoordinate2D bl = CLLocationCoordinate2DMake(_southWest.latitude, _southWest.longitude);
    
    CGPoint trPix = [_mapView convertCoordinate:tr toPointToView:_mapView];
    trPix.x += gridSize;
    trPix.y -= gridSize;
    
    CGPoint blPix = [_mapView convertCoordinate:bl toPointToView:_mapView];
    blPix.x -= gridSize;
    blPix.y += gridSize;
    
    CLLocationCoordinate2D ne = [_mapView convertPoint:trPix toCoordinateFromView:_mapView];
    CLLocationCoordinate2D sw = [_mapView convertPoint:blPix toCoordinateFromView:_mapView];
    
    _northEast = ne;
    _southWest = sw;
    _southEast = CLLocationCoordinate2DMake(sw.latitude, ne.longitude);
    _northWest = CLLocationCoordinate2DMake(ne.latitude, sw.longitude);
}



@end
