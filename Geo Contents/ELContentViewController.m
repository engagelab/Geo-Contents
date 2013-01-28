//
//  ELNearbyViewController.m
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELContentViewController.h"
#import "IMPhotoAlbumLayout.h"
#import "IMAlbumPhotoCell.h"
#import "BHAlbum.h"
#import "BHPhoto.h"

#import "ELFeature.h"


#import "ELFeatureViewController.h"
#import "ELBridgingApp.h"

#import "ELConstants.h"
#import "ELRESTful.h"

/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )



static NSString * const PhotoCellIdentifier = @"PhotoCell";






@interface ELContentViewController ()
{
    CLLocation *oLocation;
    CLLocation *nLocation;
    NSMutableArray  *nFeatures;
}
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, weak) IBOutlet IMPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic, strong) ELFeatureViewController *secondView ;
@end

@implementation ELContentViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ELContentViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [ self startLocationServices];
    
    [self.collectionView registerClass:[IMAlbumPhotoCell class] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    self.photos = [@[] mutableCopy];
    
    //
    nFeatures = [@[] mutableCopy];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    
    
    NSDictionary *bboxt = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"59.927999267f",@"lat1",
                           @"10.759999771f",@"lng1",
                           @"59.928999267f",@"lat2", 
                           @"10.761999771f",@"lng2", 
                          nil];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bbox = [defaults objectForKey:@"bbox"];
    [self loadFeaturesInBoundingBox:bbox];
    

    
    /*  Location service
     Stop CLLOcationManager when you receive notification that your app is resigning active,
     Subscribe to the notifications and provide a method to stop and start location services.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotif:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotif:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // Timer
    oLocation = [[CLLocation alloc]initWithLatitude:59.927999267f longitude:10.759999771f];
    nLocation = [[CLLocation alloc]initWithLatitude:59.927999267f longitude:10.759999771f];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self
                                   selector:@selector(setOldLocationTo:) userInfo:nLocation repeats:YES];
    
    
    UIBarButtonItem *gotoMapViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Mapview" style:UIBarButtonItemStylePlain target:self action:@selector(openMapview)];
    self.navigationItem.rightBarButtonItem = gotoMapViewButton;
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
}


-(void) loadFeaturesInBoundingBox:(NSDictionary*)bbox
{
    //Randomize instagram and overlay pois
    NSArray *results = [ELRESTful fetchPOIsInBoundingBox:bbox];
    nFeatures = [[self shuffleArray:results] mutableCopy];
    
    self.albums = [NSMutableArray array];
    
    for (ELFeature *feature in  nFeatures) {
        BHAlbum *album = [[BHAlbum alloc] init];
        NSURL *photoURL = feature.standard_resolution;
        BHPhoto *photo = [BHPhoto photoWithImageURL:photoURL];
        [album addPhoto:photo];
        [self.albums addObject:album];
        
        [self.collectionView reloadData];
    }
    
}

- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}


-(void) fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D
{
    nFeatures = [ELRESTful fetchPOIsAtLocation:coordinate2D];
    self.albums = [NSMutableArray array];
    
    for (ELFeature *feature in  nFeatures) {
        BHAlbum *album = [[BHAlbum alloc] init];
        NSURL *photoURL = feature.standard_resolution;
        BHPhoto *photo = [BHPhoto photoWithImageURL:photoURL];
        [album addPhoto:photo];
        [self.albums addObject:album];
        
        [self.collectionView reloadData];
    }
}






-(void)openMapview
{
    [ELBridgingApp openMapView];
    
    NSLog(@"goto map view");
}


-(void)viewWillDisappear:(BOOL)animated
{
    //app.features = [nFeatures mutableCopy];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







#pragma mark - UICollectionViewDataSource



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return self.albums.count;
    
    return self.albums.count;
}






- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    BHAlbum *album = self.albums[section];
    return album.photos.count;
    //return nFeatures.count;
    //return 1;
}






- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    BHAlbum *album = self.albums[indexPath.section];
    BHPhoto *photo = album.photos[indexPath.item];
    
    // load photo images in the background
    __weak ELContentViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [photo image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // then set them via the main queue if the cell is still visible.
            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                IMAlbumPhotoCell *cell =
                (IMAlbumPhotoCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                cell.imageView.image = image;
            }
        });
    }];
    
    [self.thumbnailQueue addOperation:operation];
    
    return photoCell;
    
}






- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BHAlbum *album = self.albums[indexPath.section];
    BHPhoto *photo = album.photos[indexPath.item];
    //detailviewcontroller.imageURL = [photo imageURL];
    
    self.secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];

    self.secondView.feature = [nFeatures objectAtIndex:indexPath.section];
//    self.secondView.standardResolutionImageview.image = [photo image];
//    self.secondView.usernameLabel.text = @"fahied";
//    [self.secondView.usernameLabel setText:@"spider"];
    
	[self.navigationController pushViewController:self.secondView animated:YES];
    
    
}






#pragma mark - Location Services


-(void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [self startLocationServices];
}

-(void)appWillResignActiveNotif:(NSNotification*)notif
{
    [self stopLocationServices];
}




/*
 kCLLocationAccuracyBestForNavigation
 kCLLocationAccuracyBest
 kCLLocationAccuracyNearestTenMeters
 kCLLocationAccuracyHundredMeters
 kCLLocationAccuracyKilometer
 kCLLocationAccuracyThreeKilometers
 */
