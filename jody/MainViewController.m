//
//  ViewController.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "SourceManager.h"
#import "MainViewController.h"
#import "HeadlinesView.h"
#import "ColorWheelView.h"
#import "RSSManager.h"
#import "BackgroundGenerator.h"

@interface MainViewController ()

@property (strong,nonatomic) SourceManager* sourceManager;
@property (strong,nonatomic) HeadlinesView* headlinesView;
@property (strong,nonatomic) ColorWheelView* colorWheelView;
@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) UIGestureRecognizer* tapRecognizer;
@property (weak,nonatomic) RSSManager* rssManager;
@property (weak,nonatomic) BackgroundGenerator* bgManager;
@property (strong,nonatomic) UIImageView* background;
@property (strong,nonatomic) UIImage* backgroundImage;
@property (strong,nonatomic) UIImage* fadedBackgroundImage;
@property int sourceChosen;
@property BOOL spinning;
@property BOOL transition;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sourceChosen=-1;
    
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.backgroundColor = [UIColor blackColor];
    
    // create source manager
    self.sourceManager = [SourceManager sharedManager];

    // create headlines view
    self.headlinesView = [[HeadlinesView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.headlinesView];
    self.headlinesView.fontSize = [self determineFontSize];
    self.headlinesView.smallFontSize = [self determineSmallFontSize];

    
    // set up color wheel button on tool bar
    [self.colorWheelToolBarButton setImage:[[UIImage imageNamed:@"colorWheelSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // turn off nav bar
    [self.navigationController setNavigationBarHidden:YES];
    
    // create rss manager
    self.rssManager = [RSSManager sharedManager];
    self.rssManager.mainVC = self;
    
    
    // create frame for color wheel
    CGFloat myDiameter = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat colorWheelFrameSize = floor(myDiameter*.75);
    // we get artifacts if the frame isn't an even integers
    if ((colorWheelFrameSize/2)*2 != colorWheelFrameSize) {
        colorWheelFrameSize +=-1;
    }
    
    CGFloat leftX= (self.view.frame.size.width - colorWheelFrameSize)/2.0;
    CGFloat topY = (self.view.frame.size.height-colorWheelFrameSize)/2.0;
    CGRect colorWheelFrame = CGRectMake(leftX, topY, colorWheelFrameSize, colorWheelFrameSize);

    
    // create background
    self.bgManager = [BackgroundGenerator sharedManager];
    self.bgManager.diameter = colorWheelFrameSize;
    self.backgroundImage = [self.bgManager createBackground];
    self.fadedBackgroundImage = [self.bgManager createFadedBackgroundFromBackground:self.backgroundImage];

    self.colorWheelView = [[ColorWheelView alloc] initWithFrame: colorWheelFrame withBackgroundImage: self.backgroundImage andFadedBackgroundImage:self.fadedBackgroundImage];
    [self.view addSubview:self.colorWheelView];
    
    // add gesture recognizer for color wheel
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spinColorWheel)];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    
    // set up animation parameters
    self.spinning=false;
    self.transition=false;
    
}

- (void)spinColorWheel
{
    if (self.spinning) {
        self.transition=true;
    }
    else {
        self.spinning = true;
        self.timer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void) update
{
    static double angle =0;
    if (self.spinning && !self.transition) {
        angle += 3.14159/60.0;
        if (angle > 2*3.14159) {
            angle -= 2*3.14159;
        }
        self.colorWheelView.transform = CGAffineTransformMakeRotation(angle);
        [self.colorWheelView setNeedsDisplay];
    }
    else if (self.transition) {
        [self.timer invalidate];
        self.spinning = false;
        self.transition = false;
        [self.colorWheelView fade:YES];
        [self.colorWheelView removeGestureRecognizer:self.tapRecognizer];
        [self.colorWheelView setNeedsDisplay];
        [self.view bringSubviewToFront:self.headlinesView];
        
        // we want the source that is at the top of the wheel so we add pi/2 to angle
  
        int newAngle = (int) ((angle+3.14159/2.0)/(2*3.14159)*9  );
        //NSLog(@"Original angle: %f and fixed: %d",angle*180/3.14159,newAngle);
        self.sourceChosen = newAngle % 9;
        
        
        [self.rssManager getHeadlineFrom: self.sourceChosen];
    }
}

- (void)newHeadline:(NSString *)headline
{
    
    int numHeadlinesAdded=[self.headlinesView addHeadline: headline withColor: [self.sourceManager colorForSource: self.sourceChosen]];
    if (numHeadlinesAdded==0) {
        [self.rssManager getHeadlineFrom: self.sourceChosen];
        NSLog(@"Bad headline from source: %d",self.sourceChosen);
        
    }
}

- (int)determineFontSize {
    // 72 pt font is about 1" max in height non-retina
    // 96 pt font is good for full ipad, which is 1024x768 points
    //
    int fontSize;
    int mySize = MIN(self.view.frame.size.height,self.view.frame.size.width);
    if (mySize>=700) {
        fontSize = 96;
    }
    else if (mySize>=400){
        fontSize = 72;
    }
    else {
        fontSize=56;
    }
    return fontSize;
}

- (int)determineSmallFontSize {
    int fontSize = [self determineFontSize];
    int smallFontSize;
    if (fontSize==96) {
        smallFontSize = 36;
    }
    else if (fontSize==72) {
        smallFontSize = 28;
    }
    else {
        smallFontSize = 20;
    }
    return smallFontSize;
}

- (IBAction)reset:(id)sender {
    [self.headlinesView reset];
    [self bringColorWheelIntoFocus:self];
    
}

- (IBAction)info:(id)sender {
    [self performSegueWithIdentifier:@"info" sender:self];
}


- (IBAction)bringColorWheelIntoFocus:(id)sender
{
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    [self.colorWheelView fade:NO];
    [self.view bringSubviewToFront:self.colorWheelView];
    [self.colorWheelView setNeedsDisplay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
