//
//  ELTestActionSheetViewController.m
//  Geo Contents
//
//  Created by spider on 23.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELFeatureViewController.h"

@interface ELFeatureViewController ()

@end

@implementation ELFeatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Start Location Services
    if ([CLLocationManager locationServicesEnabled]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
    
    if (self.feature != nil) {
       
        NSURL *profileURL;
        if ([self.feature.source_type isEqualToString:@"Instagram"]) {
            self.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
             profileURL = [NSURL URLWithString:self.feature.user.profile_picture];
        }
        else
        {
            self.sourceTypeImageView.image = [UIImage imageNamed:@"overlay.png"];
             profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",self.feature.user.idd,@"/picture"]];
        }
        self.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
        self.usernameLabel.text =self.feature.user.full_name;
        self.timeDistance.text = [NSString stringWithFormat:@"%llu", [self.feature.distance unsignedLongLongValue]];;
        
        // to be Fixed to async
        
        dispatch_queue_t concurrentQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            __block UIImage *image = nil;
            dispatch_sync(concurrentQueue, ^{
                /* Download the image here */
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.feature.standard_resolution]];
            });
            dispatch_sync(dispatch_get_main_queue(), ^{
                /* Show the image to the user here on the main queue*/
                self.standardResolutionImageview.image = image;
            });
        });

        
        
        if (self.feature.description !=NULL) {
            self.descriptionLabel.text = self.feature.description;
        }
        
    }
}


- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.usernameLabel ) {
        //self.detailImageView.image = (UIImage*)_detailItem;
        self.usernameLabel.text = @"Spider";
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showActionSheet:(id)sender {
    
    if ([self.feature.source_type isEqualToString:@"Instagram"]) {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View in map",@"Direct me here", @"Map this!", nil];
        
        [sheet showFromRect:[self.actionButton frame] inView:self.view animated:YES];
    }
    else
    {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View in map", @"Direct me here",@"Edit",@"Delete" ,nil];
        sheet.destructiveButtonIndex = 3;
        [sheet showFromRect:[self.actionButton frame] inView:self.view animated:YES];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Delete"])
        [self deleteClicked];
    else if([buttonTitle isEqualToString:@"Edit"])
        [self editClicked];
    else if([buttonTitle isEqualToString:@"View in map"])
        [self viewInMapClicked];
    else if([buttonTitle isEqualToString:@"Direct me here"])
        [self directMeHereClicked];
}


-(void)deleteClicked
{
    NSLog(@"deleteClicked");
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *urlPath = [NSString stringWithFormat:@"overlay://delete/entry?id=%@",self.feature.idd];
    NSURL *url = [NSURL URLWithString:urlPath];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    
}

-(void)editClicked
{
    NSLog(@"editClicked");
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *urlPath = [NSString stringWithFormat:@"overlay://edit/entry?id=%@",self.feature.idd];
    NSURL *url = [NSURL URLWithString:urlPath];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

-(void)viewInMapClicked
{
    NSLog(@"viewInMapClicked");
    
    UIApplication *app = [UIApplication sharedApplication];

    NSString *lat = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.longitude];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://browse/mapview?lat=%@&lng=%@",lat,lng]];
                      
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        //Test
    }
    
}

-(void)directMeHereClicked
{
    NSLog(@"directMeHereClicked");
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *lat = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",self.feature.fLocation.coordinate.longitude];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://browse/directMe?lat=%@&lng=%@",lat,lng]];
        
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        //Test
    }
}




- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    /* We received the new location */
    NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
    NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    /* Failed to receive user's location */
}


@end
