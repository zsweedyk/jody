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
NSMutableArray* fadedColors;
float fadeFactor=.5;

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

@implementation ColorWheelView

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.fade=NO;
        _colors=[[NSMutableArray alloc] initWithCapacity:numSegments];
        fadedColors=[[NSMutableArray alloc] initWithCapacity:numSegments];
        for (int i=0; i<numSegments; i++) {
            UIColor* color = [UIColor colorWithRed:basicColors[i][0] green:basicColors[i][1] blue:basicColors[i][2] alpha:.5];
            [_colors insertObject:color atIndex:i];
            
            UIColor* fadedColor = [UIColor colorWithRed:basicColors[i][0]*fadeFactor green:basicColors[i][1]*fadeFactor blue:basicColors[i][2]*fadeFactor alpha:.5];
            [fadedColors insertObject:fadedColor atIndex:i];

        }
        

    
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

    center= CGPointMake(rect.size.width/2,rect.size.height/2);
    radius = MIN(rect.size.width,rect.size.height)/2.0;

    [self drawColorWheel:_colors center:center radius:radius rotation:self.angle];
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
        
        UIColor* segmentColor;
        CGContextAddPath(context, segment);
        if (!self.fade) {
            segmentColor = [colors objectAtIndex:i];
        }
        else {
            segmentColor = [fadedColors objectAtIndex:i];
        }
        CGContextSetFillColorWithColor(context, segmentColor.CGColor);
        CGContextSetStrokeColorWithColor(context, segmentColor.CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);

    
    }
    CGContextRestoreGState(context);
}


@end
