//
//  SignUpViewController.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "SignUpViewController.h"
#import "RequestManager.h"
#import "UINavigationController+replaceLastViewControllerWith.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  button actions
-(IBAction)signUp:(id)sender {
   [[RequestManager sharedInstance] signUpWithUsername:_nameTextField.text AndPassword:_passwordTextField.text AndComplationHandler:^(BOOL logged, NSError *error) {
        
        if (error) {
            //signup failed
        } else {
                if (logged) {
                    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"taskTable"];
                    [self.navigationController replaceLastViewControllerWith:vc];
                }
        }
    }];
    

}

-(IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
