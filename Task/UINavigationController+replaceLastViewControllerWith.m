//
//  UINavigationController+replaceLastViewControllerWith.m
//  Task
//
//  Created by Martin Pinka on 14.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "UINavigationController+replaceLastViewControllerWith.h"

@implementation UINavigationController (replaceLastViewControllerWith)

- (void) replaceLastViewControllerWith:(UIViewController *) controller {
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [stackViewControllers removeLastObject];
    [stackViewControllers addObject:controller];
    [self setViewControllers:stackViewControllers animated:YES];
}

@end
