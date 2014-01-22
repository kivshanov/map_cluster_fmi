//
//  MapObject.m
//  MapClusterFMI
//
//  Created by Nikolay Kivshanov on 1/23/14.
//  Copyright (c) 2014 FMI Project. All rights reserved.
//

#import "MapObject.h"
#import "CoreDataManager.h"

#define MAX_PIN_NUMBER 1000

@implementation MapObject

@dynamic longtitude;
@dynamic latitude;
@dynamic name;
@dynamic type;
@dynamic index;

static inline NSInteger random_between(NSInteger min, NSInteger max) {
    return min + arc4random() % ((max+1) - min);
}

+ (BOOL)isDataBaseFull {
    NSManagedObjectContext *context = [[CoreDataManager instance] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"MapObject" inManagedObjectContext: context];
    NSError *error = nil;
    NSArray *allObjects = [context executeFetchRequest:request error:&error];
    if(allObjects && allObjects.count > 0)
        return YES;
    else
        return NO;
}

+ (void)insertCoordinatesinDB {
    
    if(![self isDataBaseFull]) {
     
        NSManagedObjectContext *context = [[CoreDataManager instance] managedObjectContext];
        
        for(int i = 0; i<MAX_PIN_NUMBER ; i++) {
            MapObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"MapObject" inManagedObjectContext:context];
            object.latitude = @(42.0f + (float)random_between(5000, 7500)/10000);
            object.longtitude = @(23.0f + (float)random_between(1600, 5000)/10000);
            object.index = @(i+1);
        }
        
        [[CoreDataManager instance] saveContext];
    }
}


+ (NSArray *)getObjectsForMaxIndex:(NSInteger)index {
    
    NSManagedObjectContext *context = [[CoreDataManager instance] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"MapObject" inManagedObjectContext: context];
    request.predicate = [NSPredicate predicateWithFormat:@"index <= %d && index >= %d",index,index-19];
    
    NSError *error = nil;
    NSArray *allObjects = [context executeFetchRequest:request error:&error];
    
    return allObjects;
}

@end
