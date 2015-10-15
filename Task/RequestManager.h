//
//  RequestManager.h
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "Task.h"
@interface RequestManager : NSObject


@property (strong, nonatomic) NSString * token;
@property (strong, nonatomic) NSString * username;
@property (strong ,nonatomic) AFHTTPRequestOperationManager *manager;
+ (RequestManager *) sharedInstance;

-(void) signUpWithUsername:(NSString *)username AndPassword: (NSString *)password AndComplationHandler:(void(^)(BOOL logged, NSError * error)) handler;
-(void) loginWithUsername:(NSString *)username AndPassword: (NSString *)password AndComplationHandler:(void(^)(bool logged,NSError * error)) handler;


-(void) getTasksWithComplationHandler:(void(^)(NSArray * tasks,NSError * error))handler;

-(void) createTask: (Task *)task AndComplationHandler: (void(^)(NSNumber * taskID, NSError * error)) handler;
-(void) updateTask: (Task *)task WithComplationHandler: (void(^)(NSError * error)) handler;
-(void) deleteTask: (Task *)task AndComplationHandler: (void(^)(NSError * error)) handler;
@end
