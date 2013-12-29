//
//  PinAnnotation.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/29/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// This is Annotation class which represents a Cluster.
@interface PinAnnotation : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
