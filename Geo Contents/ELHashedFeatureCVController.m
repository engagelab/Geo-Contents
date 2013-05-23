//
//  ELHashedFeatureCVController.m
//  Geo Contents
//
//  Created by spider on 07.03.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELHashedFeatureCVController.h"
#import "ELRESTful.h"
#import "Cell.h"
#import "ELTweetGenerator.h"
#import "NSDate+Helper.h"
#import "JMImageCache.h"
#import "ELContentViewController.h"
#import "ELConstants.h"

@interface ELHashedFeatureCVController ()
{
    NSMutableArray  *nFeatures;
    ELRESTful *restfull;
    UIImage *loadingImage;
    NSString *kCellID;
}

@end

@implementation ELHashedFeatureCVController
@synthesize hashTag;

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
    // Do any additional setup after loading the view from its nib.
    // Ensure nFeatures is instantiated before it is used
    nFeatures = [@[] mutableCopy];
    kCellID = @"cvCell";
    
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 450)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self showItemsAtLocation:@"testing"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma Collection View Implementaion

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
    suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(304, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(320.f, 380.f + suggestedSize.height);
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
    if (feature != nil) {
        
        cell.feature = feature;
        NSURL *profileURL;
        if ([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM]) {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"instagram.png"];
            profileURL = [NSURL URLWithString:feature.user.profile_picture];
        }
        else
        {
            cell.sourceTypeImageView.image = [UIImage imageNamed:@"mappa.png"];
            profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://graph.facebook.com/",feature.user.idd,@"/picture"]];
        }
        cell.userprofileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
        //[cell.userprofileImageView setFrame:CGRectMake(271, 295, 35, 35)];
        
        
        //clickable user label
        RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:[ELTweetGenerator createHTMLUserString:feature.user withSourceType:feature.source_type]];
        cell.usernameLabel.componentsAndPlainText = componentsDS;
        //        [cell.usernameLabel setTextColor:[UIColor redColor]];
        //        UIColor *test = cell.usernameLabel.textColor;
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
            CGSize suggestedSize = [componentsDS.plainTextData sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(304, FLT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            
            [cell.descriptionLabel setFrame:CGRectMake(6,355,304,suggestedSize.height)];
            
            cell.descriptionLabel.componentsAndPlainText = componentsDS;
            
            cell.descriptionLabel.delegate = self;
            
        }
        [cell.standardResolutionImageview setImageWithURL:feature.images.standard_resolution placeholder:[UIImage imageNamed:@"placeholder"]];
        
    }
    
    return cell;
    
}



- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    NSLog(@"%@",url);
    NSURL *urlp = [NSURL URLWithString:url];
    NSDictionary *dict = [ELRESTful parseQueryString:[urlp query]];
    
    if ([url hasPrefix:@"instagram"]) {
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
    }
    
    if ([url hasPrefix:@"geocontent"]) {
        
        NSLog(@"%@",@"send to content view");
        
        if ([[urlp host] isEqualToString:@"tag"])
        {
            NSLog(@"%@",@"Your have a user");
            
            ELHashedFeatureCVController *child = [[ELHashedFeatureCVController alloc]initWithNibName:@"ELHashedFeatureCVController" bundle:nil];
            [child setTitle:[dict valueForKey:@"name"]];
            child.hashTag = [dict valueForKey:@"name"];
            [self.navigationController pushViewController:child animated:YES];
        }
        
    }
    if ([url hasPrefix:@"fb"]) {
        
        NSLog(@"%@",@"facebook");
        if ([[UIApplication sharedApplication] canOpenURL:urlp]) {
            [[UIApplication sharedApplication] openURL:urlp];
        }
        
    }
    
}



- (void)showItemsAtLocation:(NSString*)hashTAG
{
    //FIXME: remove the need to duplicate the hashTag value
    hashTAG = hashTag;
    
    //Empty the view
    [nFeatures removeAllObjects];
    [self.collectionView reloadData];
    
    // Fetch the content on a worker thread
        
        nFeatures = [[ELRESTful fetchFeaturesWithHashtag:hashTAG] mutableCopy];
        // Sort all features by distance
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
            [nFeatures sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            // Ensure the new data is used in the collection view
            [self.collectionView reloadData];

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
