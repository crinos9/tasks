//
//  TaskTableViewController.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "TaskTableViewController.h"
#import "Task.h"
#import "TaskTableViewCell.h"
#import "RequestManager.h"
#import "LocalDataManager.h"
@interface TaskTableViewController ()
@property (strong, nonatomic) NSMutableArray * tasksArray;
@property (strong, nonatomic) Task * newestTask;
@end

@implementation TaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new]; //to remove extra separators
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign out", nil) style:UIBarButtonItemStyleDone target:self action:@selector(signOut:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleDone target:self action:@selector(add:)];
    
    self.title = NSLocalizedString(@"My list", nil);
    
    

    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _tasksArray = [[[LocalDataManager sharedInstance] getNotDeletedTasksForUserName:[RequestManager sharedInstance].username] mutableCopy];
    [self.tableView reloadData];
    
    [[LocalDataManager sharedInstance] syncWithServerWithCompletionHandler:^(NSError *error) {
        _tasksArray = [[[LocalDataManager sharedInstance] getNotDeletedTasksForUserName:[RequestManager sharedInstance].username] mutableCopy];
        NSLog(@"blaaaa %@", _tasksArray);
        [self.tableView reloadData];
    }];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[LocalDataManager sharedInstance] commitChangesWithCompletionHandler:nil];
    
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tasksArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TaskTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    Task * task = [_tasksArray objectAtIndex:indexPath.row];
    
    
    
    if (!cell) {
        cell = [TaskTableViewCell new];
    }
    cell.nameTextField.delegate = self;
    [cell setTask:task];
     

    cell.delegate = self;
    //[cell setLeftUtilityButtons: WithButtonWidth:<#(CGFloat)#>]
    [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:60.0f];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60.0f];
    if (task.completed) {
        [cell showLeftUtilityButtonsAnimated:NO];
    }
    return cell;
    
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Task * task = _tasksArray[indexPath.row];
        [[LocalDataManager sharedInstance] deleteTask:task];
        [_tasksArray removeObjectAtIndex:indexPath.row];
        
        [self.tableView reloadData];
        
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark Table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskTableViewCell * taskCell = (TaskTableViewCell *) cell;
    if (taskCell.task == _newestTask) {
        [taskCell.nameTextField becomeFirstResponder];
    }
}

#pragma mark button actions
-(void)signOut:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)add:(id)sender {
    
    _newestTask = [[LocalDataManager sharedInstance] createTaskWithName:@"New Task"];
    [_tasksArray insertObject:_newestTask atIndex:0];
    [self.tableView reloadData];

}


#pragma mark actions for cells

-(NSArray *) leftButtons {
    NSMutableArray * array = [NSMutableArray new];
    
    [array sw_addUtilityButtonWithColor:[UIColor colorWithRed:154.0/255.0f green:222.0/255.0f blue:72.0/255.0f alpha:1.0] icon:[UIImage imageNamed:@"check"]];
    
    return array;
}

-(NSArray *) rightButtons {
    
    NSMutableArray * array = [NSMutableArray new];
    
    [array sw_addUtilityButtonWithColor:[UIColor colorWithRed:215.0/255.0f green:73.0/255.0f blue:71.0/255.0f alpha:1.0] icon:[UIImage imageNamed:@"cross"]];
    
    return array;
    
    
}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];

    Task * task = _tasksArray[indexPath.row];
    [[LocalDataManager sharedInstance] deleteTask:task];
    [_tasksArray removeObjectAtIndex:indexPath.row];
    
    [self.tableView reloadData];
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
    
    TaskTableViewCell * taskCell = (TaskTableViewCell *) cell;
    Task * task = taskCell.task;
    
    BOOL wasCompleted = task.completed;
    
    if (state == kCellStateLeft) {
        task.completed = YES;
    } else if (state == kCellStateCenter || state == kCellStateRight) {
        task.completed = NO;
    }
    
    if (wasCompleted != task.completed) {
        
        [[LocalDataManager sharedInstance] commitChangesWithCompletionHandler:^(NSError *error) {
            _tasksArray = [[[LocalDataManager sharedInstance] getNotDeletedTasksForUserName:[RequestManager sharedInstance].username] mutableCopy];
            [self.tableView reloadData];
        }];
    }
    
}


#pragma mark textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    _newestTask = nil;
    
    _tasksArray = [[[LocalDataManager sharedInstance] getNotDeletedTasksForUserName:[RequestManager sharedInstance].username] mutableCopy];
    [self.tableView reloadData];
    
    [[LocalDataManager sharedInstance] commitChangesWithCompletionHandler:^(NSError *error) {
        _tasksArray = [[[LocalDataManager sharedInstance] getNotDeletedTasksForUserName:[RequestManager sharedInstance].username] mutableCopy];
        [self.tableView reloadData];
    }];
    
    
    
    return NO;
}

@end
