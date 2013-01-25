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
    
    CLLocationCoordinate2D coord;
    coord.latitude = 59.927999267f;
    coord.longitude = 10.759999771f;
    
    [self loadInstagramPicturesByLocation:coord];
    
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
    
    return nFeatures.count;
}






- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    //BHAlbum *album = self.albums[section];
    //return album.photos.count;
    //return nFeatures.count;
    return 1;
}






- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
//    BHAlbum *album = self.albums[indexPath.section];
//    BHPhoto *photo = album.photos[indexPath.item];
      ELFeature *feature = [nFeatures objectAtIndex:indexPath.section];
    
    
    // load photo images in the background
    __weak ELContentViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:feature.standard_resolution];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        //UIImage *image = [photo image];
        
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
    
    //BHAlbum *album = self.albums[indexPath.section];
    //BHPhoto *photo = album.photos[indexPath.item];
    //detailviewcontroller.imageURL = [photo imageURL];
        
//    ELFeatureViewController *secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];
//    secondView.feature = [nFeatures objectAtIndex:indexPath.section];
    
    
    ELFeatureViewController *secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];
        secondView.feature = [nFeatures objectAtIndex:indexPath.section];

	[self.navigationController pushViewController:secondView animated:YES];
//    ELDetailViewController *secondView = [[ELDetailViewController alloc] initWithNibName:@"ELDetailViewController" bundle:nil];
//    secondView.imageURL = [photo imageURL];
//	[self.navigationController pushViewController:secondView animated:YES];


}






#pragma mark - View Rotation

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//                                duration:(NSTimeInterval)duration
//{
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        self.photoAlbumLayout.numberOfColumns = 3;
//        
//        // handle insets for iPhone 4 or 5
//        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
//        45.0f : 25.0f;
//        
//        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
//        
//    } else {
//        self.photoAlbumLayout.numberOfColumns = 2;
//        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
//    }
//}





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
        [self loadInstagramPicturesByLocation:nLocation.coordinate];
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
//    int distance = [[self getDistanceBetweenPoint1:oLocation Point2:nLocation] integerValue];
//    
//    if (distance > 200) {
//        NSLog(@"you walked 200 meter dude!");
//    }
    
    
    //Check to make sure this is a recent location event
    NSDate *eventDate=nLocation.timestamp;
    NSTimeInterval eventInterval=[eventDate timeIntervalSinceNow];
    if(abs(eventInterval)<30.0){
        //Check to make sure the event is accurate
    
        if(nLocation.horizontalAccuracy>=0 && nLocation.horizontalAccuracy<20)
        {
            //[self loadInstagramPicturesByLocation:nLocation.coordinate];

//                NSNumber *distance = [self getDistanceBetweenPoint1:newLocation Point2:oLocation];
//                NSLog(@"P1:%@ P2:%@ %@",newLocation, oLocation, distance);
            
            
            //self.labelLocation.text=newLocation.description;
            //NSLog(@"%@",newLocation.description);
            //[self notifictationForNewLocation:newLocation];
            
            //fetchPOIs
            //[self fetchPOIsAtLocation:newLocation.coordinate];
            
            
        }
        //[self notifictationForNewLocation:newLocation];
        //[self fetchPOIsAtLocation:newLocation.coordinate];
    }
}












-(NSMutableArray*) fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D
{
    NSMutableArray *photos = [[NSMutableArray alloc]init];
        
    NSString *path = @"/geo/radius/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];

    
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate2D.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate2D.latitude];
    
    NSString *distanceInMeters = [NSString stringWithFormat:@"%f",100.0f];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@%@%@%@%@", requestUrl, lng, @"/",lat,@"/",distanceInMeters];
    
    NSDictionary *json = [self getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    NSMutableArray *elFeatures = [[NSMutableArray alloc]init];
    
    for (NSDictionary *feature in features) {
        
        ELFeature *elFeature = [[ELFeature alloc]init];
        
        // if you want to grab all properties at once then write features
        //NSDictionary *properties = [features valueForKey:@"properties"];
        NSDictionary *properties = [feature valueForKey:@"properties"];
        //search for thumbnail
        NSString *thumbnail =[properties valueForKey:@"thumbnail"];
        
        if (thumbnail != NULL) {
            NSLog(@"%@",thumbnail);
            [photos addObject:thumbnail];
            
            //
            elFeature.thumbnail = [NSURL URLWithString:thumbnail];
        }
        else
        {
            NSString *standardResolution =[properties valueForKey:@"standard_resolution"];
            
            NSLog(@"%@",standardResolution);
            if (standardResolution != NULL) {
                [photos addObject:standardResolution];
                
                //
                elFeature.standard_resolution = [NSURL URLWithString:standardResolution];
            }
        }
    
    //
    elFeature.idd = [properties valueForKey:@"id"];
    elFeature.timeDistance = [properties valueForKey:@"created_time"];
    elFeature.description = [properties valueForKey:@"description"];
    elFeature.source_type = [properties valueForKey:@"source_type"];
    ELUser *user = [[ELUser alloc]init];
    NSDictionary *userD = [properties valueForKey:@"user"];
    user.idd = [userD valueForKey:@"id"];
    user.full_name = [userD valueForKey:@"full_name"];
        elFeature.user = user;
    [elFeatures addObject:elFeature];
    }
    
    nFeatures = elFeatures;
    return photos;
}





- (BOOL) loadInstagramPicturesByLocation:(CLLocationCoordinate2D )coord
{
    
    self.albums = [NSMutableArray array];
    //NSSet *newPhotos = [self fetchPOIsAtLocation:coord];
    
    NSMutableSet * allPhotos = [NSMutableSet setWithArray:self.photos];
    
    [allPhotos addObjectsFromArray:[self fetchPOIsAtLocation:coord]];
    
    //[nFeatures addObjectsFromArray:<#(NSArray *)#>];
    
    //self.photos = [NSMutableArray arrayWithArray:[allPhotos allObjects]];
    
    
    if (self.photos != NULL) {
        for (NSString *url in self.photos)
        {
            //NSString* photoFilename = [photos objectAtIndex:i];
            BHAlbum *album = [[BHAlbum alloc] init];
            NSURL *photoURL = [NSURL URLWithString:url];
            BHPhoto *photo = [BHPhoto photoWithImageURL:photoURL];
            [album addPhoto:photo];
            [self.albums addObject:album];
        }
        
        self.thumbnailQueue = [[NSOperationQueue alloc] init];
        self.thumbnailQueue.maxConcurrentOperationCount = 3;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        
        
    }
    
    //    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
    //        if(results && [results count] > 0)
    //        {
    //            if(![self.searches containsObject:searchTerm])
    //            {
    //                NSLog(@"Found %d photos matching %@",[results count],searchTerm);
    //                [self.searches insertObject:searchTerm atIndex:0];
    //                self.searchResults[searchTerm] = results;
    //            }
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [self.collectionView reloadData];
    //            });
    //
    //        } else {
    //            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
    //        }
    //    }];
    
    //[textField resignFirstResponder];
    return YES;
}






-(NSDictionary *)getJSONResponsetWithURL:(NSString*)url
{
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSError *error;
    NSDictionary *json = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return  json;
}






@end
