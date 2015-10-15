//
//  TaskTableViewCell.h
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "Task.h"

@interface TaskTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UITextField * nameTextField;
@property (strong, nonatomic) Task * task;

@end
