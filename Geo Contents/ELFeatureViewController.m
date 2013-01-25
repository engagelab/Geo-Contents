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
    
    if (self.feature != nil) {
        NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",self.feature.user.idd,@"/picture"]];
        self.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
        self.usernameLabel.text =self.feature.user.full_name;
        if ([self.feature.source_type isEqualToString:@"Instagram"]) {
            self.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
        }
        else
        {
            self.sourceTypeImageView.image = [UIImage imageNamed:@"overlay.png"];

        }
        self.timeDistance.text = @"4w";
        self.standardResolutionImageview.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.feature.standard_resolution]];
        if (self.feature.description !=NULL) {
            self.descriptionLabel.text = self.feature.description;
        }

    }
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showActionSheet:(id)sender {

    if ([self.feature.source_type isEqualToString:@"Instagram"]) {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", @"View in map", @"Direct me here", nil];
        [sheet showFromRect:[self.actionButton frame] inView:self.view animated:YES];
    }
    else
    {
        UIActionSheet *sheet = sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", @"View in map", @"Direct me here", nil];
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
    
    
}

-(void)editClicked
{
     NSLog(@"editClicked");
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *urlPath = [NSString stringWithFormat:@"overlay://edit/entry?id=%@",@"50d33628da06456278411be3"];
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

-(void)directMeHereClicked
{
     NSLog(@"directMeHereClicked");
}


@end
