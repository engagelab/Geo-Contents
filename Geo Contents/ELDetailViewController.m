//
//  ELDetailViewController.m
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELDetailViewController.h"

@interface ELDetailViewController ()

@end

@implementation ELDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"FEATURE", @"FEATURE");

    }
    return self;
}

- (void)setScrollViewLayout
{
    //intialize scrolview
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    //set profile picture and add to scrollview
    UIImage *profileImage = [UIImage imageNamed:@"default_user_icon.jpg"];
    CGRect profileRect = CGRectMake(8.0f, 6.0f, 35.0f, 35.0f);
    self.userProfileImageView =  [[UIImageView alloc] initWithFrame:profileRect];
    [self.userProfileImageView setImage:profileImage];
    [self.scrollView addSubview:self.userProfileImageView];
    
    
    //set user label
    self.usernameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(51.0f, 13.0f, 220.0f, 21.0f)];
    //add NSAttributedString
    self.usernameLabel.text = @"spiderse";
    [self.scrollView addSubview:self.usernameLabel];
    
    //set time label
    self.creationTimeLabel =  [[UILabel alloc]initWithFrame:CGRectMake(270.0f, 13.0f, 241.0f, 21.0f)];
    //add NSAttributedString
    self.creationTimeLabel.text = @"4h";
    [self.scrollView addSubview:self.creationTimeLabel];

    
    //set standard resolution image and add to scrol view
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_imageURL]];
    CGRect rect = CGRectMake(8.0f, 46.0f, 304.0f, 304.0f);
    self.standardResulationImageView =  [[UIImageView alloc] initWithFrame:rect];
    [self.standardResulationImageView setImage:image];
    [self.scrollView addSubview:self.standardResulationImageView];
    
    
    //set time label
    self.descriptionLabel =  [[UILabel alloc]initWithFrame:CGRectMake(16.0f, 358.0f, 296.0f, 21.0f)];
    //add NSAttributedString
    self.descriptionLabel.text = @"Tell the tab bar controller to use our array of views";
    [self.scrollView addSubview:self.descriptionLabel];
    
    
    
    
    self.scrollView.contentSize = self.view.bounds.size;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setScrollViewLayout];
    

    
//    self.myImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:_imageURL]]];
//    self.myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    [self.myScrollView addSubview:self.myImageView];
//    self.myScrollView.contentSize = self.myImageView.bounds.size;
//    self.myScrollView.delegate = self;
//    [self.view addSubview:self.myScrollView];
    
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
