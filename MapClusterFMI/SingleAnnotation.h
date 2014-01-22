//
//  SingleAnnotation.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 1/8/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GroupProtocol.h"

@interface SingleAnnotation : NSObject <MKAnnotation, GroupProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *groupTag;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
