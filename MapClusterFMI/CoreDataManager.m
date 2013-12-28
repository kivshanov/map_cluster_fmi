//
//  CoreDataManager.m
//  MaptoSnow
//

#import "CoreDataManager.h"

static CoreDataManager *singletonInstance = nil;

@interface CoreDataManager()
@property (nonatomic, strong, readwrite) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext* privateContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext* managedObjectContext;
@end


/**************************************/
#pragma mark - Class Implementation
/**************************************/


@implementation CoreDataManager

+ (CoreDataManager *)instance
{
	if( !singletonInstance)
    {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			singletonInstance = [[self alloc] init];
        });
    }
    
    return singletonInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _privateContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            _privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        });
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = _privateContext;
    }
    
    return self;
}

+ (id)copyWithZone:(NSZone *)zone
{
	return self;
}

/**************************************/
#pragma mark - Stack
/**************************************/


- (NSManagedObjectContext *)backgroundContext
{

    __block NSManagedObjectContext *backgroundContext = nil;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    });
    backgroundContext.parentContext = self.managedObjectContext;

    return backgroundContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if ( !_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FindThemModel" withExtension:@"momd"];
        NSAssert(modelURL != nil, @"Failed to find model URL");
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(_managedObjectModel, @"Failed to initialize model");
    }
    
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if ( !_persistentStoreCoordinator)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSAssert(_persistentStoreCoordinator, @"Failed to initialize persistent store coordinator");
        NSURL *sourceURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FindThem.sqlite"];
        NSError *error = nil;

        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES,
                                  NSSQLitePragmasOption : @{@"journal_mode": @"DELETE"},
                                  };
        
        NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                             configuration:nil
                                                                                       URL:sourceURL
                                                                                   options:options
                                                                                     error:&error];
        if (!store) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
            
        }
    }
    
    return _persistentStoreCoordinator;
}

/**************************************/
#pragma mark - Save
/**************************************/

- (void) saveContext; {
    [self saveContextAndBlock:NO];
}

- (void)saveBackgroundContext:(NSManagedObjectContext *)backgroundContext
{
    NSError *err = nil;
    if (backgroundContext.hasChanges && ![backgroundContext save:&err])
    {
        //DO NOT COMMENT
        NSLog(@"Unresolved error %@", [err userInfo]);
    }
}


- (void)saveContextAndBlock:(BOOL)wait
{
    __weak NSManagedObjectContext *main = self.managedObjectContext;
    __weak NSManagedObjectContext *private = self.privateContext;
    
    if (!private) {
        return;
    }
    
    [main performBlock:^{
        NSError *error = nil;
        if ( ! [main save:&error]) {
            NSLog(@"Error saving main moc: %@\n%@",
                  [error localizedDescription], [error userInfo]);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [private performBlockAndWait:^{
                NSError *error = nil;
                if ( ! [private save:&error]) {
                    NSLog(@"Error saving private moc: %@\n%@",
                          [error localizedDescription], [error userInfo]);
                }
            }];
        });

    }];

}


#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

 

@end
