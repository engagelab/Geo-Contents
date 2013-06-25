//
//  ELInfoViewController.m
//  Geo Contents
//
//  Created by spider on 23.05.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELInfoViewController.h"
#import "ELConstants.h"



/*
 *  Info View
 *
 *  Discussion:
 *    A view with static contents that describe the purpose and use of the app. All contents are made on .xib using UILabel and UIButton
 *
 */
@interface ELInfoViewController ()

@end

@implementation ELInfoViewController


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
    //self.view.backgroundColor = [UIColor colorWithRed:.55 green:.74 blue:.15 alpha:1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)openWeblink:(id)sender
{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://yourban.no"]];
}



@end
