//
//  ELFeatureCListViewController.m
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELNearbyListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ELRESTful.h"
#import "Cell.h"
#import "ELTweetGenerator.h"
#import "JMImageCache.h"


NSString *kCellID = @"cvCell";                          // UICollectionViewCell storyboard id

@interface ELNearbyListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    UIImage *loadingImage;
    NSMutableArray *images;
    
}

@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@end

@implementation ELNearbyListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loadingImage = [UIImage imageNamed:@"loadingImage.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Ensure nFeatures is instantiated before it is used
    nFeatures = [@[] mutableCopy];
    
    //Start Location Services
    if ([CLLocationManager locationServicesEnabled]){
        CLLocationManager *locationManager = [CLLocationManager new];
        [self showItemsAtLocation:locationManager.location];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 450)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
}







-(void)viewDidAppear:(BOOL)animated
{
    //nFeatures = [NSMutableArray arrayWithArray:app.features];
    //[self.collectionView reloadData];
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
    NSInteger size = nFeatures.count;
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    CGSize suggestedSize;
        
        NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
        
        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
        //find the height of RTLabel
        suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(320.f, 400.f + suggestedSize.height);
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //    if (self.nLocation == nil) {
    //        [self.collectionView reloadData];
    //    }
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    
    
    static NSString *cellIdentifier = @"cvCell";
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // load photo images in the background
    __weak ELNearbyListViewController *weakSelf = self;
    __block UIImage *image = nil;
    
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feature.images.standard_resolution]];
        dispatch_async(dispatch_get_main_queue(), ^{
            // then set them via the main queue if the cell is still visible.
            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                Cell *cell =
                (Cell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                
                if (feature != nil) {
                    
                    cell.feature = feature;
                    NSURL *profileURL;
                    if ([feature.source_type isEqualToString:@"Instagram"]) {
                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
                        profileURL = [NSURL URLWithString:feature.user.profile_picture];
                    }
                    else
                    {
                        cell.sourceTypeImageView.image = [UIImage imageNamed:@"overlay.png"];
                        profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
                    }
                    cell.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
                    
                    
                    //clickable user label
                    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature]];
                    cell.usernameLabel.componentsAndPlainText = componentsDS;
                    cell.usernameLabel.delegate = self;
                    
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
                    [formatter setMaximumFractionDigits:0];
                    
                    cell.timeDistance.text = [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:feature.distance],@"m"];
                    
                    //cell.descriptionLabel.text = feature.description;
                    if (feature.description !=NULL) {
                        
                        NSString *htmlTweet =[ELTweetGenerator createHTMLTWeet:feature];
                        
                        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:htmlTweet];
                        //find the height of RTLabel
                        CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(306, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
                        
                        [cell.descriptionLabel setFrame:CGRectMake(6,355,300,suggestedSize.height)];
                        
                        cell.descriptionLabel.componentsAndPlainText = componentsDS;
                        
                        cell.descriptionLabel.delegate = self;
                        
                    }
                    
                    cell.standardResolutionImageview.image = image;
                    
                    
                }                
            }
        });
    }];
    
    [self.thumbnailQueue addOperation:operation];
    

    return cell;

}








- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    NSLog(@"%@",url);
    NSURL *urlp = [NSURL URLWithString:url];
    if ([url hasPrefix:@"instagram"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
    }
    if ([url hasPrefix:@"content"]) {
        
        NSLog(@"%@",@"send to content view");

    }
    
}


- (void)showItemsAtLocation:(CLLocation*)newLocation {
    // Fetch the content on a worker thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *unsortedArrayWithoutDisctanceProperty = [[ELRESTful fetchPOIsAtLocation:newLocation.coordinate] mutableCopy];
        // Register the content on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // Calculate the distance for each feature
            for (ELFeature *feature in unsortedArrayWithoutDisctanceProperty) {
                feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
                [nFeatures addObject:feature];
            }
            // Sort all features by distance
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
            [nFeatures sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            // Ensure the new data is used in the collection view
            [self.collectionView reloadData];
        });
    });
}




-(NSNumber*)distanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}







@end
