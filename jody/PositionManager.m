//
//  PositionManager.m
//  jody
//
//  Created by Z Sweedyk on 8/15/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "PositionManager.h"

@interface PositionManager()


@property CGFloat maxWordHeight;
@property CGFloat minSpaceBetweenWords;
@property  CGRect frame;

@end

@implementation PositionManager


+ (id)sharedManager {
    static PositionManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (NSMutableArray*) positionForWordsWithSizes: (NSArray*) wordSizes inFrame: (CGRect) frame maxWordHeight: (CGFloat) maxWordHeight andMinSpaceBetweenWords: (CGFloat) minSpaceBetweenWords withRandomness:(bool)randomness {

    self.frame = frame;
    self.maxWordHeight=maxWordHeight;
    self.minSpaceBetweenWords=minSpaceBetweenWords;
    return[self positions: wordSizes randomness: randomness];
}


- (CGFloat) spacePerLine: (int)lineCount
{
    // determine how much space (height) we should allow for each line
    // if we are aiming for 25% of word height spacing between lines
    CGFloat spacePerLine;
    CGFloat maxSpaceBetweenLines = (self.frame.size.height-self.maxWordHeight*lineCount)/(lineCount+1);
    if (maxSpaceBetweenLines<0) {
        // we don't have enough room
        // we give each line the same space and let them overlap
        spacePerLine = self.frame.size.height/lineCount;
    }
    else if (maxSpaceBetweenLines>self.maxWordHeight*.25) {
        // we have more than enough space and so we want to display headline in smaller area
        spacePerLine=1.25*self.maxWordHeight;
        
    }
    else {
        // otherwise we just allow space up to the word height
        spacePerLine=self.maxWordHeight+maxSpaceBetweenLines;
    }
    return spacePerLine;
}

- (NSMutableArray*)allocateForSpaceWords: (int) number withMinSpace: (CGFloat) minSpace andMaxSpace: (CGFloat) maxSpace withRandomness: (bool) randomness
{
    CGFloat freeSpace = maxSpace-minSpace;
    
    if (freeSpace<0) {
        freeSpace=0;
    }
    CGFloat endSpace=0;
    if (freeSpace>2*minSpace) {
        endSpace = freeSpace-2*minSpace;
        freeSpace = 2*minSpace;
    }
    else {
        endSpace = 0;
    }
    endSpace /= 2.0;
    
    NSMutableArray* space;
    if (randomness) {
        space = [self randomValues:number+1 withTotal:freeSpace];
    }
    else {
        space = [[NSMutableArray alloc] initWithCapacity:number+1];
        for (int i=0;i<number+1;i++) {
            space[i]= [NSNumber numberWithFloat:freeSpace/(float)(number+1)];
        }
    }
    
    // now add endspace
    CGFloat firstSpace = [(NSNumber*) space[0] floatValue];
    space[0] = [NSNumber numberWithFloat:firstSpace+endSpace];
    
    return space;
}

- (NSMutableArray*) randomValues: (int) number withTotal: (CGFloat) total
{
    NSMutableArray* rands = [[NSMutableArray alloc] initWithCapacity:number];
    int sum=0;
    for (int i=0;i<number;i++) {
        CGFloat val=0;
        if (total>0)
            val = (arc4random()%((int)ceil(total*1000)))/1000.0;
        rands[i] = [NSNumber numberWithFloat:val];
        sum +=val;
    }
    if (total==0)
        return rands;
    for (int i=0;i<number-1;i++) {
        CGFloat val = [(NSNumber*)rands[i] floatValue];
        rands[i] = [NSNumber numberWithFloat:val/sum*total];
    }
    return rands;
}

- (NSMutableArray*) positions: (NSArray*) wordSizes randomness: (bool)randomness
{
    NSMutableArray* positions = [[NSMutableArray alloc] initWithCapacity:[wordSizes count]];
    
    // first we go through and figure out which words to put on each line
    CGFloat widthSoFar=0;
    int wordsPlaced=0;
    NSMutableArray* lastWordInLine = [[NSMutableArray alloc] init];
    NSMutableArray* wordWidthInLine = [[NSMutableArray alloc] init];
    CGFloat maxWidth=self.frame.size.width;
    for (id wordSize in wordSizes) {
        CGFloat wordWidth = [(NSNumber*) (NSArray*)wordSize[0]  floatValue];
        // can we add the word to the current line?
        
        if ((widthSoFar+wordWidth + self.minSpaceBetweenWords <maxWidth*.95 ) || widthSoFar==0) {
            widthSoFar += wordWidth+self.minSpaceBetweenWords;
            wordsPlaced++;
        }
        else {
            [lastWordInLine insertObject: [NSNumber numberWithInt:wordsPlaced-1] atIndex:[lastWordInLine count]];
            [wordWidthInLine insertObject:[NSNumber numberWithFloat:widthSoFar] atIndex:[wordWidthInLine count]];
            widthSoFar=wordWidth+self.minSpaceBetweenWords;
            wordsPlaced++;
        }
    }
    // we need to record the last line
    [lastWordInLine insertObject: [NSNumber numberWithInt:wordsPlaced-1] atIndex:[lastWordInLine count]];
    [wordWidthInLine insertObject:[NSNumber numberWithFloat:widthSoFar] atIndex:[wordWidthInLine count]];
    
    // now we go through and determine actual positions
    int lineCount = (int)[lastWordInLine count];
    CGFloat spacePerLine = [self spacePerLine:lineCount];
    //NSLog(@"Max word height: %f, spacePerLine: %f, total: %f", self.maxWordHeight, spacePerLine, spacePerLine*lineCount);
    NSArray* spaceBetweenLines = [self allocateForSpaceWords: (int) lineCount withMinSpace: spacePerLine*lineCount andMaxSpace:self.frame.size.height withRandomness: randomness];
    
    int firstWord=0;
    int lastWord;
    
    
    CGFloat heightSoFar = 0;
    for (int i=0;i<lineCount;i++) {
        lastWord = (int)[(NSNumber*)[lastWordInLine objectAtIndex:i] integerValue];
        heightSoFar += [(NSNumber*)[spaceBetweenLines objectAtIndex:i] floatValue];
        widthSoFar=0;
        CGFloat minSpaceForWords = [(NSNumber*)[wordWidthInLine objectAtIndex:i] floatValue];
        NSArray* spaceBetweenWords = [self allocateForSpaceWords:lastWord-firstWord+1 withMinSpace:minSpaceForWords andMaxSpace:maxWidth-self.minSpaceBetweenWords withRandomness:randomness];
        
        for (int j=firstWord; j<=lastWord; j++) {
            CGFloat x = widthSoFar + [(NSNumber*)[spaceBetweenWords objectAtIndex:j-firstWord] floatValue];
            [positions insertObject:@[[NSNumber numberWithFloat:x],[NSNumber numberWithFloat:heightSoFar]] atIndex:[positions count]];
            widthSoFar += self.minSpaceBetweenWords + [(NSNumber*)[(NSArray*)[wordSizes objectAtIndex:j] objectAtIndex:0] floatValue];
        }
        heightSoFar += self.maxWordHeight;
        firstWord=lastWord+1;
        
    }
    return positions;
}

@end
