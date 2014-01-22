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

+ (NSArray *)bubbleMthodWithAnnotations:(NSArray*)annotations radius:(CLLocationDistance)radius grouped:(BOOL)grouped
{
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
	// Clustering
	for (id <MKAnnotation> annotation in annotations)
    {
		// Find fitting existing cluster
		BOOL foundCluster = NO;
        for (PinAnnotation *clusterAnnotation in clusteredAnnotations) {
            // If the annotation is in range of the cluster, add it
            if ((LocationDistance([annotation coordinate], [clusterAnnotation coordinate]) <= radius)) {
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

+ (NSArray *)gridMethodWithAnnotations:(NSArray*)annotations rect:(MKCoordinateSpan)tileRect grouped:(BOOL)grouped
{
    NSMutableDictionary *clusteredAnnotations = [[NSMutableDictionary alloc] init];
    
    // iterate through all annotations
	for (id<MKAnnotation> annotation in annotations)
    {
        // calculate grid coordinates of the annotation
        NSInteger row = ([annotation coordinate].longitude+180.0)/tileRect.longitudeDelta;
        NSInteger column = ([annotation coordinate].latitude+90.0)/tileRect.latitudeDelta;
        NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)row,(long)column];
        
        // add group tag to key
        if (grouped && [annotation conformsToProtocol:@protocol(GroupProtocol)]) {
            key = [NSString stringWithFormat: @"%@%@", key, [(id<GroupProtocol>)annotation groupTag]];
        }
        
        // get the cluster for the calculated coordinates
        PinAnnotation *clusterAnnotation = [clusteredAnnotations objectForKey:key];
        
        // if there is none, create one
        if (clusterAnnotation == nil) {
            clusterAnnotation = [[PinAnnotation alloc] init];
            
            CLLocationDegrees lon = row * tileRect.longitudeDelta + tileRect.longitudeDelta/2.0 - 180.0;
            CLLocationDegrees lat = (column * tileRect.latitudeDelta) + tileRect.latitudeDelta/2.0 - 90.0;
            clusterAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
            
            // check group
            if (grouped && [annotation conformsToProtocol:@protocol(GroupProtocol)]) {
                clusterAnnotation.groupTag = [(id<GroupProtocol>)annotation groupTag];
            }
            
            [clusteredAnnotations setValue:clusterAnnotation forKey:key];
        }
        
        // add annotation to the cluster
        [clusterAnnotation addAnnotation:annotation];
	}
    
    // return array
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // add single annotations directly without OCAnnotation
    for (PinAnnotation *anAnnotation in [clusteredAnnotations allValues]) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1) {
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}

@end
