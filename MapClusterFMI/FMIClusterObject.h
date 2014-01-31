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
@property (weak, readwrite, nonatomic) FMIClusterManager *singleObjectCluster;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, readwrite, nonatomic) BOOL averageCenter;
@property (nonatomic, assign) BOOL hasClusterCenter;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSNumber *type;
@property (strong, nonatomic) NSMutableArray *singleObjects;
@property (strong, readonly, nonatomic) NSString *tag;

- (id)initWithCluster:(FMIClusterManager *)cluster;
- (BOOL)isSingleObjectAlreadyAdded:(id<FMISingleMapObject>)singleObject;
- (NSInteger)singleObjectsInClusterFromSingleObjects:(NSArray *)singleObjects;
- (BOOL)addSingleObject:(id<FMISingleMapObject>)singleObject;
- (BOOL)isSingleObjectInClusterBounds:(id<FMISingleMapObject>)singleObject;

@end
