//
//  CoreDataManager.h
//  MaptoSnow
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)instance;

- (void) saveBackgroundContext:(NSManagedObjectContext *)backgroundContext;
- (void) saveContextAndBlock:(BOOL)wait;
- (void) saveContext;

@end
