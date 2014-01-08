//
//  SingleAnnotation.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "SingleAnnotation.h"

@implementation SingleAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    self = [super init];
    if (self) {
        _coordinate = aCoordinate;
    }
    return self;
}

#pragma mark equality

- (BOOL)isEqual:(SingleAnnotation*)annotation;
{
    if (![annotation isKindOfClass:[SingleAnnotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.title isEqualToString:annotation.title] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.groupTag isEqualToString:annotation.groupTag]);
}

@end
