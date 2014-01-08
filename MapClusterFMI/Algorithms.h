//
//  Algorithms.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    ClusteringBubbleMethod,
    ClusteringGridMethod
} OCClusteringMethod;

@interface Algorithms : NSObject

+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
                                    grouped:(BOOL)grouped;

+ (NSArray*)gridClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRect:(MKCoordinateSpan)tileRect
                                  grouped:(BOOL)grouped;

@end
