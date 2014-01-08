//
//  MapView.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "MapView.h"

@interface MapView()
@property (nonatomic, strong) NSMutableSet *allAnnotations;
@end

@implementation MapView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit;
{
    _allAnnotations = [[NSMutableSet alloc] init];
}

#pragma mark - MKMapView

- (void)addAnnotations:(NSArray *)annotations{
    [_allAnnotations addObjectsFromArray:annotations];
    [super addAnnotations:annotations];
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [_allAnnotations removeObject:annotation];
    }
    [super removeAnnotations:annotations];
}

- (NSArray *)annotations {
    return [_allAnnotations allObjects];
}


@end
