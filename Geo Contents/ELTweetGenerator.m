//
//  ELTweetGenerator.m
//  Geo Contents
//
//  Created by spider on 12.02.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELTweetGenerator.h"
#import "ELFeature.h"

@interface ELTweetGenerator()


@end
@implementation ELTweetGenerator



+(NSString*)createHTMLTWeet:(ELFeature*)feature
{
    NSString *htmlTweet = @"";
    
    NSString *userDescription = feature.description;
    if ([userDescription length])
    {
        htmlTweet = [ELTweetGenerator getHTML:userDescription];
    }
    
    if([feature.source_type isEqualToString:@"mapped_instagram"])
    {
        NSString *mapper_description = feature.mapper_description;
        // if mapper_description is not empty
        if ([mapper_description length]) {
            htmlTweet = [htmlTweet stringByAppendingFormat:@"\r\r%@\r%@",
                         @"\t\t---------- Mapper ----------",
                         [ELTweetGenerator getHTML:mapper_description]];
        }
        
    }
    
    
        
    return htmlTweet;
}



+(NSString*)getHTML:(NSString*)tweet
{
    
    NSString *htmlTweet = tweet;
    NSError *error = nil;
    
    NSString *hashTagRegExp = @"#(\\w+)";
    NSString *usernameRegEXp = @"((?<!\\w)@[\\w\\._-]+)";
    
    
    //search for hashtag entries
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:hashTagRegExp options:0 error:&error];
    NSArray *matches = [regex matchesInString:tweet options:0 range:NSMakeRange(0, tweet.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [tweet substringWithRange:wordRange];
        NSLog(@"Found tag %@", word);
        NSString *html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href='http://geocontent/search?tag=",word,"'>",word,"</a>"];
        htmlTweet = [htmlTweet stringByReplacingOccurrencesOfString:word withString:html];
    }
    
    
    //search for usernames entries
    
    regex = [NSRegularExpression regularExpressionWithPattern:usernameRegEXp options:0 error:&error];
    matches = [regex matchesInString:tweet options:0 range:NSMakeRange(0, tweet.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [tweet substringWithRange:wordRange];
        NSLog(@"Found tag %@", word);
        NSString *html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href='http://geocontent/user?name=",word,"'>",word,"</a>"];
        htmlTweet = [htmlTweet stringByReplacingOccurrencesOfString:word withString:html];
        
    }

    return htmlTweet;
}

+(NSString*)createHTMLUserString:(ELFeature*)feature
{
    NSString *userHTML;
    if ([feature.source_type isEqualToString:@"overlay"])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=http://geocontent/user?idd=",feature.user.idd,">",feature.user.full_name,"</a>"];
    }
    else if([feature.source_type isEqualToString:@"Instagram"] || [feature.source_type isEqualToString:@"mapped_instagram"])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://user?username=",feature.user.username,">",feature.user.full_name,"</a>"];

    }
    return userHTML;
}

@end
