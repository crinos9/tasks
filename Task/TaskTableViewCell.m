//
//  TaskTableViewCell.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "RequestManager.h"
@implementation TaskTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

-(void)setTask:(Task *)task {
    
    _task = task;
    _nameTextField.text = _task.name;

}


-(IBAction)textChangeBegin:(id)sender {
    _nameTextField.text = @"";
}

-(IBAction)textChanged:(id)sender {
    _task.name = _nameTextField.text;
}

-(IBAction)textEditEnded:(id)sender {
    [_nameTextField resignFirstResponder];
}


@end
