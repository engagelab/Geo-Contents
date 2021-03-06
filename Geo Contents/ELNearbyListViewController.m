//
//  ELFeatureCListViewController.m
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELNearbyListViewController.h"



@interface ELNearbyListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray  *features; // feautre list to render on screen
    ELHashedFeatureCVController *hashedFeatureCVController;
    ELUserFeaturesCVController *userFeatureCVController;
}



@end

@implementation ELNearbyListViewController

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
    
    // Ensure features is instantiated before it is used
    features = [@[] mutableCopy];
    
    [self configureCollectionView];
    
    [self refreshCollectionView];
    
    [self addRefreshViewButton];
    

}

- (void)configureCollectionView
{
    /*
     * we're going to use a custom UICollectionViewCell, which will hold
     * option menu
     * user profile picture
     * user proile lable
     * standard resulation image
     * feature source type image
     */
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
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationManager *locationManager = [CLLocationManager new];
        [self showItemsAtLocation:locationManager.location];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UICollectionView delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return self.albums.count;
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger size = features.count;
    
    //[self setTitle:[NSString stringWithFormat:@"%@ (%d)",@"Nearby",size]];
    
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

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


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    ELFeature *feature = [features objectAtIndex:indexPath.item];

    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LISTVIEW_CELL_IDENTIFIER forIndexPath:indexPath];
    if (feature != nil) {
        //pass current feature refrence to cell 
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
        //[cell.userprofileImageView setFrame:CGRectMake(271, 295, 35, 35)];
        
        //clickable user label
        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature.user withSourceType:feature.source_type]];
        cell.usernameLabel.componentsAndPlainText = componentsDS;
        cell.usernameLabel.delegate = self;
        
        cell.timeDistance.text = [NSString stringyfyDistance:feature.distance];
        
        //cell.descriptionLabel.text = feature.description;
        if (feature.description !=NULL) {
            
            NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
            
            RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
            
            CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            
            [cell.descriptionLabel setFrame:CGRectMake(6,355,304,suggestedSize.height)];
            
            cell.descriptionLabel.componentsAndPlainText = componentsDS;
            
            cell.descriptionLabel.delegate = self;
            
        }
        
        [cell.standardResolutionImageview setImageWithURL:feature.images.standard_resolution placeholder:[UIImage imageNamed:@"empty"]];
        
    }
    
    return cell;
    
}



#pragma RECLabel Delegate method, called when user tap on a hashtag / username o
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
            [hashedFeatureCVController setTitle:[NSString stringWithFormat:@"%@%@",@"#",[dict valueForKey:@"name"]]];
            hashedFeatureCVController.hashTag = [dict valueForKey:@"name"];
            [self.navigationController pushViewController:hashedFeatureCVController animated:YES];
        }
        if ([[urlp host] isEqualToString:@"user"])
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


// refresh view by loading new features for the new location
- (void)showItemsAtLocation:(CLLocation*)newLocation
{
    //Empty the view
    [features removeAllObjects];
    [self.collectionView reloadData];
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    // Fetch the content on a worker thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *unsortedArrayWithoutDisctanceProperty = [[ELRESTful fetchPOIsAtLocation:newLocation.coordinate] mutableCopy];
        // Calculate the distance for each feature
        for (ELFeature *feature in unsortedArrayWithoutDisctanceProperty) {
            feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
            [temp addObject:feature];
        }
        // Sort all features by distance
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        [temp sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        // Ensure the new data is used in the collection view
        [features removeAllObjects];
        [features addObjectsFromArray:temp];
        // Register the content on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}



//return distance between two locations in meters
-(NSNumber*)distanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}



@end
