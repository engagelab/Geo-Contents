//
//  ELFIMappaSession.h
//  Streetscape
//
//  Created by Martin Havnør on 6/5/13.
//  Copyright (c) 2013 Faster Imaging. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELFIMappaSession : NSObject

+(NSURL*)urlByAddingCurrentSessionToURL:(NSURL*)url;
+(NSURL*)urlByAddingCurrentSessionToURLAsRoute:(NSURL*)url;


+(NSArray*)currentSessionJson;

@end
