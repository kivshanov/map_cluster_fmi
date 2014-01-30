//
//  FMIClusterObject.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FMIGeographicBounds.h"

@class FMIClusterManager;
@protocol FMISingleMapObject;

@interface FMIClusterObject : NSObject <MKAnnotation>

@property (strong, readwrite, nonatomic) FMIGeographicBounds *bounds;
@property (weak, readwrite, nonatomic) FMIClusterManager *markerClusterer;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, readwrite, nonatomic) BOOL averageCenter;
@property (assign, nonatomic) BOOL hasCenter;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, copy) NSNumber *type;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, readonly, nonatomic) NSString *coordinateTag;

- (id)initWithClusterer:(FMIClusterManager *)clusterer;
- (BOOL)isMarkerAlreadyAdded:(id<FMISingleMapObject>)marker;
- (NSInteger)markersInClusterFromMarkers:(NSArray *)markers;
- (BOOL)addMarker:(id<FMISingleMapObject>)marker;
- (BOOL)isMarkerInClusterBounds:(id<FMISingleMapObject>)marker;

@end
