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

#import "ELFeature.h"


#import "ELFeatureViewController.h"
#import "ELBridgingApp.h"

#import "ELConstants.h"
#import "ELRESTful.h"

#import "JMImageCache.h"

#import "CoreLocationUtils/CLLocation+measuring.h"



static NSString * const PhotoCellIdentifier = @"PhotoCell";



/*
 *  Mosaic View
 *
 *  Discussion:
 *      Display geo-features in a grid of 3XN called mosaic view which is vertically scrolable. It is based on the UICollectionView Controller.
 *  Main Functions:
 *      1 - display POIs thumbnails on mosaic within Rectangular geographical region termed as Bounding Box provided by the Map View.
 *      2 - display POIs thumbnails on mosaic accordingn to user location and update the view as the user move
 *  Classes Used:
 *      IMPhotoAlbumLayout  : define how the mosaic view should look.
 *      IMAlbumPhotoCell    : a custom cell view for each item in the mosaic.
 *      ELFeature           : a model class to hold the feature object recived from Json response from server
 *      ELFeatureViewController :   the view controller shows the details description and high resolution image of the selected POI
 *      ELBridgingApp       : this class take advantage of cocoa touch Custom URL Schema and transfer controll from one app to another app or within one app.
 *      ELConstants         : most of the application constants are defined inside this class
 *      ELRESTful           : This handle all sort of client/server communication, also responsible for parsing json response to Feature Model 
 *      JMImageCache        : NSCache based remote-image caching and downloading mechanism for iOS.
 *      CoreLocationUtils/CLLocation+measuring : Adds capabilities to measure distance and direction from other locations, define bounding box, and more.
 */
@interface ELContentViewController ()
{
    CLLocation *previousLocation;           //keep track of user last location of content update
    CLLocation *newLocation;                // location of user after every 20 seconds
    NSMutableArray  *features;              // feautre list to render on screen
    UILabel *distanceCoveredLabel;          // display how much distance a uers covered in last 20 sec
    BOOL isUserAtCurrentLocation;           // flag that keep user current location YES/NO
    IMPhotoAlbumLayout *photoAlbumLayout;   // a custom cell view for each item in the mosaic.
    ELFeatureViewController *secondView;    // the view controller shows the details description and high resolution image of the selected POI

}
    

@end





