/*
     File: Cell.m

 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "Cell.h"
#import "CustomCellBackground.h"

@implementation Cell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}




@end
