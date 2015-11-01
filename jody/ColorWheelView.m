//
//  colorWheelView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//



#import "ColorWheelView.h"
#import "constants.h"
@import CoreGraphics;

CGPoint center;
int radius;
NSMutableArray* fadedColors;
float fadeFactor=.5;



@implementation ColorWheelView

- (id)initWithFrame: (CGRect)frame withBackgroundImage:(UIImage *)backgroundImage andFadedBackgroundImage: (UIImage*)fadedBackgroundImage
{
    
    self=[super initWithFrame:frame];
    if (self) {
        self.myBackgroundImage = backgroundImage;
        self.myFadedBackgroundImage = fadedBackgroundImage;
        self.backgroundColor = [UIColor clearColor];
        UIColor* imageColor = [[UIColor alloc] initWithPatternImage:self.myBackgroundImage];
        self.layer.backgroundColor = imageColor.CGColor;
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)fade: (bool)fade
{
    if (fade) {
        UIColor* imageColor = [[UIColor alloc] initWithPatternImage:self.myFadedBackgroundImage];
        self.layer.backgroundColor = imageColor.CGColor;
    }
    else {
        UIColor* imageColor = [[UIColor alloc] initWithPatternImage:self.myBackgroundImage];
        self.layer.backgroundColor = imageColor.CGColor;
    }
}



@end
