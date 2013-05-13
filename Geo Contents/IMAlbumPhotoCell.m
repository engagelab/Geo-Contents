//
//  IMAlbumPhotoCell.m
//  MyCollectionView
//
//  Created by spider on 12.12.12.
//  Copyright (c) 2012 spider. All rights reserved.
//

#import "IMAlbumPhotoCell.h"

@interface IMAlbumPhotoCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation IMAlbumPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 0.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.layer.shadowOpacity = 0.5f;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
    }
    return self;
}



- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
