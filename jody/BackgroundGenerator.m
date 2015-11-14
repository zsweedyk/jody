//
//  BackgroundGenderator.m
//  jody
//
//  Created by Z Sweedyk on 7/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "NWSource.h"
#import "SourceManager.h"
#import "BackgroundGenerator.h"
#import "constants.h"
#import "UIImage+crop.h"
@import CoreGraphics;

@interface BackgroundGenerator()
@property (weak,nonatomic) SourceManager* sourceManager;
@end


@implementation BackgroundGenerator

+ (id)sharedManager {
    static BackgroundGenerator *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (UIImage*) createFadedBackgroundFromBackground: (UIImage*)background
{

    UIImage* faded =[self blendImage:background withColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
    return faded;
}


- (UIImage*) createBackground
{
    self.diameter = floor(self.diameter);  // to avoid rounding artifacts

    
    UIImage* background;
    UIImage* mask;
    if (!self.sourceManager) {
        self.sourceManager = [SourceManager sharedManager];
    }

    // for each source
    for (int i=0; i<kSourceCount; i++) {

  
        // get front page image for source
        UIImage* frontPage = [self.sourceManager frontPageImageForSource:i];
  
        // scale front page to size of screen or 2x size of screen
        if (frontPage.size.width<self.diameter || frontPage.size.height<self.diameter) {
            frontPage = [frontPage scaleImageToSize:CGSizeMake(self.diameter,self.diameter)];
        }
        if (frontPage.size.width>2*self.diameter || frontPage.size.height>2*self.diameter) {
            frontPage = [frontPage scaleImageToSize:CGSizeMake(2*self.diameter,2*self.diameter)];
        }

        // crop to a square about center
        CGFloat x = (frontPage.size.width-self.diameter)/2.0;
        CGFloat y = (frontPage.size.height-self.diameter)/2.0;
        frontPage = [frontPage crop: CGRectMake(x, y, self.diameter, self.diameter)];
        
        // blend image with color for source
        frontPage = [self blendImage:frontPage withColor: [self.sourceManager colorForSource:i]];
        
        // mask front page for segment and add to background
        mask =[self createMaskForSegment:i];
        UIImage* maskedImage=[self maskImage:frontPage withMask:mask];
        if (background) {
            background = [self blendImage: background withImage: maskedImage];
        }
        else {
            background=maskedImage;
        }
    }
    return background;
}

-(UIImage*) blendImage:(UIImage*)image withColor:(UIColor*) color {
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContext( size );
    [color setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.diameter, self.diameter)] fill];
    
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,size.width,size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}

- (UIImage*) createMaskForSegment: (int) segmentNumber
{
    CGPoint center = CGPointMake(self.diameter/2.0, self.diameter/2.0);
    
    CGSize circleSize;
    circleSize.width=self.diameter;
    circleSize.height=self.diameter;
    UIGraphicsBeginImageContext(circleSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // make background white
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.diameter, self.diameter)] fill];

    
    CGContextTranslateCTM( context, center.x, center.y ) ;
    double radiansInSegment = 2.0*3.14159/(double)kSourceCount;
    
    // we need one side and the arc to be black, the other white
    // otherwise we blend two photos on the edge and it becomes too light
    


    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGMutablePathRef segment = CGPathCreateMutable();
    CGPathMoveToPoint(segment, NULL,0,0);
    CGFloat startAngle = segmentNumber*radiansInSegment;
    CGFloat x= self.diameter/2.0*cos(startAngle);
    CGFloat y= self.diameter/2.0*sin(startAngle);
    CGContextSetLineWidth(context, 1.0);
    CGPathAddLineToPoint(segment, NULL, x, y);
    CGPathAddArc(segment, NULL,
                 0,0,
                 self.diameter/2.0,
                 startAngle,
                 startAngle-radiansInSegment,
                 YES);
    CGPathAddLineToPoint(segment, NULL,0,0);
    CGContextAddPath(context, segment);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    // now draw one side and arc for segment
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, x, y);
    CGContextStrokePath(context);
    
    UIImage* mask =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mask;
}

- (UIImage*) blendImage: (UIImage*)image0 withImage: (UIImage*)image1 {
    CGSize size = CGSizeMake(self.diameter, self.diameter);
    UIGraphicsBeginImageContext(size);

    
    // create rect that fills screen
    CGRect bounds = CGRectMake( 0,0, self.diameter, self.diameter);
    
    // This isbkgnd image
    [image0 drawInRect:bounds];
    // this is other
    [image1 drawInRect:bounds blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return outputImage;
}


@end
