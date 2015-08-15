//
//  HeadlinesView.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "ChainView.h"
#import "HeadlinesView.h"

@interface HeadlinesView()

@property (strong,nonatomic) ChainView* chainView;
@property CGFloat maxWordHeight;
@property CGFloat minSpaceBetweenWords;
@property (strong,nonatomic) NSMutableArray* deleted;

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
    
    // set horizontal positions and line numbers
    NSMutableArray* wordPositions = [self positions: wordSizes];
    
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

-(CGFloat) spacePerLine: (int)lineCount
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

- (NSMutableArray*)allocateForSpaceWords: (int) number withMinSpace: (CGFloat) minSpace andMaxSpace: (CGFloat) maxSpace
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
    
    NSMutableArray* space = [self randomValues:number+1 withTotal:freeSpace];
    
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

- (NSMutableArray*) positions: (NSArray*) wordSizes
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
    NSLog(@"Max word height: %f, spacePerLine: %f, total: %f", self.maxWordHeight, spacePerLine, spacePerLine*lineCount);
    NSArray* spaceBetweenLines = [self allocateForSpaceWords: (int) lineCount withMinSpace: spacePerLine*lineCount andMaxSpace:self.frame.size.height];
    
    int firstWord=0;
    int lastWord;
    

    CGFloat heightSoFar = 0;
    for (int i=0;i<lineCount;i++) {
        lastWord = (int)[(NSNumber*)[lastWordInLine objectAtIndex:i] integerValue];
        heightSoFar += [(NSNumber*)[spaceBetweenLines objectAtIndex:i] floatValue];
        widthSoFar=0;
        CGFloat minSpaceForWords = [(NSNumber*)[wordWidthInLine objectAtIndex:i] floatValue];
        NSArray* spaceBetweenWords = [self allocateForSpaceWords:lastWord-firstWord+1 withMinSpace:minSpaceForWords andMaxSpace:maxWidth-self.minSpaceBetweenWords];
        
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
    static UIView* fade;
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.chainView) {
            NSLog(@"Problem --- starting new chain when one exists");
        }
        
        // create "fade"
        if (!fade) {
            fade = [[UIView alloc] initWithFrame:self.frame];
            fade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        }
        [self addSubview:fade];
        [self bringSubviewToFront:fade];
  
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
        NSMutableArray* chain = self.chainView.chain;
        [self.chainView removeFromSuperview];
        self.chainView = nil;
        [fade removeFromSuperview];
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

