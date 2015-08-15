//
//  ChainView.m
//  jody
//
//  Created by Z Sweedyk on 8/14/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "PositionManager.h"
//#import "PathView.h"
#import "ChainView.h"
@interface ChainView()

@property (weak,nonatomic) NSArray* words;

@property (strong,nonatomic) NSMutableArray* chainPtrToPath;
@property (strong,nonatomic) NSMutableArray* path;
@property (strong,nonatomic) NSMutableArray* wordsToIgnore;
@property (strong,nonatomic) UILabel* wordWaitingToAddToChain;
@property int newWordStartingPoint;
@property CGPoint fingerPosition;
//@property (strong,nonatomic) PathView* pathView;
@property bool initialized;
@property (strong,nonatomic) NSMutableArray* wordSizes;
@property CGFloat maxWordHeight;
@property CGFloat minSpaceBetweenWords;
@property CGFloat distanceToLastWord;

@end

@implementation ChainView

- (id)initWithFrame:(CGRect)frame andWords: (NSMutableArray*) words andDeletedFlags:(NSMutableArray *)deleted
{
    self = [super initWithFrame:frame];
    if (self) {
        self.words = words;
        self.wordSizes = [[NSMutableArray alloc] init];
        self.chain = [[NSMutableArray alloc] init];
        self.path = [[NSMutableArray alloc] init];
        self.wordsToIgnore = [[NSMutableArray alloc] initWithCapacity:[self.words count]];
        for (int i=0; i<[self.words count]; i++) {
            self.wordsToIgnore[i]=deleted[i];
        }
        self.chainPtrToPath = [[NSMutableArray alloc] init];
        //self.pathView = [[PathView alloc] initWithFrame:self.frame];
        //self.pathView.backgroundColor = [UIColor clearColor];
        //[self addSubview:self.pathView];
        self.wordWaitingToAddToChain=nil;
        self.maxWordHeight = -1;
        self.minSpaceBetweenWords=-1; 
    }
    return self;
}


- (void) addFirstWord: (int) i atLocation: (CGPoint) position
{
    UILabel* firstWord = self.words[i];
    self.fingerPosition = position;
    UILabel* newWord = [self createLabelForWord:(int)firstWord.tag centeredAt: position];
    self.chain[0] = newWord;
    self.wordSizes[0]=[self NSArrayFromCGSize:newWord.frame.size];
    self.chainPtrToPath[0]=[NSNumber numberWithInt:0];
    self.path[0]=[self NSArrayFromCGPoint:position];
    self.wordsToIgnore[i]=[NSNumber numberWithInt:1];
    [self addSubview:newWord];
    self.initialized=NO;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize]};
    NSString* space = @"  ";
    CGSize frameSize = [space sizeWithAttributes:attributes];
    self.minSpaceBetweenWords=frameSize.width;
}

- (UILabel*) createLabelForWord: (int) i centeredAt: (CGPoint) point
{
    UILabel* word = self.words[i];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize]};
    CGSize frameSize = [word.text sizeWithAttributes:attributes];
    CGRect frame = CGRectMake(point.x-frameSize.width/2.0, point.y-frameSize.height/2.0, frameSize.width, frameSize.height);
    UILabel* chainWord = [[UILabel alloc] initWithFrame:frame];
    chainWord.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize];
    chainWord.textAlignment = NSTextAlignmentCenter;
    chainWord.textColor = word.textColor;
    chainWord.backgroundColor = [UIColor clearColor];
    chainWord.text = word.text;
    chainWord.tag = word.tag;
    if (frame.size.height>self.maxWordHeight) {
        self.maxWordHeight=frame.size.height;
    }
    return chainWord;
}

