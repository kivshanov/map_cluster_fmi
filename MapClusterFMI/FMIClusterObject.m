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

@property (strong, readwrite, nonatomic) NSString *tag;

@end

@implementation FMIClusterObject

- (id)initWithCluster:(FMIClusterManager *)cluster
{
    if ((self = [super init])) {
        self.singleObjectCluster = cluster;
        self.averageCenter = [cluster isAverageCenter];
        self.singleObjects = [[NSMutableArray alloc] init];
        self.hasClusterCenter = NO;
        self.bounds = [[FMIGeographicBounds alloc] initBoundsWithMapView:self.singleObjectCluster.mapView];
    }
    return self;
}

- (BOOL)addSingleObject:(id<FMISingleMapObject>)singleObject
{ 
    if ([self isSingleObjectAlreadyAdded:singleObject])
        return NO;
    
    if (!self.hasClusterCenter) {
        self.coordinate = singleObject.coordinate;
        self.tag = [NSString stringWithFormat:@"%f%f", self.coordinate.latitude, self.coordinate.longitude];
        self.hasClusterCenter = YES;
        [self setNewBounds];
    } else {
        if (self.averageCenter && self.singleObjects.count >= 2) {
            CGFloat l = self.singleObjects.count + 1;
            CGFloat lat = (self.coordinate.latitude * (l - 1) + singleObject.coordinate.latitude) / l;
            CGFloat lng = (self.coordinate.longitude * (l - 1) + singleObject.coordinate.longitude) / l;
            self.coordinate = CLLocationCoordinate2DMake(lat, lng);
            self.tag = [NSString stringWithFormat:@"%f%f", self.coordinate.latitude, self.coordinate.longitude];
            self.hasClusterCenter = YES;
            [self setNewBounds];
        }
    }
    [self.singleObjects addObject:singleObject];
    
    if (self.singleObjects.count == 1){
        self.title = ((id<FMISingleMapObject>)self.singleObjects.lastObject).title;
//        self.subtitle = ((id<FMISingleMapObject>)self.singleObjects.lastObject).title;
        self.type = [NSNumber numberWithInt:[((FMISingleMapObject *)self.singleObjects.lastObject).type intValue]];
    } else{
        self.title = [NSString stringWithFormat:self.singleObjectCluster.clusterName, self.singleObjects.count];
        self.type = [NSNumber numberWithInt:[((FMISingleMapObject *)self.singleObjects.lastObject).type intValue]];
//        self.subtitle = @"";
    }
    
    return YES;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;

    if (self.singleObjects.count == 1) {
        FMISingleMapObject *singleObject = self.singleObjects.lastObject;
        singleObject.coordinate = coordinate;
    }
}

- (void)setNewBounds
{
    [self.bounds setBottomLeft:self.coordinate topRight:self.coordinate];
    [self.bounds setExtendedBounds:self.singleObjectCluster.size];
}

- (BOOL)isSingleObjectInClusterBounds:(id<FMISingleMapObject>)singleObject
{
    return [self.bounds boundsContains:singleObject.coordinate];
}

- (NSInteger)singleObjectsInClusterFromSingleObjects:(NSArray *)singleObjects
{
    NSInteger result = 0;
    for (id<FMISingleMapObject>singleObject in singleObjects) {
        if ([self isSingleObjectAlreadyAdded:singleObject])
            result++;
    }
    return result;
}

- (BOOL)isSingleObjectAlreadyAdded:(id<FMISingleMapObject>)singleObject
{
    for (id<FMISingleMapObject>m in self.singleObjects) {
        if ([m isEqual:singleObject])
            return YES;
    }
    return NO;
}

@end
