//
//  ELAppDelegate.m
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELAppDelegate.h"
#import "ELHomeScreenViewController.h"
#import "ELContentViewController.h"
#import "ELSearchViewController.h"
#import "ELNearbyListViewController.h"
#import "ELRecentListViewController.h"
#import "ELFeatureViewController.h"
#import "ELRESTful.h"
#import "ELInfoViewController.h"
#import "ELConstants.h"



@implementation ELAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    //Create Latest View Controller and give it a tittle
    ELInfoViewController *infoView =
    [[ELInfoViewController alloc] initWithNibName:@"ELInfoViewController" bundle:nil];
    [infoView setTitle:@"Info"];
    
    
    
    //Create Latest View Controller and give it a tittle
    ELContentViewController *contentView =
    [[ELContentViewController alloc] initWithNibName:@"ELContentViewController" bundle:nil];
    [contentView setTitle:@"Browse"];
    // Create our navigation controller using our ELLatestViewController as it's root view controller
	self.contentNavController = [[UINavigationController alloc] initWithRootViewController:contentView];

    
    ELSearchViewController *searchView =
    [[ELSearchViewController alloc] initWithNibName:@"ELSearchViewController" bundle:nil];
    [searchView setTitle:@"Search"];
    // Create our navigation controller using our ELLatestViewController as it's root view controller
	self.searchNavController = [[UINavigationController alloc] initWithRootViewController:searchView];
    

    
    
    ELNearbyListViewController *nearbyListView =
    [[ELNearbyListViewController alloc] initWithNibName:@"ELNearbyListViewController" bundle:nil];
    [nearbyListView setTitle:@"Nearby"];
    
    // Create our navigation controller using our ELLatestViewController as it's root view controller
    self.nearbyNavController = [[UINavigationController alloc] initWithRootViewController:nearbyListView];
    
    
    
    //Create Latest View Controller and give it a tittle
    ELRecentListViewController *recentView =
    [[ELRecentListViewController alloc] initWithNibName:@"ELRecentListViewController" bundle:nil];
    [recentView setTitle:@"Recent"];
    
    // Create our navigation controller using our ELLatestViewController as it's root view controller
	self.recentNavController = [[UINavigationController alloc] initWithRootViewController:recentView];
    
        
	// Make an array containing our plain view controller and our navigation controller
	NSArray *viewArray = [NSArray arrayWithObjects:infoView,self.contentNavController,self.searchNavController,self.nearbyNavController,self.recentNavController,nil];
    
    // Create our tab bar controller
    self.tabBarController = [[UITabBarController alloc] init];
    
    //self.tabBarController.delegate = mapView;
    
    // Tell the tab bar controller to use our array of views
    [self.tabBarController setViewControllers:viewArray];
    
    // Finally, set the tabbar controller as a root view controller of the app window
    [self.window setRootViewController:self.tabBarController];
    
    
    [self customizeiPhoneTheme];
    
    [self setuserdefaults];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)setuserdefaults
{
    NSDictionary *sampleGroup = @{@"administrator" : @"1",
                                  @"bookmark_order": @"1",
                                  @"id" : @"201969126621175",
                                  @"name" : @"MAPPA2",
                                  @"unread" : @"8",
                                  @"version" : @"1"};
    
    NSArray *groupArray = [NSArray arrayWithObject:sampleGroup];
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:groupArray forKey:SHARED_DICT_FB_SESSION_ID_LIST_KEY];
    [defaults synchronize];
    
}






- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    

    NSDictionary *dict = [ELRESTful parseQueryString:[url query]];
    
    
    if ([[url host] isEqualToString:@"browse"]) {
        //utilize bbox info if required
        //open search view controller
        if ([[url path] isEqualToString:@"/bbox"]) {
            self.overlayBoundingBox = [NSDictionary dictionaryWithDictionary:dict];
            [self.contentNavController popToRootViewControllerAnimated:YES];
            [self.tabBarController setSelectedIndex:1];
        }
        
        else if ([[url path] isEqualToString:@"/entry"])
        {
           // NSString *poiID = [dict objectForKey:@"id"];
            //NSString *type = [dict objectForKey:@"type"];
            
           // ELFeature *feature = [];
            // fetch poi info from instagram/overlay using the ID
            // prepare the  view controller with instagram/overaly data
            ELFeatureViewController *secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];
            
            [self.contentNavController pushViewController:secondView animated:YES];
            [self.tabBarController setSelectedIndex:1];
        }
    }
    
    if ([[url host] isEqualToString:@"search"]) {
        [self.searchNavController popToRootViewControllerAnimated:YES];
        [self.tabBarController setSelectedIndex:2];
    }
    
    if ([[url host] isEqualToString:@"nearby"]) {
        //utilize bbox info if required
        //open search view controller
        if ([[url path] isEqualToString:@"/bbox"]) {
            self.overlayBoundingBox = [NSDictionary dictionaryWithDictionary:dict];
            [self.nearbyNavController popToRootViewControllerAnimated:YES];
            [self.tabBarController setSelectedIndex:3];
        }
    }
    
    if ([[url host] isEqualToString:@"recent"]) {
        //utilize bbox info if required
        //open search view controller
        if ([[url path] isEqualToString:@"/bbox"]) {
            self.overlayBoundingBox = [NSDictionary dictionaryWithDictionary:dict];
            [self.recentNavController popToRootViewControllerAnimated:YES];
            [self.tabBarController setSelectedIndex:4];
        }
    }
    
    return YES;
}






-(void)customizeiPhoneTheme
{
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:184/255.0 green:211/255.0 blue:54/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:184/255.0 green:211/255.0 blue:54/255.0 alpha:1.0]];
    
//    UIImage *navBarImage = [[UIImage imageNamed:@"menubar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
//    
//    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
//
//    UIImage *barButton = [[UIImage imageNamed:@"menubar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//    
//    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal
//                                          barMetrics:UIBarMetricsDefault];
//    
//    UIImage *backButton = [[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
//    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
//    
//    
//    UIImage *minImage = [UIImage imageNamed:@"ipad-slider-fill"];
//    UIImage *maxImage = [UIImage imageNamed:@"ipad-slider-track.png"];
//    UIImage *thumbImage = [UIImage imageNamed:@"ipad-slider-handle.png"];
//    
//    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
//    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
//    
//    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar-active.png"]];
    
}





- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


}

@end
