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

//float basicColors[10][3]={
//    {1,0,0},
//    {1,.5,0},
//    {1,1,0},
//    {.50,1,0},
//    {0,1,0},
//    {0,.5,1},
//    {0,0,1},
//    {.50,0,1},
//    {.75,0,1},
//    {1,0,1}
//};


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
        self.sources =
        @[@"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/NY_NYT.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/DC_WP.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/UK_TG.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/CA_LAT.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/WSJ.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/NY_NYP.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/NY_DN.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/IND_AGE.pdf",
            @"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf9/UAE_TN.pdf"];
    }
    return self;
}


- (UIImage*) createBackground
{
    const float alpha = .5;
    //UIImage* background=[self blackImage];
    UIImage* background;
    int sourceNum=0;
    for (id source in self.sources) {
        UIImage* frontPage = [self imageFromURL:source];
        //UIImage* coloredFrontPage = [self blendImage:frontPage withColor:[UIColor colorWithRed:basicColors[sourceNum][0] green:basicColors[sourceNum][1] blue:basicColors[sourceNum][2] alpha: alpha]];
        UIImage* mask =[self createMaskForSegment:sourceNum];
        UIImage* maskedImage=[self maskImage:frontPage withMask:mask];
        if (background) {
            background = [self blendImage: background withImage: maskedImage];
        }
        else {
            background=maskedImage;
        }
        sourceNum++;
    }
    return background;
}

//- (UIImage*) blackImage {
//    CGSize imageSize = CGSizeMake(self.radius*2, self.radius*2);
//    UIColor *fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [fillColor setFill];
//    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
//    UIImage *blackImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return blackImage;
//}

- (UIImage*) imageFromURL: (NSString*) urlString
{
    NSURL *pathUrl = [NSURL URLWithString:urlString];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pathUrl);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, 1);
    
    // since the aspect ratio is different, shrinking to fit may mean that part of a segment is blank! so for now, just crop to our size
    //CGAffineTransform shrinkingTransform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, CGRectMake(0, 0, self.radius*2, self.radius*2), 0, YES);
    
    //UIGraphicsBeginImageContext(CGSizeMake(612,792)); // A4 size for pdf
    
    UIGraphicsBeginImageContext(CGSizeMake(self.radius*2,self.radius*2)); // A4 size for pdf
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(currentContext, 0, 2*self.radius); //
    CGContextScaleCTM(currentContext, 1.0, -1.0); // make sure the page is the right way up
    //CGContextConcatCTM(currentContext, shrinkingTransform);
    CGContextDrawPDFPage (currentContext, pdfPage);  // draws the page in the graphics context
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//-(UIImage*) blendImage:(UIImage*)image withColor:(UIColor*) color {
//    
//    
//    CGSize size = CGSizeMake(image.size.width, image.size.height);
//    UIGraphicsBeginImageContext( size );
//    
//    [color setFill];
//    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.radius*2, self.radius*2)] fill];
//    
//    // Use existing opacity as is
//    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
//    
//    
//    // Apply supplied opacity
//    [image drawInRect:CGRectMake(0,0,size.width,size.height) blendMode:kCGBlendModeNormal alpha:0.5];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//    
//}
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

- (UIImage*) blendImage: (UIImage*)image0 withImage: (UIImage*)image1 {
    CGSize size = CGSizeMake(self.radius*2, self.radius*2);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // create rect that fills screen
    CGRect bounds = CGRectMake( 0,0, self.radius*2, self.radius*2);
    
    // This is my bkgnd image
    [image0 drawInRect:bounds];
    //CGContextDrawImage(context, bounds, [image0 CGImage] );
    
    //CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    // This is my image to blend in
    //CGContextDrawImage(context, bounds, [image1 CGImage]);
   // blendMode:kCGBlendModeNormal alpha:1.0
    [image1 drawInRect:bounds blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return outputImage;
}


                           






@end
