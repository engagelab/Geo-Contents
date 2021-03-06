//
//  ELRecentListViewController.m
//  Geo Contents
//
//  Created by spider on 30.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELRecentListViewController.h"





@interface ELRecentListViewController ()
{
    NSMutableArray  *features; //holds the feature list
    ELHashedFeatureCVController *hashedFeatureCVController;
    ELUserFeaturesCVController *userFeatureCVController;
    
}



@end

@implementation ELRecentListViewController

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
    features = [@[] mutableCopy];
    
    [self configureCollectionView];
    
    [self refreshCollectionView];
    
    [self addRefreshViewButton];
    
}


- (void)configureCollectionView
{
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:LISTVIEW_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 450)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)addRefreshViewButton
{
    // Refresh button to update list
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshCollectionView)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}


-(void)refreshCollectionView
{
    if ([CLLocationManager locationServicesEnabled]){
        CLLocationManager *locationManager = [CLLocationManager new];
        [self showItemsAtLocation:locationManager.location];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
}


#pragma UICollectionView Delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return self.albums.count;
    
    return 1;
}



- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger size = features.count;
    return size;
}



//recalculate the size of the CELL runtime to fit the content in it
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELFeature *feature = [features objectAtIndex:indexPath.item];
    CGSize suggestedSize;
    
    NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
    
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
    //find the height of RTLabel
    suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(304, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(320.f, 380.f + suggestedSize.height);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ELFeature *feature = [features objectAtIndex:indexPath.item];
    
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LISTVIEW_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (feature != nil) {
        
        cell.feature = feature;
        NSURL *profileURL;
        if ([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM])
        {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram"];
            profileURL = [NSURL URLWithString:feature.user.profile_picture];
        }
        else if ([feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
        {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"mapped_instagram"];
            profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
        }
        
        else
        {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"mappa"];
            profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
        }
        cell.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
        
        //clickable user label
        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature.user withSourceType:feature.source_type]];
        cell.usernameLabel.componentsAndPlainText = componentsDS;
        cell.usernameLabel.delegate = self;
        
        //: formate time using Utitlity category NSDATE+Helper
        NSTimeInterval timeInterval = (double)([feature.time unsignedLongLongValue]);
        NSDate *theDate = [[NSDate alloc]initWithTimeIntervalSince1970: timeInterval];
        NSString *displayString = [NSDate stringForDisplayFromDate:theDate];
        
        cell.timeDistance.text = displayString;
        
        if (feature.description !=NULL) {
            
            NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
            
            RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
            //find the height of RTLabel
            CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            
            [cell.descriptionLabel setFrame:CGRectMake(6,355,304,suggestedSize.height)];
            
            cell.descriptionLabel.componentsAndPlainText = componentsDS;
            
            cell.descriptionLabel.delegate = self;
            
        }
        [cell.standardResolutionImageview setImageWithURL:feature.images.standard_resolution placeholder:[UIImage imageNamed:@"empty"]];
    }
    
    return cell;
    
}




- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    NSURL *urlp = [NSURL URLWithString:url];
    NSDictionary *dict = [ELRESTful parseQueryString:[urlp query]];
    
    if ([url hasPrefix:@"instagram"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
    }
    
    if ([url hasPrefix:@"geocontent"]) {
        
        if ([[urlp host] isEqualToString:@"tag"])
        {
            hashedFeatureCVController = [[ELHashedFeatureCVController alloc]initWithNibName:@"ELHashedFeatureCVController" bundle:nil];
            [hashedFeatureCVController setTitle:[dict valueForKey:@"name"]];
            hashedFeatureCVController.hashTag = [dict valueForKey:@"name"];
            [self.navigationController pushViewController:hashedFeatureCVController animated:YES];
        }
        else if ([[urlp host] isEqualToString:@"user"])
        {
            userFeatureCVController = [[ELUserFeaturesCVController alloc]initWithNibName:@"ELUserFeaturesCVController" bundle:nil];
            [userFeatureCVController setTitle:[dict valueForKey:@"username"]];
            userFeatureCVController.userName = [dict valueForKey:@"username"];
            [self.navigationController pushViewController:userFeatureCVController animated:YES];
        }
        
    }
    if ([url hasPrefix:@"fb"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
        
    }
    
}





- (void)showItemsAtLocation:(CLLocation*)newLocation {
    [features removeAllObjects];
    [self.collectionView reloadData];
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    
    // Fetch the content on a worker thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [temp addObjectsFromArray: [ELRESTful fetchRecentlyAddedFeatures:newLocation.coordinate]];
        // Register the content on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
            [temp sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            [features removeAllObjects];
            [features addObjectsFromArray:temp];
            // Ensure the new data is used in the collection view
            [self.collectionView reloadData];
        });
    });
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    /* Failed to receive user's location */
}




-(NSNumber*)getDistanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}





@end
