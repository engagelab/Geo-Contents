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


NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id

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
    // Do any additional setup after loading the view from its nib.
    nFeatures = [@[] mutableCopy];
    app = [[UIApplication sharedApplication]delegate];
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];

    CLLocationCoordinate2D coord;
    coord.latitude = 59.927999267f;
    coord.longitude = 10.759999771f;
    
    nFeatures = [ELRESTful fetchPOIsAtLocation:coord];
    
    [self.collectionView reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{
    nFeatures = [NSMutableArray arrayWithArray:app.features];
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return self.albums.count;
    
    return nFeatures.count;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    
    ELFeature *feature = [nFeatures objectAtIndex:indexPath.section];
    cell.userprofileImageView.image = [UIImage imageNamed:@"default_user_icon.jpg"];
    cell.usernameLabel.text = feature.user.full_name;
    
    cell.timeDistance.text = @"4w";
    
    // load the image for this cell
    //NSData *imageData = [NSData dataWithContentsOfURL:feature.standard_resolution];
    //UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    if (feature.standard_resolution != nil) {

    NSString *imageURL = [feature.standard_resolution absoluteString];
    [AFImageDownloader imageDownloaderWithURLString:imageURL autoStart:YES completion:^(UIImage *decompressedImage) {
        cell.standardResolutionImageview.image = decompressedImage;
    }];
    }
    //cell.standardResolutionImageview.image = image;
    NSString *desc = feature.description;
    cell.descriptionLabel.text = desc;
    
    return cell;
}



@end
