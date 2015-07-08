//
//  colorWheelView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//



#import "ColorWheelView.h"
@import CoreGraphics;

CGPoint center;
int radius;
NSArray* colors;

@implementation ColorWheelView

- (void)drawRect:(CGRect)rect
{
    colors=[NSArray arrayWithObjects:[UIColor redColor],
        [UIColor colorWithRed:1.0 green:68.0/255.0 blue:0 alpha:1],
        [UIColor orangeColor],
        [UIColor colorWithRed:253.0/255.0 green:178.0/255.0 blue:0 alpha:1],
        [UIColor yellowColor],
        [UIColor colorWithRed:70.0/255.0 green:182.0/255 blue:0 alpha:1],
        [UIColor greenColor],
        [UIColor cyanColor],
        [UIColor blueColor],
            [UIColor colorWithRed:148.0/255.0 green:33.0/255.0 blue:0 alpha:1],nil]
            ;
//            /
//            ,
//        [UIColor purpleColor],
//        [UIColor colorWithRed:90.0/255.0 green:23.0/255.0 blue:158.0/255.0 alpha:1], nil];

        
    center= CGPointMake(rect.size.width/2,rect.size.height/2);
    radius = MIN(rect.size.width,rect.size.height)*.75/2.0;
    [self drawColorWheel:colors center:center radius:radius rotation:self.angle];


}

- (void) drawColorWheel:(NSArray*)colors center:(CGPoint)center radius:(int)radius rotation:(double)rotation
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM( context, center.x, center.y ) ;
    CGContextRotateCTM( context, rotation ) ;
    int numSegments = (int)[colors count];
    double radiansInSegment = 2.0*3.14159/(double)numSegments;


    for (int i=0;i<numSegments;i++) {
        CGMutablePathRef segment = CGPathCreateMutable();
        

        CGPathMoveToPoint(segment, NULL,0,0);
        CGFloat startAngle = i*radiansInSegment;
        CGFloat x= radius*cos(startAngle);
        CGFloat y= radius*sin(startAngle);
        CGPathAddLineToPoint(segment, NULL, x, y);
        CGPathAddArc(segment, NULL,
                     0,0,
                     radius,
                     startAngle,
                     startAngle-radiansInSegment,
                     YES);
        CGPathAddLineToPoint(segment, NULL,0,0);
        
        CGContextAddPath(context, segment);
        UIColor* segmentColor = [colors objectAtIndex:i];
        CGContextSetFillColorWithColor(context, segmentColor.CGColor);
        CGContextSetStrokeColorWithColor(context, segmentColor.CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);

    
    }
    CGContextRestoreGState(context);
}


@end
