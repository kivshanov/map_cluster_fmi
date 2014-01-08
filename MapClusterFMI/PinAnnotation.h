//
//  PinAnnotation.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/29/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GroupProtocol.h"

// This is Annotation class which represents a Cluster.
@interface PinAnnotation : NSObject <GroupProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *groupTag;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
- (NSArray*)annotationsInCluster;
- (void)addAnnotation:(id<MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray*)annotations;

@end
