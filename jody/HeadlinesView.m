//
//  HeadlinesView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "HeadlinesView.h"

@implementation HeadlinesView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headlines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

- (void)addHeadline:(NSString*) headline withColor:(UIColor*)color
{
    
    // for now we just put it somewhere
    

    NSMutableArray* words = [NSMutableArray arrayWithArray:[headline componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
    //[parts removeObjectIdenticalTo:@""];
    


    CGFloat x=0;
    CGFloat y=0;
    CGFloat topOfCurrentLine = 0;
    CGFloat bottomOfCurrentLine=0;
    CGFloat lastWidth=0;
    bool newLine = true;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:96]};
    for (id word in words) {
        
        // create frame
        CGSize frameSize = [word sizeWithAttributes:attributes];
        if (y==0){
            y += arc4random() % (int) self.frame.size.height/4.0;
            bottomOfCurrentLine = y + frameSize.height;
            topOfCurrentLine = y;
        }
        x += lastWidth + (CGFloat) (arc4random() % (int) self.frame.size.width)/4;
        if (x + frameSize.width > self.frame.size.width && !newLine) {
                // start new line
            x = (CGFloat) (arc4random() % (int) self.frame.size.width)/4;
            y += frameSize.height*1.5; // or something
                topOfCurrentLine=y;
                bottomOfCurrentLine=y+frameSize.height;

            newLine=true;
        }
        else {
            if (x + frameSize.width > self.frame.size.width) {
                // we need to start the string sooner
                x -= (frameSize.width - x);
            }
            newLine=false;
        }
        lastWidth=frameSize.width;
        CGRect labelFrame = CGRectMake(x, y, frameSize.width, frameSize.height);
        UILabel* newLabel = [[UILabel alloc] initWithFrame:labelFrame];
        newLabel.text=word;
        newLabel.textColor=color;
        [newLabel setFont:[UIFont fontWithName:@"TimesNewRomanPSMT" size:96.0]];
        newLabel.numberOfLines = 1;
        newLabel.tag = [self.headlines count];
        newLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeHeadline:)];
        [newLabel addGestureRecognizer:tapGestureRecognizer];
        UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHeadline:)];
        [newLabel addGestureRecognizer:panGestureRecognizer];
        [self addSubview:newLabel];
        [self.headlines addObject: headline];
        
    }
}

- (void) removeHeadline: (UITapGestureRecognizer*)sender
{
    UILabel* label = (UILabel*)[sender view];
    int tag = label.tag;
    [label removeFromSuperview];
    // we don't remove from the array because the indices need to match the tags
    
}

- (void) moveHeadline: (UIPanGestureRecognizer*)sender
{

    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:self];
}



@end

