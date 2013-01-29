/*
     File: Cell.h

 */

#import <UIKit/UIKit.h>
#import "ELFeature.h"

@interface Cell : UICollectionViewCell<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *userprofileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeDistance;
@property (strong, nonatomic) IBOutlet UIImageView *standardResolutionImageview;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sourceTypeImageView;


-(IBAction)showActionSheet:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;




@end
