//
//  ELTweetGenerator.m
//  Geo Contents
//
//  Created by spider on 12.02.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELTweetGenerator.h"
#import "ELFeature.h"
#import "ELConstants.h"

@interface ELTweetGenerator()


@end
@implementation ELTweetGenerator



+(NSString*)createHTMLTWeet:(ELFeature*)feature
{
    NSString *htmlTweet = @"";
    
    NSString *featureDescription;
    

    if([feature.source_type isEqualToString:FEATURE_TYPE_MAPPA])
    {
        featureDescription = [NSString stringWithFormat:@"@%@ %@",feature.user.username,feature.description];
        if ([featureDescription length]) {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:feature.source_type andUser:feature.user];
        }
    }
    else if ([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM])
    {
        featureDescription = [NSString stringWithFormat:@"@%@ %@",feature.user.username,feature.description];
        if ([featureDescription length])
        {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:feature.source_type andUser:feature.user];
        }
    }
    
    
    else if([feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
    {
        featureDescription = [NSString stringWithFormat:@"@%@ %@",feature.user.username,feature.description];
        //FixME: hard coded check, please remove it as soon as possible with a good logic
        // the reason is feature.description is the instagram description in this mapped scenario
        if ([featureDescription length])
        {
            htmlTweet = [ELTweetGenerator getHTML:featureDescription withSourceType:FEATURE_TYPE_INSTAGRAM andUser:feature.mapper];
        }
        
        NSString *mapper_description = [NSString stringWithFormat:@"@%@ %@",feature.mapper.username,feature.mapper_description];;
        // if mapper_description is not empty
        if ([mapper_description length]) {
            htmlTweet = [htmlTweet stringByAppendingFormat:@"\r\r%@\r%@",
                         @"\t",
                         [ELTweetGenerator getHTML:mapper_description withSourceType:feature.source_type andUser:feature.mapper]];
        }
        
    }
    
    return htmlTweet;
}








+(NSString*)getHTML:(NSString*)tweet withSourceType:(NSString*)sourceType andUser:(ELUser*)user
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
        NSString *html;
        if ([sourceType isEqualToString:FEATURE_TYPE_MAPPA] || [sourceType isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM] )
        {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=geocontent://tag?name=",hashtag,">",hashtag,"</a>"];
        }
        else if([sourceType isEqualToString:FEATURE_TYPE_INSTAGRAM])
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
        NSString *html;
        if ([sourceType isEqualToString:FEATURE_TYPE_MAPPA] || [sourceType isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM] ) {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=geocontent://user?username=",username,">",username,"</a>"];
        }
        
        else if([sourceType isEqualToString:FEATURE_TYPE_INSTAGRAM])
        {
            html = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://user?username=",[username substringFromIndex:1],">",username,"</a>"];
            
        }
        
        htmlTweet = [htmlTweet stringByReplacingOccurrencesOfString:username withString:html];
        
    }
    
    
    //NSString *userLink = [ELTweetGenerator createHTMLUserString:user withSourceType:sourceType];
    
    //NSString *descriptionHTML = [userLink stringByAppendingString:htmlTweet];

    return htmlTweet;
}





+(NSString*)createHTMLUserString:(ELUser*)user withSourceType:(NSString*)source_type
{
    NSString *userHTML;
    if ([source_type isEqualToString:FEATURE_TYPE_MAPPA])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%s%@%s",@"<a href=fb://profile/",user.idd,">","<font color=\"B8D336\">",user.full_name,"</font></a>"];

    }
    else if([source_type isEqualToString:FEATURE_TYPE_INSTAGRAM] || [source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
    {
            userHTML = [NSString stringWithFormat:@"<a href=instagram://user?username=%@>%@</a>",user.username,user.full_name];
    }
    return userHTML;
}










+(NSString*)createHTMLUserStringForDescriptionText:(ELFeature*)feature
{
    NSString *userHTML;
    if ([feature.source_type isEqualToString:FEATURE_TYPE_MAPPA])
    {
        /*
         <a href="http://www.yahoo.com"><font color="FF00CC">here</font></a>
         */
        userHTML = [NSString stringWithFormat:@"%@%@%s%s%@%s",@"<a href=geocontent://user/",feature.user.idd,">","<font color=\"B8D336\">",feature.user.full_name,"</font></a>"];
        
        //userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=fb://profile/",feature.user.idd,">",feature.user.full_name,"</a>"];
    }
    else if([feature.source_type isEqualToString:FEATURE_TYPE_INSTAGRAM] || [feature.source_type isEqualToString:FEATURE_TYPE_MAPPED_INSTAGRAM])
    {
        userHTML = [NSString stringWithFormat:@"%@%@%s%@%s",@"<a href=instagram://user?username=",feature.mapper.username,">",feature.mapper.full_name,"</a>"];
        
    }
    
    return userHTML;
}
@end
