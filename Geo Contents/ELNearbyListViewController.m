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



NSString *kCellID = @"cvCell";                          // UICollectionViewCell storyboard id

@interface ELNearbyListViewController ()
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    UIImage *loadingImage;
    
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
                    cell.usernameLabel.text = feature.user.full_name;
                
                    
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
                    [formatter setMaximumFractionDigits:0];
                    
                    cell.timeDistance.text = [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:feature.distance],@"m"];
                    
                    //TODO: to be Fixed to async/cached
                    
                    
                    //cell.descriptionLabel.text = feature.description;
                    
                    cell.standardResolutionImageview.image = image;

                    
                }
                
                
            }
        });
    }];
    
    [self.thumbnailQueue addOperation:operation];
    
    
    // load Images asyc 
//    dispatch_queue_t concurrentQueue =
//    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(concurrentQueue, ^{
//        __block UIImage *image = nil;
//        dispatch_sync(concurrentQueue, ^{
//            /* Download the image here */
//            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feature.standard_resolution]];
//        });
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            /* Show the image to the user here on the main queue*/
//            cell.standardResolutionImageview.image = image;
//        });
//    });
//    
    
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
        
        NSMutableArray *unsortedArrayWithoutDisctanceProperty = [[ELRESTful fetchPOIsAtLocation:_nLocation.coordinate] mutableCopy];
        
        for (ELFeature *feature in unsortedArrayWithoutDisctanceProperty) {
            
            feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
            [nFeatures addObject:feature];
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        [nFeatures sortUsingDescriptors:[NSArray arrayWithObject:sort]];

        
        
        //Cache Images in array to load faster
//        for (ELFeature *featrue in nFeatures)
//        {
//        // load Images asyc
//            dispatch_queue_t concurrentQueue =
//            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            dispatch_async(concurrentQueue, ^{
//                __block UIImage *image = nil;
//                dispatch_sync(concurrentQueue, ^{
//                    /* Download the image here */
//                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:featrue.standard_resolution]];
//                });
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    /* Show the image to the user here on the main queue*/
//                    [images addObject:image];
//                });
//            });
//    
//            
//            
//        }
        
        [self.collectionView reloadData];
    }
    
}




- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    /* Failed to receive user's location */
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
