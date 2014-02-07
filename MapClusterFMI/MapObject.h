//
//  MapObject.h
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 1/23/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MapObject : NSManagedObject

@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;

+ (void)insertCoordinatesinDB;
+ (NSArray *)getObjectsForMaxIndex:(NSInteger)index;
+ (NSArray *)getObjectsForMaxIndex:(NSInteger)index andType:(NSInteger)type;
@end
