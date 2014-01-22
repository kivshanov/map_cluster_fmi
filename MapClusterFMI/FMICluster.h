//
//  ReCluster.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RELatLngBounds.h"

@class REMarkerClusterer;
@protocol FMIMarker;

@interface FMICluster : NSObject <MKAnnotation>

@property (strong, readwrite, nonatomic) RELatLngBounds *bounds;
@property (weak, readwrite, nonatomic) REMarkerClusterer *markerClusterer;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, readwrite, nonatomic) BOOL averageCenter;
@property (assign, nonatomic) BOOL hasCenter;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, readonly, nonatomic) NSString *coordinateTag;

- (id)initWithClusterer:(REMarkerClusterer *)clusterer;
- (BOOL)isMarkerAlreadyAdded:(id<FMIMarker>)marker;
- (NSInteger)markersInClusterFromMarkers:(NSArray *)markers;
- (BOOL)addMarker:(id<FMIMarker>)marker;
- (BOOL)isMarkerInClusterBounds:(id<FMIMarker>)marker;
- (void)setAverageCenter;
- (void)printDescription;

@end
