//
//  Algorithms.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "Algorithms.h"
#import "PinAnnotation.h"
#import "Distance.h"
#import "GroupProtocol.h"

@implementation Algorithms

+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
                                    grouped:(BOOL)grouped;
{
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
	// Clustering
	for (id <MKAnnotation> annotation in annotationsToCluster)
    {
		// Find fitting existing cluster
		BOOL foundCluster = NO;
        for (PinAnnotation *clusterAnnotation in clusteredAnnotations) {
            // If the annotation is in range of the cluster, add it
            if ((CLLocationCoordinateDistance([annotation coordinate], [clusterAnnotation coordinate]) <= radius)) {
                // check group
                if (grouped && [annotation conformsToProtocol:@protocol(GroupProtocol)]) {
                    if (![clusterAnnotation.groupTag isEqualToString:((id <GroupProtocol>)annotation).groupTag])
                        continue;
                }
                
                foundCluster = YES;
                [clusterAnnotation addAnnotation:annotation];
                break;
            }
        }
        
        // If the annotation wasn't added to a cluster, create a new one
        if (!foundCluster){
            PinAnnotation *newCluster = [[PinAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
            
            // check group
            if (grouped && [annotation conformsToProtocol:@protocol(GroupProtocol)]) {
                newCluster.groupTag = [(id<GroupProtocol>)annotation groupTag];
            }
        }
	}
    
    // whipe all empty or single annotations
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (PinAnnotation *anAnnotation in clusteredAnnotations) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1){
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}

@end