-(void) startLocationServices
{
    
    if(_locationManager==nil){
        //Instantiate _locationManager
        _locationManager = [[CLLocationManager alloc] init];
        //set the accuracy for the signals
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        _locationManager.distanceFilter=1;
        _locationManager.delegate=self;
    }
    //Start updating location
    [_locationManager startUpdatingLocation];
    
}


-(void) stopLocationServices
{
    if (_locationManager != nil) {
        [_locationManager stopUpdatingLocation];
    }
}


#pragma mark - Location Services : delegate



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(error.code == kCLErrorDenied){
        [manager stopUpdatingLocation];
    }
}






- (void)notifictationForNewLocation:(CLLocation *)newLocation
{
    UILocalNotification *locationNotification = [[UILocalNotification alloc]
                                                 init];
    locationNotification.alertBody=[NSString stringWithFormat:@"New Location:%.3f, %.3f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    locationNotification.alertAction=@"Ok";
    locationNotification.soundName = UILocalNotificationDefaultSoundName;
    //Increment the applicationIconBadgeNumber
    locationNotification.applicationIconBadgeNumber=[[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    //[[UIApplication sharedApplication] presentLocalNotificationNow:locationNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
}







/*
 var R = 6371; // km
 var dLat = (lat2-lat1).toRad();
 var dLon = (lon2-lon1).toRad();
 var lat1 = lat1.toRad();
 var lat2 = lat2.toRad();
 
 var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
 Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
 var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
 var d = R * c;
 */
-(NSNumber*)getDistanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}



-(void)setOldLocationTo:(NSTimer*)theTimer
{
    
    int distance = [[self getDistanceBetweenPoint1:nLocation Point2:oLocation] integerValue];
    if (distance > 100) {
        [self fetchPOIsAtLocation:nLocation.coordinate];
    }
    
    if (oLocation == nil) {
        oLocation = [[CLLocation alloc]init];
        oLocation = nLocation;
    }
    else
        oLocation = nLocation;
}




-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    nLocation = [locations lastObject];
    //Check to make sure this is a recent location event
    NSDate *eventDate=nLocation.timestamp;
    NSTimeInterval eventInterval=[eventDate timeIntervalSinceNow];
    if(abs(eventInterval)<30.0){
        //Check to make sure the event is accurate
        
        if(nLocation.horizontalAccuracy>=0 && nLocation.horizontalAccuracy<20)
        {
            
            
        }
        //[self notifictationForNewLocation:newLocation];
        //[self fetchPOIsAtLocation:newLocation.coordinate];
    }
}





@end
