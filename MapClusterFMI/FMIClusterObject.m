//
//  FMIClusterObject.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "FMIClusterObject.h"
#import "FMIClusterManager.h"

@interface FMIClusterObject ()

@property (strong, readwrite, nonatomic) NSString *coordinateTag;

@end

@implementation FMIClusterObject

- (id)initWithClusterer:(FMIClusterManager *)clusterer
{
    if ((self = [super init])) {
        self.markerClusterer = clusterer;
        self.averageCenter = [clusterer isAverageCenter];
        self.markers = [[NSMutableArray alloc] init];
        self.hasCenter = NO;
        self.bounds = [[FMIGeographicBounds alloc] initBoundsWithMapView:self.markerClusterer.mapView];
    }
    return self;
}

- (BOOL)addMarker:(id<FMISingleMapObject>)marker
{ 
    if ([self isMarkerAlreadyAdded:marker])
        return NO;
    
    if (!self.hasCenter) {
        self.coordinate = marker.coordinate;
        self.coordinateTag = [NSString stringWithFormat:@"%f%f", self.coordinate.latitude, self.coordinate.longitude];
        self.hasCenter = YES;
        [self calculateBounds];
    } else {
        if (self.averageCenter && self.markers.count >= 2) {
            CGFloat l = self.markers.count + 1;
            CGFloat lat = (self.coordinate.latitude * (l - 1) + marker.coordinate.latitude) / l;
            CGFloat lng = (self.coordinate.longitude * (l - 1) + marker.coordinate.longitude) / l;
            self.coordinate = CLLocationCoordinate2DMake(lat, lng);
            self.coordinateTag = [NSString stringWithFormat:@"%f%f", self.coordinate.latitude, self.coordinate.longitude];
            self.hasCenter = YES;
            [self calculateBounds];
        }
    }
    [self.markers addObject:marker];
    
    if (self.markers.count == 1){
        self.title = ((id<FMISingleMapObject>)self.markers.lastObject).title;
//        self.subtitle = ((id<FMISingleMapObject>)self.markers.lastObject).title;
        self.type = [NSNumber numberWithInt:[((FMISingleMapObject *)self.markers.lastObject).type intValue]];
    } else{
        self.title = [NSString stringWithFormat:self.markerClusterer.clusterTitle, self.markers.count];
        self.type = [NSNumber numberWithInt:[((FMISingleMapObject *)self.markers.lastObject).type intValue]];
//        self.subtitle = @"";
    }
    
    return YES;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;

    if (self.markers.count == 1) {
        FMISingleMapObject *marker = self.markers.lastObject;
        marker.coordinate = coordinate;
    }
}

- (void)calculateBounds
{
    [self.bounds setBottomLeft:self.coordinate topRight:self.coordinate];
    [self.bounds setExtendedBounds:self.markerClusterer.gridSize];
}

- (BOOL)isMarkerInClusterBounds:(id<FMISingleMapObject>)marker
{
    return [self.bounds contains:marker.coordinate];
}

- (NSInteger)markersInClusterFromMarkers:(NSArray *) markers
{
    NSInteger result = 0;
    for (id<FMISingleMapObject>marker in markers) {
        if ([self isMarkerAlreadyAdded:marker])
            result++;
    }
    return result;
}

- (BOOL)isMarkerAlreadyAdded:(id<FMISingleMapObject>)marker
{
    for (id<FMISingleMapObject>m in self.markers) {
        if ([m isEqual:marker])
            return YES;
    }
    return NO;
}

@end
