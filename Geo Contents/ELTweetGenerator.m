//
//  ELTweetGenerator.m
//  Geo Contents
//
//  Created by spider on 12.02.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELTweetGenerator.h"

@implementation ELTweetGenerator



+(NSString*)createHTMLTWeet:(NSString*)tweet
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

@end