@implementation ELContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ELContentViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start location services
    [ self startLocationServices];
        
    // initialze 
    features = [@[] mutableCopy];
    
    
    /*  Location service
     Stop CLLOcationManager when you receive notification that your app is resigning active,
     Subscribe to the notifications and provide a method to stop and start location services.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotif:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotif:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // configure collectionview to load features
    [self configureCollectionView];
        
    //for test purpose only display distance covered in 10 sec by a user
    distanceCoveredLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 300, 60, 20)];
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Collection view methods


- (void)configureCollectionView
{
    [self.collectionView registerClass:[IMAlbumPhotoCell class] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    // Add background image to collection view
    self.collectionView.backgroundView =[[UIView alloc]initWithFrame:self.collectionView.bounds];
    UIImageView *background_image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mosaic_bg3x107"]];
    [self.collectionView.backgroundView addSubview:background_image];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

//called when the application becomes active.
-(void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [self startLocationServices];
}

// called when the application is no longer active and loses focus.
-(void)appWillResignActiveNotif:(NSNotification*)notif
{
    [self stopLocationServices];
}




#pragma mark - UICollectionView delegate methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return features.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMAlbumPhotoCell *mosiacCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    ELFeature *feature = [features objectAtIndex:indexPath.section];
    
    //load images using JMImageCache liberary. Awesome :)
    [mosiacCell.imageView setImageWithURL:feature.images.thumbnail placeholder:[UIImage imageNamed:@"placeholder"]];
    
    // differentiate external POIs with 60% alpha
    if ([feature.source_type isEqualToString:FEATURE_TYPE_MAPPA] || [feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
    {
        mosiacCell.imageView.alpha = 1.0;
    }
    else
        mosiacCell.imageView.alpha = 0.6;
    
    return mosiacCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELFeature *feature = [features objectAtIndex:indexPath.section];
    
    feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];

    secondView = [[ELFeatureViewController alloc] initWithNibName:@"ELFeatureViewController" bundle:nil];
    secondView.feature = feature;
	[self.navigationController pushViewController:secondView animated:YES];
}




#pragma mark - Location Services

-(void) startLocationServices
{
    
    if(_locationManager==nil){
        //Instantiate _locationManager
        _locationManager = [[CLLocationManager alloc] init];
        
        //set the accuracy for the signals
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        
        //The distanceFilter property defines the minimum distance a device has to move horizontally
        // before an update event is produced.
        _locationManager.distanceFilter = 10;
        
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



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // refuses events older than 5 seconds:
    if (abs(howRecent) < 15.0)
    {
        //runs only first time and as the app have no previous location
        if (previousLocation == nil)
        {
            //set the first location update to it.
            previousLocation = [locations lastObject];

            //check if the bounding box selected by user in mapview matches his current location
            if ([CLLocation boundingBox:[self boundingBoxFromNSUserDefaults] ContainsCLLocation:[locations lastObject]] && isUserAtCurrentLocation == NO)
            {
                //if bounding box and current location matches then sent flag to YES
                isUserAtCurrentLocation = YES;
            }
            
            //update the mosaic view according to user location if bounding box and current userlocation matches
            if (isUserAtCurrentLocation)
            {
                // Create a new private queue
                dispatch_queue_t myBackgroundQueue;
                myBackgroundQueue = dispatch_queue_create("engagelab.fetchPOIsAtLocation", NULL);
                
                dispatch_async(myBackgroundQueue, ^(void) {
                    
                    // downlaod features async on secondary thread
                    features=  [ELRESTful fetchPOIsAtLocation:location.coordinate];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // update user interface on main thread to avoid deley in loading UI
                        [self.collectionView reloadData];
                    });
                });
                
            }
            
            // load features withing bounding box if the bounding box and user current location does not match
            else
            {
                [self startViewWithBoundingBox:[self boundingBoxFromNSUserDefaults]];
                //stop location services as we will not update view if the match was NO
                [self stopLocationServices];
            }
            
        }
        
         //start updating the mosaic view dynamically if bounding box and current userlocation  was matched in first location update
        if (isUserAtCurrentLocation)
        {
            // find the distance covered since last location update
            NSNumber *distanceCovered = [self distanceBetweenPoint1:previousLocation Point2:location];
            
            // find the time passed since last location update
            NSTimeInterval timeElepsed = [previousLocation.timestamp timeIntervalSinceNow];
            
            if ([distanceCovered intValue] >= 10 || abs(timeElepsed) > 20.0)
            {
                //swipe previous with new location and update new location
                previousLocation = newLocation;
                newLocation = location;
                
                //Refresh view with new Features at this position
                [self refreshView:newLocation];
                
                // Placed label for testing purpose only : remove it in release verion
                distanceCoveredLabel.text = [distanceCovered stringValue];
                [self.collectionView addSubview:distanceCoveredLabel];
                
                [self refreshView:newLocation];
            }
        }
    }
}



-(void)refreshView:(CLLocation*)location
{
    //TODO: make this operation on secondary thread
    NSMutableArray *newFeatures = [ELRESTful fetchPOIsAtLocation:location.coordinate];
    //Compare if restults are diffirent
    if ([self foundNewEntriesIn:newFeatures withOldResults:features])
    {
        //assign new resluts to features
            features = newFeatures;
        //refresh view with new features
            [self.collectionView reloadData];
    }

}

#pragma Collectionview 
-(void)startViewWithBoundingBox:(NSDictionary*)bbox
{
    
    // Create a new private queue
    dispatch_queue_t myBackgroundQueue;
    myBackgroundQueue = dispatch_queue_create("engagelab.loadFeaturesInBoundingBox", NULL);
  
        dispatch_async(myBackgroundQueue, ^(void) {
            
            // do some time consuming things here
            [self loadFeaturesInBoundingBox:bbox];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // do some things here in the main queue
                // for example: update UI controls, etc.
                [self.collectionView reloadData];
            });
        });
        
}

-(NSDictionary*)boundingBoxFromNSUserDefaults
{
    // dafualt boounding box in case GPS does not work
    NSDictionary *defaultBBox = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"59.943072f",@"lat1",
                                 @"10.715114f",@"lng1",
                                 @"59.941095f",@"lat2",
                                 @"10.717839f",@"lng2",
                                 nil];
    // fetch the bounding box dictionary from the NSUserDefaults being sent by Mappa
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bbox = [defaults objectForKey:@"bbox"];
    
    if (bbox != nil) {
        return bbox;
    }
    
return defaultBBox;
}




-(void) loadFeaturesInBoundingBox:(NSDictionary*)bbox
{
    //TODO: make this operation on secondary thread
    NSArray *results = [ELRESTful fetchPOIsInBoundingBox:bbox];
    // find the distance of each indivitual feature from user current location and add into Feature model
    for (ELFeature *feature in results)
    {
        feature.distance = [self distanceBetweenPoint1:newLocation Point2:feature.fLocation];
        [features addObject:feature];
    }
    //Randomize instagram and overlay pois
    features = [[self shuffleArray:results] mutableCopy];
}








#pragma utility methods

-(NSNumber*)distanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2
{
    double meters1 = [point1 distanceFromLocation:point2];
    
    double meters2 = [point2 distanceFromLocation:point1];
    
    double meters = (meters1 + meters2)/2;
    
    NSNumber *distance = [NSNumber numberWithDouble:meters];
    
    return distance;
}


- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}


-(BOOL)foundNewEntriesIn:(NSMutableArray*)newArray withOldResults:(NSMutableArray*)oldArray
{
    
    NSMutableSet *newSet = [NSMutableSet setWithArray: newArray];
    NSSet *oldSet = [NSSet setWithArray: oldArray];
    [newSet minusSet: oldSet];
    if (newSet.count > 0) {
        return YES;
    }
    
    return NO;
}



@end

