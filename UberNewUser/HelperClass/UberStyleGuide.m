//
//  UberStyleGuide.m
//  UberforXOwner
//
//  Created by Elluminati - macbook on 08/01/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "UberStyleGuide.h"

@implementation UberStyleGuide

#pragma mark- Color

+(UIColor *)colorDefault

{
   UIColor *regularColor= [UIColor colorWithRed:(255/255.0f) green:(156/255.0f) blue:(62/255.0f) alpha:1.0];
    return regularColor;
}

#pragma mark - Fonts

+ (UIFont *)fontRegularLight {
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:15.0f];
}

+ (UIFont *)fontRegular {
    //return [UIFont fontWithName:@"OpenSans-Regular" size:14.0f];
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:13.0f];
}
+ (UIFont *)fontRegularLight:(CGFloat)size
{
    return [UIFont fontWithName:@"OpenSans-Light" size:size];
}

+ (UIFont *)fontRegular:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:size];
}

+ (UIFont *)fontRegularBold
{
    
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:13.0f];
}

+ (UIFont *)fontRegularBold:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:size];
}

+ (UIFont *)fontSemiBold
{
    
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:13.0f];
}

+ (UIFont *)fontSemiBold:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:size];
}

+ (UIFont *)fontButtonBold {
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:18.0f];
}

+ (UIFont *)fontLarge {
    return [UIFont fontWithName:@"AvenirLTStd-Black" size:21.0f];
}



@end
