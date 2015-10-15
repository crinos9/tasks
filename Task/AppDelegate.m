//
//  AppDelegate.m
//  Task
//
//  Created by Martin Pinka on 13.10.15.
//  Copyright © 2015 thefuntasty. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworkReachabilityManager.h>
#import "LocalDataManager.h"
@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UINavigationBar appearance].shadowImage = [UIImage imageNamed:@"separator"];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0f green:181.0/255.0 blue:239.0/255.0 alpha:1.0],
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:15]}];
    
    
    
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:214.0f/255.0f green:217.0f/255.0f blue:223.0f/255.0f alpha:1.0f],
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:12.0]
       }
     forState:UIControlStateNormal];
    
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [[LocalDataManager sharedInstance] syncWithServer];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[LocalDataManager sharedInstance] localCommit];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[LocalDataManager sharedInstance] localCommit];
}


@end
