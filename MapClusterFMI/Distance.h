//
//  Distance.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/29/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Distance : NSObject

double LocationDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);

@end
