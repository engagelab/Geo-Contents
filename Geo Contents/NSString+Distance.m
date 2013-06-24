//
//  NSString+Distance.m
//  Geo Contents
//
//  Created by spider on 24.06.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "NSString+Distance.h"

@implementation NSString (Distance)

+(NSString*)stringyfyDistance:(NSNumber*)distance
{
    NSString *stringDistance;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    
    double cDistance = [distance doubleValue];
    if (cDistance > 999)
    {
        [formatter setMaximumFractionDigits:2];
        stringDistance= [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:[NSNumber numberWithDouble:(cDistance/1000.0)]],@"km"];
        return stringDistance;
    }
    [formatter setMaximumFractionDigits:0];
    stringDistance = [NSString stringWithFormat:@"%@%@",[formatter  stringFromNumber:distance],@"m"];
    
    return stringDistance;
}

@end
