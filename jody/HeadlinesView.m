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

- (int)addHeadline:(NSString*) headline withColor:(UIColor*)color andFontSize: (int) fontSize
{
    
    // check for bad characters -- if so, we assume it is not a headline
    NSCharacterSet *badCharacters=[NSCharacterSet characterSetWithCharactersInString:@"@#%&"];

    if ([headline rangeOfCharacterFromSet:badCharacters].location != NSNotFound) {
        return 0;
    }
    
    // for now get the words
    NSMutableArray* tempWords = [NSMutableArray arrayWithArray:[headline componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
    NSCharacterSet *trimCharacters=[NSCharacterSet characterSetWithCharactersInString:@"\n\t"];
    // get rid of empty words cause by end-of-line, tabs etc.
    // these should be eliminated in tempWords -- but they aren't
    NSMutableArray* words = [[NSMutableArray alloc] initWithCapacity:[tempWords count]];
    int wordCount=0;
    for (id obj in tempWords) {
        NSString* word = (NSString*) obj;
        word=[word stringByTrimmingCharactersInSet:trimCharacters];
        if (![word isEqualToString:@""]) {
            [words insertObject:word atIndex:wordCount];
            wordCount++;
        }
    }

    // compute how many lines we need and which words will fall on which lines
    NSMutableArray* lineNumber = [[NSMutableArray alloc] initWithCapacity:[words count]];
    NSMutableArray* wordWidth = [[NSMutableArray alloc] initWithCapacity:[words count]];
    NSMutableArray* lineWidthSoFar = [[NSMutableArray alloc] initWithCapacity:[words count]];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize]};
    
    // determine how many lines we need to display headline
    int lineCount=0;
    CGFloat widthSoFar=0;
    CGFloat maxHeightOfWord=0;
    for (int i=0; i<wordCount; i++) {
        NSString* word = [words objectAtIndex:i];
        // remember max frame height (will these all be the same?)
        CGSize frameSize = [word sizeWithAttributes:attributes];
        if (maxHeightOfWord<frameSize.height) {
            maxHeightOfWord=frameSize.height;
        }
        // remember width
        [wordWidth insertObject:[NSNumber numberWithFloat: frameSize.width] atIndex:i];
        
        // can we add the word to the current line?
        if (widthSoFar+frameSize.width<self.frame.size.width*.80 || widthSoFar==0) {
            widthSoFar += frameSize.width;
        }
        else {
            lineCount++;
            widthSoFar=frameSize.width;
        }
        [lineNumber insertObject:[NSNumber numberWithInt: lineCount] atIndex:i];
        [lineWidthSoFar insertObject:[NSNumber numberWithFloat: widthSoFar] atIndex: i];
    }
    lineCount++; // we need to add the last line
    
    // now determine how much space (height) we should allow for each line
    // this is the max number of lines we can handle with 25% space between lines
    CGFloat spacePerLine;
    CGFloat startOfFirstLine;
 
    CGFloat maxSpaceBetweenLines = (self.frame.size.height-maxHeightOfWord*lineCount)/(lineCount+1);
    if (maxSpaceBetweenLines<0) {
        // we don't have enough room
        // we give each line the same space and let them overlap
        spacePerLine = self.frame.size.height/lineCount;
        startOfFirstLine=0;
    }
    else if (maxSpaceBetweenLines>maxHeightOfWord) {
        // we have more than enough space and so we want to display headline in smaller area
        spacePerLine=2*maxHeightOfWord;
        int leftover=(int)(self.frame.size.height - spacePerLine*lineCount);
        startOfFirstLine = arc4random()% leftover;
  
        
    }
    else {
        // otherwise we just allow space up to the word height
        spacePerLine=maxHeightOfWord+maxSpaceBetweenLines;
        startOfFirstLine=0;
        
    }


    // now place words
    int firstWord=0;
    int lastWord;
    
    for (int i=0; i<lineCount; i++) {
        // find last word in this line
        lastWord=firstWord;
        while (lastWord+1<wordCount && [[lineNumber objectAtIndex:lastWord+1] integerValue] == i){
            lastWord++;
        }

        // find the blank space we can allow per word
        CGFloat totalWidth = [[lineWidthSoFar objectAtIndex:lastWord] floatValue];
        CGFloat blankHorizontalSpacePerWord = (self.frame.size.width-totalWidth)/(CGFloat)(lastWord-firstWord+1);
        if (blankHorizontalSpacePerWord<1)
            blankHorizontalSpacePerWord=1;
        
        // find the height of the current row
        CGFloat y = startOfFirstLine+i*spacePerLine;
        int blankVerticalSpaceForLine = spacePerLine-maxHeightOfWord;
        if (blankVerticalSpaceForLine>0) {
            y+=arc4random()%blankVerticalSpaceForLine;
        }

        CGFloat x=0;
        int currentWord = firstWord;
        while (currentWord <= lastWord) {
            x += arc4random()%((int) blankHorizontalSpacePerWord);
            CGRect labelFrame = CGRectMake(x, y, [[wordWidth objectAtIndex:currentWord] floatValue], maxHeightOfWord);
            UILabel* newLabel = [[UILabel alloc] initWithFrame:labelFrame];
            newLabel.text=[words objectAtIndex:currentWord];
            
            // we want to use color but with an alpha of 1
            CGFloat red, green, blue, alpha;
            [color getRed: &red
                    green: &green
                     blue: &blue
                    alpha: &alpha];
            UIColor* textColor = [UIColor colorWithRed: red green:green blue:blue alpha:1];
            newLabel.textColor=textColor;
            
            [newLabel setFont:[UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize]];
            newLabel.numberOfLines = 1;
            newLabel.tag = [self.headlines count];
            newLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeHeadline:)];
            [newLabel addGestureRecognizer:tapGestureRecognizer];
            UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHeadline:)];
            [newLabel addGestureRecognizer:panGestureRecognizer];
            [self addSubview:newLabel];
            [self.headlines addObject: headline];
            x += [(NSNumber*)[wordWidth objectAtIndex:currentWord] floatValue];
            
            currentWord++;
            
        }
        firstWord=lastWord+1;
    }
    return 1;
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

- (void)reset {
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    self.headlines = [[NSMutableArray alloc] init];
}



@end

