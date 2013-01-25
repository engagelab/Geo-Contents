//
//  ELBridgingApp.m
//  Geo Contents
//
//  Created by spider on 23.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELBridgingApp.h"

@implementation ELBridgingApp


+ (void)openMapView

{
    UIApplication *app = [UIApplication sharedApplication];
        
    NSURL *url = [NSURL URLWithString:@"overlay://mapview/location?lat=59.927999267f&lng=10.759999771"];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}

+ (void)gotoEditPOI

{
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *url = [NSURL URLWithString:@"overlay://edit/poi?id=someid"];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}


+ (void)gotoXXXPOI

{
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *url = [NSURL URLWithString:@"geocontent://brows/bbox?lat1=59.927999267f&lng1=10.759999771f&lat2=59.937999267f&lng2=10.769999771f"];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}


@end
