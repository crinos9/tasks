//
//  Task.h
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Task : NSManagedObject

@property (nonatomic) NSInteger taskID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * username;
@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL taskDeleted;



-(id)initWithName:(NSString *) name AndCompleteState:(BOOL) completeState;
-(id)initWithID:(NSInteger)taskID Name:(NSString *) name AndCompleteState:(BOOL) completeState;

@end
 