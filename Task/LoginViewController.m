//
//  LoginViewController.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "LoginViewController.h"
#import "RequestManager.h"
#import "LocalDataManager.h"
@interface LoginViewController ()
@property BOOL loginRequestSend;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //  [[LocalDataManager sharedInstance] tryFunc];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark button clicks
-(IBAction)login:(id)sender {
    
    if (_loginRequestSend == NO) {
        
        _loginRequestSend = YES;
        
        [[RequestManager sharedInstance] loginWithUsername:_nameTextField.text AndPassword:_passwordTextField.text AndComplationHandler:^(bool logged, NSError *error) {
        
            if (logged) {
                UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"taskTable"];
                [self.navigationController pushViewController:vc animated:YES];
                
                [[LocalDataManager sharedInstance] syncWithServer];
            }
            _loginRequestSend = NO;

        }];
    }
    
 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
