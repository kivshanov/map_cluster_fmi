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

@property(nonatomic, assign) ClusteringMethod clusteringMethod;
@property(nonatomic, strong) NSMutableSet *annotationsToIgnore;
@property(nonatomic, readonly) NSArray *displayedAnnotations;
@property(nonatomic, assign) BOOL clusteringEnabled;
@property(nonatomic, assign) CLLocationDistance clusterSize;
@property(nonatomic, assign) BOOL clusterByGroupTag;
@property(nonatomic, assign) CLLocationDegrees minLongitudeDeltaToCluster;
@property(nonatomic, assign) NSUInteger minimumAnnotationCountPerCluster;
@property (nonatomic, assign) BOOL clusterInvisibleViews;

- (void)doClustering;
- (NSArray *)displayedAnnotations;

@end
