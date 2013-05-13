//
//  ELTweetGenerator.h
//  Geo Contents
//
//  Created by spider on 12.02.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELFeature.h"

@interface ELTweetGenerator : NSObject

+(NSString*)createHTMLUserString:(ELUser*)user withSourceType:(NSString*)source_type;
+(NSString*)createHTMLTWeet:(ELFeature*)feature;


@end
