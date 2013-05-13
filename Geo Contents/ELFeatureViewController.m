//
//  ELTestActionSheetViewController.m
//  Geo Contents
//
//  Created by spider on 23.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELFeatureViewController.h"
#import "ELContentViewController.h"
#import "ELTweetGenerator.h"
#import "JMImageCache.h"

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
        
        //clickable user label
        
        self.usernameLabel = [[RCLabel alloc] initWithFrame:CGRectMake(94,13,144,31)];
        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:self.feature.user withSourceType:self.feature.source_type]];
        self.usernameLabel.componentsAndPlainText = componentsDS;
        self.usernameLabel.delegate = self;
        [self.scroll addSubview:self.usernameLabel];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [formatter setMaximumFractionDigits:0];
        
        CLLocationManager *manager = [CLLocationManager new];
        CLLocation *userLoc = manager.location;
        CLLocation *featureLoc = self.feature.fLocation;
        NSNumber *distance = [ELContentViewController getDistanceBetweenPoint1:userLoc Point2:featureLoc];
        self.timeDistance.text = [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:distance],@"m"];
        
        [self.standardResolutionImageview setImageWithURL:self.feature.images.standard_resolution  placeholder:[UIImage imageNamed:@"placeholder.png"]];
        
        if (self.feature.description !=NULL) {
            
            NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:self.feature];
    
            RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
            //find the height of RTLabel
            CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            
            self.descriptionLabel = [[RCLabel alloc] initWithFrame:CGRectMake(6,355,300,suggestedSize.height)];
            self.descriptionLabel.componentsAndPlainText = componentsDS;
            self.descriptionLabel.delegate = self;
            
            [self.scroll addSubview:self.descriptionLabel];
            //self.descriptionLabel.text = self.feature.description;
        }
        
    }
}



- (void)rtLabel:(id)rtLabel didChangedSize:(CGSize)size
{
    NSLog(@"%@",@"string");
}


- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    
    
    
    NSURL *urlp = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
        [[UIApplication sharedApplication] openURL:urlp];
    }
    
    
    
}








- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.usernameLabel ) {
        //self.detailImageView.image = (UIImage*)_detailItem;
        //self.usernameLabel.text = @"Spider";
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
    else if([buttonTitle isEqualToString:@"Map this!"])
        [self mapThisClicked];
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


-(void)mapThisClicked
{
    NSLog(@"mapThisClicked");
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *feature_id = self.feature.idd;
    NSString *source_type = self.feature.source_type;
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"overlay://mapthis/entry?feauture_id=%@&source_type=%@",feature_id,source_type]];
    
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


//
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation{
//    /* We received the new location */
//    //NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
//    //NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
//}
//
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error{
//    /* Failed to receive user's location */
//}






@end
