//
//  ELInfoViewController.m
//  Geo Contents
//
//  Created by spider on 23.05.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELInfoViewController.h"
#import "ELConstants.h"

@interface ELInfoViewController ()

@end

@implementation ELInfoViewController
@synthesize infoWebView;
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
    // Do any additional setup after loading the view from its nib.
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:INFO_PAGE_URL];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.infoWebView loadRequest:requestObj];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    }

@end
