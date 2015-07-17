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
    
    CGFloat x = (CGFloat) (arc4random() % (int) self.frame.size.width)/2;
    CGFloat y = (CGFloat) (arc4random() % (int) self.frame.size.height)-50;
    CGRect labelFrame = CGRectMake(x, y, self.frame.size.width-x, self.frame.size.height-y);
    UILabel* newLabel = [[UILabel alloc] initWithFrame:labelFrame];
    newLabel.text=headline;
    newLabel.textColor=color;
    newLabel.numberOfLines = 0;
    newLabel.lineBreakMode = UILineBreakModeWordWrap;
    [newLabel sizeToFit];
    newLabel.tag = [self.headlines count];
    newLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeHeadline:)];
    [newLabel addGestureRecognizer:tapGestureRecognizer];

    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHeadline:)];
    [newLabel addGestureRecognizer:panGestureRecognizer];
    
    [self addSubview:newLabel];
    [self.headlines addObject: headline];
    
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

