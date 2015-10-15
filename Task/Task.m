//
//  Task.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "Task.h"



@implementation Task
@synthesize taskID = _taskID;
@synthesize name = _name;
@synthesize completed = _completed;
@synthesize username = _username;
@synthesize taskDeleted = _taskDeleted;
-(id)initWithName:(NSString *) name AndCompleteState:(BOOL) completeState {
    self = [super init];

    if (self) {
        _taskID = -1;
        _name = name;
        _completed = completeState;
    }

    return self;
}

-(id)initWithID:(NSInteger)taskID Name:(NSString *) name AndCompleteState:(BOOL) completeState {
    self = [self initWithName:name AndCompleteState:completeState];
    
    if (self) {
        _taskID = taskID;
        
    }

    return self;
}


//dont know if this is standard solution, but i wasnt able to change value in core data
-(void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

-(void)setCompleted:(BOOL)completed {
    [self willChangeValueForKey:@"completed"];
    _completed = [NSNumber numberWithBool:completed];
    [self didChangeValueForKey:@"completed"];
}

-(void)setTaskID:(NSInteger)taskID {
    [self willChangeValueForKey:@"taskID"];
    _taskID = taskID;
    [self didChangeValueForKey:@"taskID"];    
}

-(void)setTaskDeleted:(BOOL)taskDeleted {
    [self willChangeValueForKey:@"taskDeleted"];
    _taskDeleted = [NSNumber numberWithBool:taskDeleted];
    [self didChangeValueForKey:@"taskDeleted"];        
}

@end
