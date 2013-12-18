//
//  GroupProtocol.h
//  MapClusterFMI
//
//  Created by Pavlina Gatova on 12/18/13.
//  Copyright (c) 2013 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol GroupProtocol <MKAnnotation>

@property (nonatomic, readonly, copy) NSString *groupTag;

@end
