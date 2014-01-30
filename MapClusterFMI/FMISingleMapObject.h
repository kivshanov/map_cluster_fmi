//
// FMISingleMapObject.h
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov  on 01/18/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FMISingleMapObject <MKAnnotation>
@end

@interface FMISingleMapObject : NSObject <FMISingleMapObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end