- (void) moveFingerTo:(CGPoint)newPosition
{
    static CGPoint lastPoint;
    if (!self.initialized) {
        lastPoint = [(UILabel*)self.chain[0] center];
        self.initialized=YES;

    }

    self.path[self.path.count] = [self NSArrayFromCGPoint:newPosition];
    UILabel* lastWordInChain = (UILabel*)self.chain[[self.chain count]-1];
    int lastWordStartingIndex = (int)[(NSNumber*) self.chainPtrToPath[[self.chain count]-1] integerValue];
    [self moveChain];
    
    // erase path as needed
    if (!self.wordWaitingToAddToChain) {
        int lastWordCurrentIndex = (int)[(NSNumber*) self.chainPtrToPath[[self.chain count]-1] integerValue];
        for (int i=lastWordStartingIndex; i<lastWordCurrentIndex; i++){
            CGPoint startPoint = [self CGPointFromArray:(NSArray*)self.path[i]];
            CGPoint endPoint = [self CGPointFromArray:(NSArray*)self.path[i+1]];
            //[self.pathView eraseLineFrom:startPoint To:endPoint];
        }
    }
    
    // check if waiting word can be added
    if (self.wordWaitingToAddToChain) {
        CGPoint lastWordCenter = lastWordInChain.center;
        CGPoint newWordCenter = self.wordWaitingToAddToChain.center;
        CGFloat distance = sqrt(pow(lastWordCenter.x-newWordCenter.x,2)+pow(lastWordCenter.y-newWordCenter.y,2));
        CGFloat requiredDistance = (lastWordInChain.frame.size.width + self.wordWaitingToAddToChain.frame.size.width)/2.0;
        if (distance>requiredDistance) {
            self.chainPtrToPath[[self.chain count]] = [NSNumber numberWithInt:self.newWordStartingPoint];
            self.chain[[self.chain count]]= self.wordWaitingToAddToChain;
            self.wordSizes[[self.wordSizes count]] = [self NSArrayFromCGSize:self.wordWaitingToAddToChain.frame.size];
            self.wordsToIgnore[self.wordWaitingToAddToChain.tag]=[NSNumber numberWithInt:1];
            self.wordWaitingToAddToChain=nil;
        }
        
    }
    
    // check for collision of last word in chain with word not in chain
    else {
        UILabel* collideWithWord = [self checkCollisions];
        if (collideWithWord) {
            // add to chain
            CGRect intersectionArea = CGRectIntersection (collideWithWord.frame, lastWordInChain.frame);
            UILabel* newWord = [self createLabelForWord:(int)collideWithWord.tag centeredAt: CGPointMake(intersectionArea.origin.x + intersectionArea.size.width/2.0, intersectionArea.origin.y+intersectionArea.size.height/2.0)];
            self.wordWaitingToAddToChain = newWord;
            [self addSubview:newWord];
            self.newWordStartingPoint = (int)[(NSNumber*)self.chainPtrToPath[[self.chain count]-1] integerValue];
        }
    }

    if ([self.chain count]>1 || self.wordWaitingToAddToChain) {
        
        //[self.pathView drawLineFrom: lastPoint To: newPosition];
    }
    
    if ([self.chain count]>1 && !self.wordWaitingToAddToChain) {
        int lastPointIndex = (int)[(NSNumber*)self.chainPtrToPath[[self.chain count]-1] integerValue];
        CGPoint lastPoint = [self CGPointFromArray:(NSArray*)self.path[lastPointIndex]];
        CGPoint secondToLastPoint = [self CGPointFromArray:(NSArray*)self.path[lastPointIndex+1]];
        
        //[self.pathView eraseLineFrom:lastPoint To:secondToLastPoint];
    }
    lastPoint=newPosition;
        
}

