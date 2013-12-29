//
//  Distance.m
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/29/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import "Distance.h"

@implementation Distance

double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
    return sqrt(pow(c1.latitude  - c2.latitude , 2.0) +
                pow(c1.longitude - c2.longitude, 2.0));
}

@end
