//
//  MapView.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Algorithms.h"
#import "Distance.h"
#import "PinAnnotation.h"

@interface MapView : MKMapView

@property(nonatomic, assign) ClusterMethodType clusterMethodType;
@property(nonatomic, strong) NSMutableSet *annotationsToIgnore;
@property(nonatomic, readonly) NSArray *displayedAnnotations;
@property(nonatomic, assign) BOOL enableClustering;
@property(nonatomic, assign) CLLocationDistance clusterSize;
@property(nonatomic, assign) BOOL makeGroups;
@property(nonatomic, assign) CLLocationDegrees minDelta;
@property(nonatomic, assign) NSUInteger minAnnotationsInCluster;
@property (nonatomic, assign) BOOL clusterInvisibleViews;

- (void)divideElementsIntoClusters;

@end