- (void) moveChain
{
    // move the first word
    UILabel* theWord = (UILabel*)self.chain[0];
    int pathIndex = (int)[self.chainPtrToPath[0] integerValue] + 1;
    CGPoint nextPoint = [self CGPointFromArray:(NSArray*) self.path[pathIndex]];
    [theWord setCenter: nextPoint];
    self.chainPtrToPath[0]=[NSNumber numberWithInt:pathIndex];
    UILabel* nextWord=theWord;
    

    for (int i=1; i<[self.chain count]; i++)
    {
        UILabel* theWord = (UILabel*)self.chain[i];
        pathIndex = (int)[self.chainPtrToPath[i] integerValue]+1;
        int startingIndex=pathIndex-1;
        CGPoint moveToPoint = [self CGPointFromArray:(NSArray*) self.path[pathIndex]];
        CGRect movedFrame = CGRectMake(moveToPoint.x, moveToPoint.y, theWord.frame.size.width, theWord.frame.size.height);
        while ([self goodDistanceFrom: movedFrame To: nextWord.frame]){
            pathIndex++;
            moveToPoint = [self CGPointFromArray:(NSArray*) self.path[pathIndex]];
            movedFrame.origin.x = moveToPoint.x;
            movedFrame.origin.y = moveToPoint.y;
        }
        pathIndex--;
        if (pathIndex == startingIndex) {
            // we're stall stop movement
            break;
        }
        else {
            moveToPoint = [self CGPointFromArray:(NSArray*) self.path[pathIndex]];
            [theWord setCenter: moveToPoint];
            self.chainPtrToPath[i]=[NSNumber numberWithInt:pathIndex];
            nextWord=theWord;
        }
    }
}

- (bool) goodDistanceFrom: (CGRect) frame1 To:  (CGRect) frame2
{
    if (fabs(frame1.origin.y - frame2.origin.y) > MAX(frame1.size.height,frame2.size.height)*2)
        return YES;
    else if (fabs(frame1.origin.x - frame2.origin.x) > 1.5*(frame1.size.width + frame2.size.width)/2.0)
            return YES;
    return NO;
    
}

- (UILabel*) checkCollisions
{
    UILabel* lastWordInChain = (UILabel*) self.chain[[self.chain count]-1];
    
    for (long i=[self.words count]-1; i>=0; i--) {
        if ([(NSNumber*) self.wordsToIgnore[i] integerValue]==0) {
            if (CGRectIntersectsRect (((UILabel*)self.words[i]).frame, lastWordInChain.frame))
                return (UILabel*)self.words[i];
        }
    }
    return nil;
}


- (void)animateEnd {
    
//    if (self.pathView) {
//        [self.pathView removeFromSuperview];
//        self.pathView=nil;
//    }
    if (self.wordWaitingToAddToChain) {
        self.chainPtrToPath[[self.chain count]] = [NSNumber numberWithInt:self.newWordStartingPoint];
        self.chain[[self.chain count]]= self.wordWaitingToAddToChain;
        self.wordSizes[[self.wordSizes count]] = [self NSArrayFromCGSize:self.wordWaitingToAddToChain.frame.size];
        self.wordsToIgnore[self.wordWaitingToAddToChain.tag]=[NSNumber numberWithInt:1];
        self.wordWaitingToAddToChain=nil;
    }
    PositionManager* pManager = [PositionManager sharedManager];
    NSArray* positions = [pManager positionForWordsWithSizes: self.wordSizes inFrame: self.frame maxWordHeight: self.maxWordHeight andMinSpaceBetweenWords: self.minSpaceBetweenWords withRandomness:NO];
   
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    for (int i=0; i<[self.chain count]; i++) {
        UILabel* theWord = (UILabel*) self.chain[i];
        CGPoint position = [self CGPointFromArray:(NSArray*)positions[i]];
        CGRect newFrame = CGRectMake(position.x, position.y, theWord.frame.size.width, theWord.frame.size.height);
        theWord.frame = newFrame;
    }
    [UIView commitAnimations];
    
}

- (void) reset
{
    self.chainPtrToPath=nil;
    self.path = nil;
    self.wordsToIgnore=nil;
    self.wordWaitingToAddToChain=nil;
    //self.pathView = nil;
    self.wordSizes=nil;
    self.chain=nil;
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
