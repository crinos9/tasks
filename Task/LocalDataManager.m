//
//  LocalDataManager.m
//  Task
//
//  Created by Martin Pinka on 14.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "LocalDataManager.h"
#import "RequestManager.h"
@implementation LocalDataManager

-(id)init {
    self = [super init];
    if (self) {
        _managedObjectContext = [self managedObjectContext];
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
        //    [self syncWithServer];
        }
    }return self;
}

+ (LocalDataManager *)sharedInstance {
    
    static LocalDataManager *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
    
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tasksx.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
  
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(Task *)createTaskWithName:(NSString *) name {


    Task * task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:_managedObjectContext];    
    task.name = name;
    task.completed = NO;

    task.username = [RequestManager sharedInstance].username;
    
    return task;
}

-(void)deleteTask:(Task *) task {
    
    [[RequestManager sharedInstance] deleteTask:task AndComplationHandler:^(NSError *error) {
        if (error == nil || (error && [error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"])) {
            [_managedObjectContext deleteObject:task];
        } else {
            task.taskDeleted = YES;
        }
    }];
    

}

-(void)commitChangesWithCompletionHandler: (void(^)(NSError * error))handler {
    
//    [self localCommit];
    
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        [self syncWithServerWithCompletionHandler:^(NSError *error) {
            if (handler) {
                handler(error);
            }
        }];
    }
}

-(void)localCommit {
    NSError *error;
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } 
}

-(NSArray *)getNotDeletedTasksForUserName:(NSString *)username {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"username", [RequestManager sharedInstance].username, @"taskDeleted", [NSNumber numberWithBool:NO]];
    
    return [self getTasksWithPredicate:predicate];
}

-(NSArray *)getTasksForUsername:(NSString *)username {
    
    return [self getTasksWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"username", [RequestManager sharedInstance].username]];
}

-(NSArray *) getTasksWithPredicate:(NSPredicate *) predicate {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    //    [entity setValue:@"blah" forKey:@"username"];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", result);
        
    }
    
    return result;
}


-(void)syncWithServer {
    
    [self syncWithServerWithCompletionHandler:nil];
}

-(void)syncWithServerWithCompletionHandler: (void(^)(NSError * error))handler{

    
    if (![AFNetworkReachabilityManager sharedManager].reachable || _isSyncing) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    
    _isSyncing = YES;
    
    [self uploadChangesWithCompletionHandler:^(NSError *error) {
    // if (error == nil) {

            [self downloadNewFromServerWithComplationHandler:^(NSError *error) {
                _isSyncing = NO;
                if (handler) {
                    handler(nil);
                }
                
            }];
        //}
        
        
    }];
}

-(void)uploadChangesWithCompletionHandler: (void(^)(NSError * error))handler{
    
    NSArray * array = [self getTasksForUsername:[RequestManager sharedInstance].username];
    __block NSInteger numOfResponses = 0;
    __block NSError * lastFail = nil; 
    
    if (array.count == 0) {
        handler(nil);
        return;
    }
    
    for (Task * task in array) {

        if (task.taskID == -1) { //not in server DB
         
            if (task.taskDeleted) { //should be deleted
                [self deleteTask:task];
                continue;
            } //otherwise will be created on the server
            
            [[RequestManager sharedInstance] createTask:task AndComplationHandler:^(NSNumber *taskID, NSError *error) {
                
                numOfResponses++;
                
                if (error == nil) {
                    task.taskID = [taskID integerValue];   
                } else {
                    lastFail = error;
                }
                
                if (numOfResponses == array.count) {
                    handler(error);
                }
            }];
            
        } else { //is in the server DB
            
            if (task.taskDeleted) {// is on server and it has to be deleted
                
                [[RequestManager sharedInstance] deleteTask:task AndComplationHandler:^(NSError *error) {
                    
                    numOfResponses++;
                    
                    if (error == nil) {//was deleted
                        [self deleteTask:task];
                    } else {
                        lastFail = error;
                    }
                    
                    if (numOfResponses == array.count) {
                        handler(error);
                    }
                }];
                
            } else {//otherwise task has to be updated
                
                if (task.completed) {
            
                    [[RequestManager sharedInstance] updateTask:task WithComplationHandler:^(NSError *error) {
                    
                        numOfResponses++;
                    
                        if (error) {//was updated
                            lastFail = error;
                        }
                    
                        if (numOfResponses == array.count) {
                            handler(error);
                        }
                    }];
                } else {
                    numOfResponses++;
                }
            }
        } 
    }
    

}

-(void)downloadNewFromServerWithComplationHandler: (void(^)(NSError * error))handler {
    [[RequestManager sharedInstance] getTasksWithComplationHandler:^(NSArray *tasks, NSError *error) {
        NSArray * local = [self getTasksForUsername:[RequestManager sharedInstance].username];
        BOOL found = NO; 
        
        for (NSDictionary * remoteTask in tasks) {
            for (Task * localTask in local) {
                
                if (localTask.taskID == [remoteTask[@"id"] integerValue]) {
                    found = YES;
                    
                    if (!localTask.completed) {
                        localTask.completed = [remoteTask[@"completed"] boolValue];
                    }
                    
                    break;
                }
            }
            
            if (found) {
                found = NO;    
                continue;
            } else { //remoteTask doesnt exist in local db, so we have to create it
                
                Task * newTask = [self createTaskWithName:remoteTask[@"name"]];
                newTask.completed = [remoteTask[@"completed"] boolValue];
                newTask.taskID = [remoteTask[@"id"] integerValue];
                
            }
        }
        
       // [self localCommit];
        handler(nil);
    }];
}

@end
