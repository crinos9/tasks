//
//  RequestManager.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#define HOST @"http://api.taskstest.thefuntasty.com/"
#define AUTHORIZE [NSString stringWithFormat:@"%@%@", HOST, @"authorize"]
#define REGISTER [NSString stringWithFormat:@"%@%@", HOST, @"register"]
#define GET_TASKS(token) [NSString stringWithFormat:@"%@%@?token=%@", HOST, @"me/tasks",token]
#define CREATE_TASK(token) [NSString stringWithFormat:@"%@%@?token=%@", HOST, @"me/tasks",token]
#define EDIT_TASK(token, ID) [NSString stringWithFormat:@"%@%@%ld?token=%@", HOST, @"me/tasks/",ID,token] 
#define DELETE_TASK(token, ID) EDIT_TASK(token, ID)


#import "RequestManager.h"
#import "LocalDataManager.h"
@implementation RequestManager

-(id)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];

    }
    return self;
}

+ (RequestManager *)sharedInstance {
    
    static RequestManager *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
    
}

-(void)signUpWithUsername:(NSString *)username AndPassword: (NSString *)password AndComplationHandler:(void(^)(BOOL logged, NSError * error))handler {

       NSDictionary *params = @{@"username": username,
                             @"password": password};
    [_manager POST:REGISTER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"JSON: %@", responseObject);
            _token = responseObject[@"token"];
            handler(YES, nil);
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(NO,error);
            NSLog(@"Error: %@", error);
        });
           
        
    }];
    
}

-(void)loginWithUsername:(NSString *)username AndPassword: (NSString *)password AndComplationHandler:(void(^)(bool logged,NSError * error))handler{
    
   
    NSDictionary *params = @{@"username": username,
                               @"password": password};
    [_manager POST:AUTHORIZE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"JSON: %@", responseObject);
            _token = responseObject[@"token"];
            _username = responseObject[@"user"][@"username"];
            handler(YES, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
            handler(NO, error);
        });

    }];
    
}


-(void)getTasksWithComplationHandler:(void(^)(NSArray * tasks,NSError * error))handler{
    
    
//    NSDictionary *params = @{@"username": username,
       //                      @"password": password};
    //[[LocalDataManager sharedInstance] getTasksForUsername:self.username];

    [_manager GET:GET_TASKS(_token) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * responseArray = responseObject;

            
            handler(responseArray, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
        });
        
    }];
    
}

-(void)createTask:(Task *)task AndComplationHandler:(void(^)(NSNumber * taskID,NSError * error))handler{
    
    
    NSDictionary *params = @{@"name": task.name,
                             @"completed": [NSNumber numberWithBool:task.completed]};
    [_manager POST:CREATE_TASK(_token) parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"JSON: %@", responseObject);
            handler(responseObject[@"id"], nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
            handler(nil, error);
        });
        
    }];
    
}

-(void)updateTask:(Task*)task WithComplationHandler:(void(^)(NSError * error))handler{
   
    
    NSDictionary *params = @{@"id": [NSNumber numberWithInteger:task.taskID],
                             @"name": task.name,
                             @"completed": [NSNumber numberWithBool:task.completed]};
    [_manager PUT:EDIT_TASK(_token, (long)task.taskID) parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"JSON: %@", responseObject);
            handler(nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
            handler(error);
        });
        
    }];
    
}

-(void)deleteTask:(Task*)task AndComplationHandler:(void(^)(NSError * error))handler{
    
    
    NSDictionary *params = @{@"id": [NSNumber numberWithInteger:task.taskID],
                             @"name": task.name,
                             @"completed": [NSNumber numberWithBool:task.completed]};
    [_manager DELETE:DELETE_TASK(_token, (long)task.taskID) parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"JSON: %@", responseObject);
            handler(nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
            handler(error);
        });
        
    }];
    
}

-(void)setUsername:(NSString *)username {
    _username = username;
    
}
@end
