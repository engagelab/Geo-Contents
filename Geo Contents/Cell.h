/*
     File: Cell.h

 */

#import <UIKit/UIKit.h>
#import "ELFeature.h"

@interface Cell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userprofileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeDistance;


@property (strong, nonatomic) IBOutlet UIImageView *standardResolutionImageview;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;





@end
