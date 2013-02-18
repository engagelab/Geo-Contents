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
    
    NSString *featureDescription;
    

    if([feature.source_type isEqualToString:@"overlay"])
    {
        featureDescription = feature.description;
        if ([featureDescription length]) {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:feature.source_type];
        }
    }
    else if ([feature.source_type isEqualToString:@"Instagram"])
    {
        featureDescription = feature.description;
        if ([featureDescription length])
        {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:feature.source_type];
        }
    }
    
    
    else if([feature.source_type isEqualToString:@"mapped_instagram"])
    {
        featureDescription = feature.description;
        //FixME: hard coded check, please remove it as soon as possible with a good logic
        // the reason is feature.description is the instagram description in this mapped scenario
        if ([featureDescription length])
        {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:@"Instagram"];
        }
        
        NSString *mapper_description = feature.mapper_description;
        // if mapper_description is not empty
        if ([mapper_description length]) {
            htmlTweet = [htmlTweet stringByAppendingFormat:@"\r\r%@\r%@",
                         @"\t\t---------- Mapper ----------",
                         [ELTweetGenerator getHTML:mapper_description withSourceType:feature.source_type]];
        }
        
    }
    
    
        
    return htmlTweet;
}



+(NSString*)getHTML:(NSString*)tweet withSourceType:(NSString*)sourceType
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
        NSString* hashtag = [tweet substringWithRange:wordRange];
        NSLog(@"Found tag %@", hashtag);
        NSString *html;
        if ([sourceType isEqualToString:@"overlay"] || [sourceType isEqualToString:@"mapped_instagram"] ) {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=geocontent://tage?name=",hashtag,">",hashtag,"</a>"];
        }
        else if([sourceType isEqualToString:@"Instagram"])
        {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://tag?name=",hashtag,">",hashtag,"</a>"];

        }
        
        htmlTweet = [htmlTweet stringByReplacingOccurrencesOfString:hashtag withString:html];
    }
    
    
    //search for usernames entries
    
    regex = [NSRegularExpression regularExpressionWithPattern:usernameRegEXp options:0 error:&error];
    matches = [regex matchesInString:tweet options:0 range:NSMakeRange(0, tweet.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* username = [tweet substringWithRange:wordRange];
        NSLog(@"Found tag %@", username);
        NSString *html;
        if ([sourceType isEqualToString:@"overlay"] || [sourceType isEqualToString:@"mapped_instagram"] ) {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=geocontent://user?username=",username,">",username,"</a>"];
        }
        else if([sourceType isEqualToString:@"Instagram"])
        {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://user?username=",[username substringFromIndex:1],">",username,"</a>"];
            
        }
        
        htmlTweet = [htmlTweet stringByReplacingOccurrencesOfString:username withString:html];
        
    }

    return htmlTweet;
}

+(NSString*)createHTMLUserString:(ELFeature*)feature
{
    NSString *userHTML;
    if ([feature.source_type isEqualToString:@"overlay"])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=geocontent://user?idd=",feature.user.idd,">",feature.user.full_name,"</a>"];
    }
    else if([feature.source_type isEqualToString:@"Instagram"] || [feature.source_type isEqualToString:@"mapped_instagram"])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://user?username=",feature.user.username,">",feature.user.full_name,"</a>"];

    }
    return userHTML;
}

@end
