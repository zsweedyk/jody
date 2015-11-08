//
//  HeadlinesView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "FontManager.h"
#import "PositionManager.h"
#import "ChainView.h"
#import "HeadlinesView.h"
#import "constants.h"

const int maxDisplacement = 3;


@interface HeadlinesView()

@property (strong,nonatomic) ChainView* chainView;
@property (strong,nonatomic) UIView* fade;
@property CGFloat maxWordHeight;
@property CGFloat minSpaceBetweenWords;
@property (strong,nonatomic) NSMutableArray* deleted;
@property (weak,nonatomic) PositionManager* positionManager;
@property (strong,nonatomic) UITapGestureRecognizer* myTapRecognizer;
@property int fontSize;



@end

@implementation HeadlinesView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headlines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        self.words = [[NSMutableArray alloc] init];
        self.deleted = [[NSMutableArray alloc] init];
        self.positionManager = [PositionManager sharedManager];
        FontManager* fontManager = [FontManager sharedManager];
        self.fontSize = fontManager.headlineFontSize;
  
    }
    return self;
}

- (int)addHeadline:(NSString*) headline withColor:(UIColor*)color
{

    // it doesn't disappear sometimes -- not sure why but this should take care of it
    // until we can find the problem
    if (self.chainView) {
        [self endChain];
    }
    // find words
    NSMutableArray* newWords = [self wordsOfHeadline: headline];
    if (!newWords) {
        return 0;
    }
    
    // get sizes -- word Rects also sets self.maxWordHeight and self.minWordWidth
    self.maxWordHeight=-1;
    self.minSpaceBetweenWords=-1;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontName size:self.fontSize]};
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
    int oldWordCount = (int)[self.words count];
    for (int i=0;i<[theWords count]; i++) {
        // find last word in this line
        
        CGPoint point = [self CGPointFromArray:(NSArray*)[wordPositions objectAtIndex:i]];
        CGSize size = [self CGSizeFromArray:(NSArray*)[wordSizes objectAtIndex:i]];
        
        CGRect labelFrame = CGRectMake(point.x, point.y, size.width, size.height);
        
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
        newLabel.alpha = 0;
        
        [newLabel setFont:[UIFont fontWithName:kFontName size:self.fontSize]];
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
        [self addWord: newLabel withAnimationDelay: i*.5 andMoveWords:oldWordCount];

        [self.words insertObject:newLabel atIndex:newLabel.tag];
        [self.deleted insertObject:[NSNumber numberWithInt:0] atIndex:newLabel.tag];
        

    }
}

- (void) addWord: (UILabel*) word withAnimationDelay: (CGFloat) delay andMoveWords: (int) oldWordCount
{
    __block NSMutableArray* toFade = [[NSMutableArray alloc] init];
    for (int i=0;i<oldWordCount;i++) {
        UILabel* oldWord = (UILabel*) self.words[i];

        CGRect intersect = CGRectIntersection (oldWord.frame, word.frame);
        if (CGRectIsNull(intersect) || CGRectIsEmpty(intersect)) {
                toFade[[toFade count]]=oldWord;
        }
    }
    [UIView animateWithDuration:.5 delay:.2*delay options:0
                     animations:^(){
                         word.alpha=1;
                         for (int j=0; j<[toFade count];j++) {
                             UILabel* oldWord = (UILabel*)toFade[j];
                             oldWord.alpha=.5;
                        }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.5 delay:.2*delay options:0
                                          animations:^() {
                                              for (int j=0; j<[toFade count];j++) {
                                                  UILabel* oldWord = (UILabel*)toFade[j];
                                                  oldWord.alpha=1;
                                              }
                                          }
                                          completion:nil];
                     }];
}

- (CGPoint)moveOldWord:(CGRect)oldFrame forNewWord:(CGRect)newFrame
{
    CGPoint displacement = CGPointMake(0, 0);
    CGRect intersect = CGRectIntersection (oldFrame, newFrame);
    if (CGRectIsNull(intersect) || CGRectIsEmpty(intersect)) {
        return displacement;
    }
    if (newFrame.origin.y < oldFrame.origin.y) {
        displacement.y = -intersect.size.height;
    }
    else {
        displacement.y = intersect.size.height;
    }
    return displacement;
}

- (void) removeHeadline: (UITapGestureRecognizer*)sender
{
    if (!self.enableInput) {
        return;
    }
    UILabel* label = (UILabel*)[sender view];
    [label removeFromSuperview];
    self.deleted[label.tag]=[NSNumber numberWithInt:1];
}

- (void) moveHeadline: (UIPanGestureRecognizer*)sender
{
    if (!self.enableInput) {
        return;
    }
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                     sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:self];
}

- (void) startChain: (UILongPressGestureRecognizer*)sender
{
    if (!self.enableInput) {
        return;
    }
    if(sender.state == UIGestureRecognizerStateBegan)
    {

        if (self.chainView) {
            self.chainView=nil;
        }
        
        // create "fade"
        if (!self.fade) {
            self.fade = [[UIView alloc] initWithFrame:self.frame];
            self.fade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.65];
        }
        [self addSubview:self.fade];
        [self bringSubviewToFront:self.fade];
  
        // create subview
        self.chainView = [[ChainView alloc] initWithFrame: self.frame andWords: self.words andDeletedFlags:self.deleted];
        [self addSubview:self.chainView];

        
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
    if (self.chainView) {
        [self.chainView reset];
    }
    [self endChain];
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    self.headlines = [[NSMutableArray alloc] init];
    self.words = [[NSMutableArray alloc] init];
}


- (CGPoint) CGPointFromArray: (NSArray*) array
{
    return CGPointMake([(NSNumber*)array[0] floatValue], [(NSNumber*)array[1] floatValue]);
}
- (NSArray*) NSArrayFromCGPoint: (CGPoint) point
{
    return @[[NSNumber numberWithFloat:point.x],[NSNumber numberWithFloat:point.y]];
}

- (CGSize) CGSizeFromArray: (NSArray*) array
{
    return CGSizeMake([(NSNumber*)array[0] floatValue], [(NSNumber*)array[1] floatValue]);
}

- (NSArray*) NSArrayFromCGSize: (CGSize) size
{
    return @[[NSNumber numberWithFloat:size.width],[NSNumber numberWithFloat:size.height]];
}

@end

