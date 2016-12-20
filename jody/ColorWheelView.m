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

- (id)initWithFrame: (CGRect)frame withBackgroundImage:(UIImage *)backgroundImage
{
    
    self=[super initWithFrame:frame];
    if (self) {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        [backgroundImage drawInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.myBackgroundImage = newImage;
        
    
        UIImage* faded =[self blendImage:newImage withColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        [faded drawInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.myFadedBackgroundImage = newImage;
        
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

-(UIImage*) blendImage:(UIImage*)image withColor:(UIColor*) color {
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContext( size );
    [color setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, image.size.width, image.size.height)] fill];
    
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,size.width,size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
