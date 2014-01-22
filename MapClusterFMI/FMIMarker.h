//
// FMIMarker
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FMIMarker <MKAnnotation>
@end

@interface FMIMarker : NSObject <FMIMarker>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end