//
// FMIGeographicBounds
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "FMIGeographicBounds.h"

@implementation FMIGeographicBounds

- (void)setBottomLeft:(CLLocationCoordinate2D)bl upRight:(CLLocationCoordinate2D)tr
{
    _bottomLeft = bl;
    _topRight = tr;
    _bottomRight = CLLocationCoordinate2DMake(bl.latitude, tr.longitude);
    _topLeft = CLLocationCoordinate2DMake(tr.latitude, bl.longitude);
}

- (id)initManagerWithMapView:(MKMapView *)mapView
{
    if ((self = [super init])) {
        _mapView = mapView;
    }
    return self;
}


- (bool)contains:(CLLocationCoordinate2D)coordinate
{
    CGPoint point = [_mapView convertCoordinate:coordinate toPointToView:_mapView];
    CGPoint topLeft = [_mapView convertCoordinate:_topLeft toPointToView:_mapView];
    CGPoint bottomRight = [_mapView convertCoordinate:_bottomRight toPointToView:_mapView];
    CGPoint topRight = [_mapView convertCoordinate:_topRight toPointToView:_mapView];
    
    if (point.x >= topLeft.x && point.x <= topRight.x)
        if (point.y >= topLeft.y && point.y <= bottomRight.y)
            return YES;
    
    return NO;
}

- (void)setExtendedBounds:(NSInteger)gridSize
{
    CLLocationCoordinate2D tr = CLLocationCoordinate2DMake(_topRight.latitude, _topRight.longitude);
    CLLocationCoordinate2D bl = CLLocationCoordinate2DMake(_bottomLeft.latitude, _bottomLeft.longitude);
    
    CGPoint trPix = [_mapView convertCoordinate:tr toPointToView:_mapView];
    trPix.x += gridSize;
    trPix.y -= gridSize;
    
    CGPoint blPix = [_mapView convertCoordinate:bl toPointToView:_mapView];
    blPix.x -= gridSize;
    blPix.y += gridSize;
    
    CLLocationCoordinate2D tr2 = [_mapView convertPoint:trPix toCoordinateFromView:_mapView];
    CLLocationCoordinate2D bl2 = [_mapView convertPoint:blPix toCoordinateFromView:_mapView];
    
    _topRight = tr;
    _bottomLeft = bl;
    _bottomRight = CLLocationCoordinate2DMake(bl2.latitude, tr2.longitude);
    _topLeft = CLLocationCoordinate2DMake(tr2.latitude, bl2.longitude);
}



@end
