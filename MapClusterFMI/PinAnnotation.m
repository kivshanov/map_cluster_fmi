//
//  PinAnnotation.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/29/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "PinAnnotation.h"

@interface PinAnnotation ()
@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@end

@implementation PinAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        _annotationsInCluster = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
{
    self = [self init];
    if (self) {
        _coordinate = [annotation coordinate];
        [_annotationsInCluster addObject:annotation];
        
        if ([annotation respondsToSelector:@selector(title)]) {
            self.title = [annotation title];
        }
        if ([annotation respondsToSelector:@selector(subtitle)]) {
            self.subtitle = [annotation subtitle];
        }
    }
    
    return self;
}

// find min/max and calculate center
- (CLLocationCoordinate2D)coordinate;
{
    if (self.annotationsInCluster.count == 0) return CLLocationCoordinate2DMake(0, 0);
    
    CLLocationCoordinate2D min = [self.annotationsInCluster[0] coordinate];
    CLLocationCoordinate2D max = [self.annotationsInCluster[0] coordinate];
    for (id<MKAnnotation> annotation in self.annotationsInCluster) {
        min.latitude = MIN(min.latitude, annotation.coordinate.latitude);
        min.longitude = MIN(min.longitude, annotation.coordinate.longitude);
        max.latitude = MAX(max.latitude, annotation.coordinate.latitude);
        max.longitude = MAX(max.longitude, annotation.coordinate.longitude);
    }
    
    CLLocationCoordinate2D center = min;
    center.latitude += (max.latitude-min.latitude)/2.0;
    center.longitude += (max.longitude-min.longitude)/2.0;
    
    return center;
}

- (NSArray*)annotationsInCluster;
{
    return [_annotationsInCluster copy];
}

// add annotation in cluster
- (void)addAnnotation:(id<MKAnnotation>)annotation;
{
    [_annotationsInCluster addObject:annotation];
}

- (void)addAnnotations:(NSArray *)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

// remove annotation from cluster
- (void)removeAnnotation:(id<MKAnnotation>)annotation;
{
    [_annotationsInCluster removeObject:annotation];
}

- (void)removeAnnotations:(NSArray*)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

@end
