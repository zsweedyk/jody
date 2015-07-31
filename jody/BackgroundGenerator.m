//
//  BackgroundGenderator.m
//  jody
//
//  Created by Z Sweedyk on 7/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "BackgroundGenerator.h"
@import CoreGraphics;

int numSegments =9;

float basicColors[10][3]={
    {1,0,0},
    {1,.5,0},
    {1,1,0},
    {.50,1,0},
    {0,1,0},
    {0,.5,1},
    {0,0,1},
    {.50,0,1},
    {.75,0,1},
    {1,0,1}
};


@implementation BackgroundGenerator

+ (id)sharedManager {
    static BackgroundGenerator *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.sources = @[@"http://www.nytimes.com/images/2015/07/24/nytfrontpage/scan.pdf"];
    }
    return self;
}

- (UIImage*) imageFromURL: (NSString*) urlString
{
    
    NSURL *pathUrl = [NSURL URLWithString:urlString];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pathUrl);
    

    UIGraphicsBeginImageContext(CGSizeMake(self.radius,self.radius));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, 0, 2*self.radius); //596,842 //640x960,
    CGContextScaleCTM(currentContext, 1.0, -1.0); // make sure the page is the right way up
    
    CGPDFPageRef page = CGPDFDocumentGetPage (pdf, 1); // first page of PDF is page 1 (not zero)
    CGContextDrawPDFPage (currentContext, page);  // draws the page in the graphics context
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
    
    return nil;
}

- (UIImage*) createBackgroundWithRadius:(CGFloat)radius
{
    NSMutableArray* images = [[NSMutableArray alloc] initWithCapacity:[self.sources count]];
    for (id source in self.sources) {
        int sourceNum=[images count];
        UIImage* frontPage = [self imageFromURL:source];
        UIImage* coloredFrontPage = [self blendImage:frontPage withColor:[UIColor colorWithRed:basicColors[sourceNum][0] green:basicColors[sourceNum][1] blue:basicColors[sourceNum][2] alpha:.5]];
        UIImage* mask =[self createMaskForSegment:[images count]];
        [images addObject: [self maskImage:coloredFrontPage withMask:mask]];
    }
    if ([images count]==1)
        return [images objectAtIndex:0];
    else
        return nil;
}

-(UIImage*) blendImage:(UIImage*)image withColor:(UIColor*) color {
    

    CGSize newSize = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContext( newSize );
    
    [color setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.radius*2, self.radius*2)] fill];
    
    // Use existing opacity as is
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
    
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
    CGPoint center = CGPointMake(self.radius, self.radius);
    
    CGSize circleSize;
    circleSize.width=self.radius*2;
    circleSize.height=self.radius*2;
    UIGraphicsBeginImageContext(circleSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // make background white
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.radius*2, self.radius*2)] fill];
    
    // draw segment in black

    CGContextTranslateCTM( context, center.x, center.y ) ;
    double radiansInSegment = 2.0*3.14159/(double)numSegments;
    
    CGMutablePathRef segment = CGPathCreateMutable();
    CGPathMoveToPoint(segment, NULL,0,0);
    CGFloat startAngle = segmentNumber*radiansInSegment;
    CGFloat x= self.radius*cos(startAngle);
    CGFloat y= self.radius*sin(startAngle);
    CGPathAddLineToPoint(segment, NULL, x, y);
    CGPathAddArc(segment, NULL,
                 0,0,
                 self.radius,
                 startAngle,
                 startAngle-radiansInSegment,
                 YES);
    CGPathAddLineToPoint(segment, NULL,0,0);
    
    UIColor* segmentColor;
    segmentColor = [UIColor blackColor];
    CGContextAddPath(context, segment);

    CGContextSetFillColorWithColor(context, segmentColor.CGColor);
    CGContextSetStrokeColorWithColor(context, segmentColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    UIImage* mask =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mask;
}

@end
