//
//  ELFeatureViewController.m
//  Geo Contents
//
//  Created by spider on 11.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "OldFeatureViewController.h"
#import "TTTTimeIntervalFormatter.h"


@interface OldFeatureViewController ()
//@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation OldFeatureViewController

//@synthesize timeIntervalFormatter;


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
    
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",self.feature.user.idd,@"/picture"]];
    self.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
    self.usernameLabel.text =self.feature.user.full_name;
    
//    double num = [self.feature.created_time doubleValue];
//    NSTimeInterval interval=[self.feature.created_time doubleValue];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
//    
//    NSTimeInterval timeInterval = -([date timeIntervalSinceNow]);
//    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
//    [self.creationTime setText:timestamp];
    
    
    self.creationTime.text = @"4w";
    self.standardResolutionImageview.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.feature.images.standard_resolution]];
    if (self.feature.description !=NULL) {
        [self.descriptionTextView setText:self.feature.description];
    }
    
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button addTarget:self
//               action:@selector(showEntryOptions)
//     forControlEvents:UIControlEventTouchDown];
//    [button setTitle:@"Show View" forState:UIControlStateNormal];
//    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
//    [self.view addSubview:button];
    
    

}



- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.standardResolutionImageview;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(IBAction)showActionSheet:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Title" delegate:self cancelButtonTitle:@"Cancel Button" destructiveButtonTitle:@"Destructive Button" otherButtonTitles:@"Other Button 1", @"Other Button 2", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog( @"Destructive Button Clicked");
	} else if (buttonIndex == 1) {
		NSLog( @"Other Button 1 Clicked");
	} else if (buttonIndex == 2) {
		NSLog( @"Other Button 2 Clicked");
	} else if (buttonIndex == 3) {
		NSLog(@"Cancel Button Clicked");
	}
    
	/**
	 * OR use the following switch statement
	 * Suggested by Colin =)
	 */
	/*
     switch (buttonIndex) {
     case 0:
     self.label.text = @"Destructive Button Clicked";
     break;
     case 1:
     self.label.text = @"Other Button 1 Clicked";
     break;
     case 2:
     self.label.text = @"Other Button 2 Clicked";
     break;
     case 3:
     self.label.text = @"Cancel Button Clicked";
     break;
     }
     */
}

@end
