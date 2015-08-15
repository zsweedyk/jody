//
//  ChainView.m
//  jody
//
//  Created by Z Sweedyk on 8/14/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//



#import "PathView.h"
#import "ChainView.h"
@interface ChainView()

@property (weak,nonatomic) NSArray* words;

@property (strong,nonatomic) NSMutableArray* chainPtrToPath;
@property (strong,nonatomic) NSMutableArray* path;
@property (strong,nonatomic) NSMutableArray* wordsToIgnore;
@property (strong,nonatomic) UILabel* wordWaitingToAddToChain;
@property int newWordStartingPoint;
@property CGPoint fingerPosition;
@property (strong,nonatomic) PathView* pathView;

@property (strong,nonatomic) UILabel* lastWordNotYetAdded;
@property CGFloat distanceToLastWord;

@end

@implementation ChainView

- (id)initWithFrame:(CGRect)frame andWords: (NSMutableArray*) words andDeletedFlags:(NSMutableArray *)deleted
{
    self = [super initWithFrame:frame];
    if (self) {
        self.words = words;
        self.chain = [[NSMutableArray alloc] init];
        self.path = [[NSMutableArray alloc] init];
        self.wordsToIgnore = [[NSMutableArray alloc] initWithCapacity:[self.words count]];
        for (int i=0; i<[self.words count]; i++) {
            self.wordsToIgnore[i]=deleted[i];
        }
        self.chainPtrToPath = [[NSMutableArray alloc] init];
        self.pathView = [[PathView alloc] initWithFrame:self.frame];
        self.pathView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.pathView];
                                        
    }
    return self;
}


- (void) addFirstWord: (int) i atLocation: (CGPoint) position
{
    UILabel* firstWord = self.words[i];
    self.fingerPosition = position;
    UILabel* newWord = [self createLabelForWord:(int)firstWord.tag centeredAt: position];
    self.chain[0] = newWord;
    self.chainPtrToPath[0]=[NSNumber numberWithInt:0];
    self.path[0]=[self NSArrayFromCGPoint:position];
    self.wordsToIgnore[i]=[NSNumber numberWithInt:1];
    [self addSubview:newWord];
}

- (UILabel*) createLabelForWord: (int) i centeredAt: (CGPoint) point
{
    UILabel* word = self.words[i];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize]};
    CGSize frameSize = [word.text sizeWithAttributes:attributes];
    CGRect frame = CGRectMake(point.x-frameSize.width/2.0, point.y-frameSize.height/2.0, frameSize.width, frameSize.height);
    UILabel* chainWord = [[UILabel alloc] initWithFrame:frame];
    chainWord.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:self.fontSize];
    chainWord.textAlignment = UITextAlignmentCenter;
    chainWord.textColor = [UIColor blackColor];
    chainWord.backgroundColor = word.textColor;
    chainWord.text = word.text;
    chainWord.tag = word.tag;
    return chainWord;
}

- (void) moveFingerTo:(CGPoint)newPosition
{
    static CGPoint lastPoint;
    static bool initialized=NO;
    if (!initialized) {
        lastPoint = [(UILabel*)self.chain[0] center];
        initialized=YES;
    }
    
    self.path[self.path.count] = [self NSArrayFromCGPoint:newPosition];
    [self moveChain];
    
    UILabel* lastWordInChain = (UILabel*)self.chain[[self.chain count]-1];
    if (self.wordWaitingToAddToChain) {
        CGPoint lastWordCenter = lastWordInChain.center;
        CGPoint newWordCenter = self.wordWaitingToAddToChain.center;
        CGFloat distance = sqrt(pow(lastWordCenter.x-newWordCenter.x,2)+pow(lastWordCenter.y-newWordCenter.y,2));
        CGFloat requiredDistance = (lastWordInChain.frame.size.width + self.wordWaitingToAddToChain.frame.size.width)/2.0;
        if (distance>requiredDistance) {
            self.chainPtrToPath[[self.chain count]] = [NSNumber numberWithInt:self.newWordStartingPoint];
            self.chain[[self.chain count]]= self.wordWaitingToAddToChain;
            self.wordsToIgnore[self.wordWaitingToAddToChain.tag]=[NSNumber numberWithInt:1];
            self.wordWaitingToAddToChain=nil;
        }
        
    }
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
        [self.pathView drawLineFrom: lastPoint To: newPosition];
    }
    
    if ([self.chain count]>1 && !self.wordWaitingToAddToChain) {
        int lastPointIndex = (int)[(NSNumber*)self.chainPtrToPath[[self.chain count]-1] integerValue];
        CGPoint lastPoint = [self CGPointFromArray:(NSArray*)self.path[lastPointIndex]];
        CGPoint secondToLastPoint = [self CGPointFromArray:(NSArray*)self.path[lastPointIndex+1]];
        
        [self.pathView eraseLineFrom:lastPoint To:secondToLastPoint];
    }
    lastPoint=newPosition;
        
}

- (void) moveChain
{

    for (int i=0; i<[self.chain count]; i++)
    {
        UILabel* theWord = (UILabel*)self.chain[i];
        int pointInPath = (int)[self.chainPtrToPath[i] integerValue] + 1;
        CGPoint nextPoint = [self CGPointFromArray:(NSArray*) self.path[pointInPath]];
        [theWord setCenter: nextPoint];
        self.chainPtrToPath[i]=[NSNumber numberWithInt:pointInPath];
    }
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



- (void) addNewWordFor: (UILabel*)addWord withFontSize: (int) fontSize
{
    
    UILabel* lastWord = (UILabel*) self.chain[[self.chain count]-1];
    CGRect intersection = CGRectIntersection(addWord.frame, lastWord.frame);
    CGPoint center = CGPointMake(intersection.origin.x + intersection.size.width/2.0, intersection.origin.y+intersection.size.height/2.0);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize]};
    CGSize size = [addWord.text sizeWithAttributes:attributes];
    CGRect frame = CGRectMake(center.x-size.width/2.0, center.y-size.height/2.0, size.width, size.height);
    UILabel* newWord = [[UILabel alloc] initWithFrame:frame];
    newWord.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize];
    newWord.textAlignment = UITextAlignmentCenter;
    newWord.textColor = [UIColor blackColor];
    newWord.backgroundColor = addWord.textColor;
    newWord.text = addWord.text;
    [self addSubview:newWord];
    self.lastWordNotYetAdded=newWord;

    
}

- (CGPoint) CGPointFromArray: (NSArray*) array
{
    return CGPointMake([(NSNumber*)array[0] floatValue], [(NSNumber*)array[1] floatValue]);
}
- (NSArray*) NSArrayFromCGPoint: (CGPoint) point
{
    return @[[NSNumber numberWithFloat:point.x],[NSNumber numberWithFloat:point.y]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
