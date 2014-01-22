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
} ClusterMethodType;

@interface Algorithms : NSObject

+ (NSArray *)bubbleMthodWithAnnotations:(NSArray*)annotations
                                 radius:(CLLocationDistance)radius
                                grouped:(BOOL)grouped;
+ (NSArray *)gridMethodWithAnnotations:(NSArray*)annotations
                                  rect:(MKCoordinateSpan)tileRect
                               grouped:(BOOL)grouped;

@end
