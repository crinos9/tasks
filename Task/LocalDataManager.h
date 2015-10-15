//
//  LocalDataManager.h
//  Task
//
//  Created by Martin Pinka on 14.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Task.h"


@interface LocalDataManager : NSObject

@property BOOL isSyncing;
@property (nonatomic,strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (LocalDataManager *) sharedInstance;

-(NSArray *)getTasksForUsername:(NSString *)username;
-(NSArray *)getNotDeletedTasksForUserName:(NSString *)username;

-(Task *)createTaskWithName:(NSString *) name;
-(void)deleteTask:(Task *) task;

-(void)commitChangesWithCompletionHandler: (void(^)(NSError * error))handler;

-(void)localCommit;
-(void)syncWithServer;
-(void)syncWithServerWithCompletionHandler: (void(^)(NSError * error))handler;
@end
