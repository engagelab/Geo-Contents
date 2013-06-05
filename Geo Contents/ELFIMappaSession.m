//
//  ELFIMappaSession.m
//  Streetscape
//
//  Created by Martin Havnør on 6/5/13.
//  Copyright (c) 2013 Faster Imaging. All rights reserved.
//

#import "ELFIMappaSession.h"
#import "ELConstants.h"

@implementation ELFIMappaSession

+(NSURL*)urlByAddingCurrentSessionToURL:(NSURL*)url {
    // Get the shared groups
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *groups = [defaults objectForKey:SHARED_DICT_FB_SESSION_ID_LIST_KEY];
    // If no groups, don't modify the url
    if(groups.count < 1)
        return url;
    // Start by adding all ids except the last one (avoid issues with the comma separator)
    NSString *groupIds = @"";
    for(int i=0;i<groups.count - 1;i++) {
        NSDictionary *groupAtI = [groups objectAtIndex:i];
        NSString *groupIdAtI = [groupAtI objectForKey:@"id"];
        groupIds = [groupIds stringByAppendingFormat:@"%@,", groupIdAtI];
    }
    // Add the last group id
    NSDictionary *lastGroup = [groups objectAtIndex:groups.count - 1];
    NSString *groupIdAtI = [lastGroup objectForKey:@"id"];
    groupIds = [groupIds stringByAppendingString:groupIdAtI];
    // Form a new url by adding the group ids
    NSString *modified = url.absoluteString;
    // Check whether there are existing parameters already
    BOOL hasParams = [modified rangeOfString:@"?"].location != NSNotFound;
    NSString *separator = (hasParams ? @"&" : @"?");
    // Add the sessions and return
    modified = [modified stringByAppendingFormat:@"%@sessions=%@", separator, groupIds];
    return [NSURL URLWithString:modified];
}

+(NSArray*)currentSessionJson {
    // Get the shared groups
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *groups = [defaults objectForKey:SHARED_DICT_FB_SESSION_ID_LIST_KEY];
    // If no groups, don't modify the url
    if(groups.count < 1)
        return nil;
    // Create an nsdictionary containing json-formatted data for all valid groups (invalid groups will never be in the shared user defaults)
    NSMutableArray *sessions = [NSMutableArray arrayWithCapacity:groups.count];
    for(int i=0;i<groups.count;i++) {
        NSDictionary *groupAtI = [groups objectAtIndex:i];
        NSString *groupIdAtI = [groupAtI objectForKey:@"id"];
        NSString *name = [groupAtI objectForKey:@"name"];
        NSNumber *adminValue = [groupAtI objectForKey:@"administrator"];
        NSMutableDictionary *dictForGroupAtI = [NSMutableDictionary dictionaryWithCapacity:10];
        [dictForGroupAtI setObject:groupIdAtI forKey:@"id"];
        [dictForGroupAtI setObject:name forKey:@"name"];
        [dictForGroupAtI setObject:adminValue forKey:@"administrator"];
        [sessions addObject:dictForGroupAtI];
    }
    return sessions;
}
    
@end
