//
//  HeadlinesView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "PositionManager.h"
#import "ChainView.h"
#import "HeadlinesView.h"

@interface HeadlinesView()

@property (strong,nonatomic) ChainView* chainView;
@property (strong,nonatomic) UIView* fade;
@property CGFloat maxWordHeight;
@property CGFloat minSpaceBetweenWords;
@property (strong,nonatomic) NSMutableArray* deleted;
@property (weak,nonatomic) PositionManager* positionManager;
@property (strong,nonatomic) UITapGestureRecognizer* myTapRecognizer;

@end

@implementation HeadlinesView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headlines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.fontSize = 52; // these will be set by mainVC -- but just in case we set defaults
        self.smallFontSize = 20;
        self.words = [[NSMutableArray alloc] init];
        self.deleted = [[NSMutableArray alloc] init];
        self.positionManager = [PositionManager sharedManager];
    }
    return self;
}

- (int)addHeadline:(NSString*) headline withColor:(UIColor*)color
{
    
    NSLog(@"Adding headline: %@",headline);
    // find words
    NSMutableArray* newWords = [self wordsOfHeadline: headline];
    if (!newWords) {
        return 0;
    }
    
    // get sizes -- word Rects also sets self.maxWordHeight and self.minWordWidth
    self.maxWordHeight=-1;
    self.minSpaceBetweenWords=-1;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize]};
    NSMutableArray* wordSizes = [self wordSizes: newWords withAttributes:attributes];
    
    // set positions
    NSMutableArray* wordPositions = [self.positionManager positionForWordsWithSizes: wordSizes inFrame: self.frame     maxWordHeight: self.maxWordHeight andMinSpaceBetweenWords: self.minSpaceBetweenWords withRandomness:YES];
    
    // now create frames
    [self layoutWords:newWords atPositions: wordPositions withSizes: wordSizes withColor:color];
    
    [self.headlines addObject:headline];
    return 1;
    
}

- (NSMutableArray*) wordsOfHeadline: (NSString*) headline
{
    // check for bad characters -- if so, we assume it is not a headline
    NSCharacterSet *badCharacters=[NSCharacterSet characterSetWithCharactersInString:@"@#%&"];
    if ([headline rangeOfCharacterFromSet:badCharacters].location != NSNotFound) {
        return nil;
    }
    NSMutableArray* tempWords = [NSMutableArray arrayWithArray:[headline componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
    NSCharacterSet *trimCharacters=[NSCharacterSet characterSetWithCharactersInString:@"\n\t\r"];
    // get rid of empty words cause by end-of-line, tabs etc.
    // these should be eliminated in tempWords -- but they aren't
    NSMutableArray* theWords = [[NSMutableArray alloc] initWithCapacity:[tempWords count]];
    for (id obj in tempWords) {
        NSString* word = (NSString*) obj;
        word=[word stringByTrimmingCharactersInSet:trimCharacters];
        if (![word isEqualToString:@""]) {
            [theWords insertObject:word atIndex:[theWords count]];
        }
    }
    return theWords;
}
- (NSMutableArray*) wordSizes: (NSArray*) theWords withAttributes: (NSDictionary*) attributes
{
    NSMutableArray* wordSizes = [[NSMutableArray alloc] initWithCapacity:[theWords count]];

    
    for (NSString* word in theWords) {
        CGSize frameSize = [word sizeWithAttributes:attributes];
        [wordSizes insertObject:@[[NSNumber numberWithFloat:frameSize.width],[NSNumber numberWithFloat:frameSize.height]] atIndex:[wordSizes count]];
        if (frameSize.height > self.maxWordHeight)
            self.maxWordHeight=frameSize.height;
    }
    // find a minimum space between words
    NSString* wordSpace = @"  ";
    CGSize frameSize = [wordSpace sizeWithAttributes:attributes];
    self.minSpaceBetweenWords = frameSize.width;
    return wordSizes;
}


- (void)layoutWords: (NSArray*) theWords atPositions: (NSArray*) wordPositions withSizes: (NSArray*) wordSizes withColor: (UIColor*) color
{
    
    for (int i=0;i<[theWords count]; i++) {
        // find last word in this line
        
        NSArray* position = (NSArray*)[wordPositions objectAtIndex:i];
        CGFloat x = [(NSNumber*)[position objectAtIndex:0] floatValue];
        CGFloat y = [(NSNumber*)[position objectAtIndex:1] floatValue];
        
        NSArray* size = (NSArray*)[wordSizes objectAtIndex:i];
        CGFloat width = [(NSNumber*)[size objectAtIndex:0] floatValue];
        CGFloat height = [(NSNumber*)[size objectAtIndex:1] floatValue];
        
        CGRect labelFrame = CGRectMake(x, y, width, height);
        UILabel* newLabel = [[UILabel alloc] initWithFrame:labelFrame];
        newLabel.text=(NSString*)[theWords objectAtIndex:i];
        
        // we want to use color but with an alpha of 1
        CGFloat red, green, blue, alpha;
        [color getRed: &red
                green: &green
                 blue: &blue
                alpha: &alpha];
        UIColor* textColor = [UIColor colorWithRed: red green:green blue:blue alpha:1];
        newLabel.textColor=textColor;
        
        [newLabel setFont:[UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize]];
        newLabel.numberOfLines = 1;
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.userInteractionEnabled = YES;
        newLabel.tag = [self.words count];
        
        // add gesture recognizers
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeHeadline:)];
        [newLabel addGestureRecognizer:tapGestureRecognizer];
        UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHeadline:)];
        [newLabel addGestureRecognizer:panGestureRecognizer];
        UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startChain:)];
        [newLabel addGestureRecognizer:longPressGestureRecognizer];
        
        // add subview
        [self addSubview:newLabel];
        [self.words insertObject:newLabel atIndex:newLabel.tag];
        [self.deleted insertObject:[NSNumber numberWithInt:0] atIndex:newLabel.tag];
        
    }
    
}


- (void) removeHeadline: (UITapGestureRecognizer*)sender
{
    UILabel* label = (UILabel*)[sender view];
    [label removeFromSuperview];
    self.deleted[label.tag]=[NSNumber numberWithInt:1];

}

- (void) moveHeadline: (UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                     sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:self];
}

- (void) startChain: (UILongPressGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.chainView) {
            self.chainView=nil;
        }
        
        // create "fade"
        if (!self.fade) {
            self.fade = [[UIView alloc] initWithFrame:self.frame];
            self.fade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        }
        [self addSubview:self.fade];
        [self bringSubviewToFront:self.fade];
  
        // create subview
        self.chainView = [[ChainView alloc] initWithFrame: self.frame andWords: self.words andDeletedFlags:self.deleted];
        [self addSubview:self.chainView];
        self.chainView.fontSize = self.smallFontSize;
        
        int num = (int)((UILabel*)[sender view]).tag;
        CGPoint position = [sender locationInView:self];
        [self.chainView addFirstWord: num atLocation:position];
        [self.chainView setNeedsDisplay];
        
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
        
        //move your views here.
   
        [self.chainView moveFingerTo:[sender locationInView:self]];

        
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        [self.chainView animateEnd];
        if (!self.myTapRecognizer) {
            self.myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endChain)];
        }

        [self addGestureRecognizer:self.myTapRecognizer];
    }

}

- (void) endChain
{
    if (self.chainView) {
        [self.chainView removeFromSuperview];
        self.chainView = nil;
        [self.fade removeFromSuperview];
        [self removeGestureRecognizer:self.myTapRecognizer];
    }
    
}



- (void)reset {
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    self.headlines = [[NSMutableArray alloc] init];
}

@end

