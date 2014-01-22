//
// REMarker.h
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FMIMarker <MKAnnotation>
@end

@interface FMIMarker : NSObject <FMIMarker>

@property (assign, readwrite, nonatomic) NSUInteger markerId;
@property (copy, readwrite, nonatomic) NSString *title;
@property (copy, readwrite, nonatomic) NSString *subtitle;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, readwrite, nonatomic) NSDictionary *userInfo;

@end