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

#import "ENCListLayout.h"
#import "ELAppDelegate.h"
#import "AFImageDownloader.h"


NSString *kCellID = @"cvCell";                          // UICollectionViewCell storyboard id

@interface ELNearbyListViewController ()
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    ELAppDelegate *app;
    
}
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;


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
    
    
    // Do any additional setup after loading the view from its nib.
    nFeatures = [@[] mutableCopy];
    app = [[UIApplication sharedApplication]delegate];
    
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //    if (self.nLocation == nil) {
    //        [self.collectionView reloadData];
    //    }
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.item];
    
    
    static NSString *cellIdentifier = @"cvCell";
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // load photo images in the background
    __weak ELNearbyListViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        //UIImage *image = [photo image];
        
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
                    cell.usernameLabel.text = feature.user.full_name;
                    
                    
                    NSNumber *distance = [self getDistanceBetweenPoint1:self.nLocation Point2:feature.fLocation];
                    
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
                    [formatter setMaximumFractionDigits:0];
                    
                    cell.timeDistance.text = [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:distance],@"m"];
                    
                    //TODO: to be Fixed to async/cached
                    cell.standardResolutionImageview.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feature.standard_resolution]];
                    
                    cell.descriptionLabel.text = feature.description;
                    
                }

                
            }
        });
    }];
    
    [self.thumbnailQueue addOperation:operation];
    
    return cell;
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    /* We received the new location */
    CLLocation * newLocation = [locations lastObject];
    
    if (!haveLocation) {
        _nLocation = newLocation;
        haveLocation = YES;
        NSLog(@"Latitude = %f", _nLocation.coordinate.latitude);
        NSLog(@"Longitude = %f", _nLocation.coordinate.longitude);
        
        nFeatures = [[ELRESTful fetchPOIsAtLocation:_nLocation.coordinate] mutableCopy];
        [self.collectionView reloadData];
    }
    
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
