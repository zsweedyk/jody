//
//  ViewController.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

enum {
    IN_FOCUS_WAITING =0,
    OUT_OF_FOCUS = 1,
    SPINNING = 2
};

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
@property (strong,nonatomic) UIButton* showToolBarButton;
@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) UIGestureRecognizer* tapRecognizer;
@property (weak,nonatomic) RSSManager* rssManager;
@property (weak,nonatomic) BackgroundGenerator* bgManager;
@property (strong,nonatomic) UIImageView* background;
@property (strong,nonatomic) UIImage* backgroundImage;
@property (strong,nonatomic) UIImage* fadedBackgroundImage;
@property int sourceChosen;
@property int colorWheelState;
@property double colorWheelAngle;
@property BOOL toolBarUsed;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sourceChosen=-1;
    
    // set up tool bar
    [self setUpToolBar];
    
    // create source manager
    self.sourceManager = [SourceManager sharedManager];

    // create headlines view
    self.headlinesView = [[HeadlinesView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.headlinesView];

    // set up color wheel button on tool bar

    
    // turn off nav bar
    [self.navigationController setNavigationBarHidden:YES];
    
    // create rss manager
    self.rssManager = [RSSManager sharedManager];
    self.rssManager.mainVC = self;
    
    
    // create frame for color wheel
    CGFloat myDiameter = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat colorWheelFrameSize = floor(myDiameter*.85);
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
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spin:)];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    
    // set up color wheel state
    self.colorWheelState = IN_FOCUS_WAITING;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self hideToolBarWithDelay:1.0];
}

- (void)setUpToolBar
{
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.backgroundColor = [UIColor blackColor];
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
    self.navigationController.toolbar.translucent = NO;

    
    // set text on tool bar
    // need to set up sizes for different devices
    NSUInteger size = 10;
    UIFont * font = [UIFont boldSystemFontOfSize:size];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [self.infoButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.shareButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.resetButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.spinButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    CGRect rect = self.navigationController.toolbar.frame;
    self.showToolBarButton = [[UIButton alloc] initWithFrame:rect];
    self.showToolBarButton.backgroundColor=[UIColor blackColor];
    self.showToolBarButton.enabled=NO;
    [self.showToolBarButton addTarget:self action:@selector(showToolBar:) forControlEvents:UIControlEventTouchUpInside];
    
    // timer disabled for testing
    //NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkToolBarTimer) userInfo:nil repeats:YES];
    self.toolBarUsed=NO;
    
}
                      
- (void)checkToolBarTimer
{
    static int cyclesWaited=0;
    
    // tool bar is shown and wheel is not spinning
    if (self.showToolBarButton.enabled==NO && !(self.colorWheelState==SPINNING)) {
        // we wait until it has been unused for a full cycle to hide it
        
        if (!self.toolBarUsed) {
            if (cyclesWaited>=1) {
                cyclesWaited=0;
                [self hideToolBarWithDelay:0];
            }
            else {
                cyclesWaited++;
            }
        }
        else {
            self.toolBarUsed=NO;
            cyclesWaited=0;
        }
    }
}

- (void)hideToolBarWithDelay: (float) delay
{
    CGRect newRect = self.navigationController.toolbar.frame;
    newRect.origin.y += 40;
    [UIView animateWithDuration:1.0
                          delay:delay
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.navigationController.toolbar.frame = newRect;
                         
                     }
                     completion:^(BOOL finished){
                         [self enableShowToolBarButton];
                     }];
}

- (void) enableShowToolBarButton {
    [self.navigationController.view addSubview:self.showToolBarButton];
    self.showToolBarButton.enabled=YES;
    self.toolBarUsed=NO;
}


- (void)showToolBar: (id)sender {
    
    self.showToolBarButton.enabled=NO;
    [self.showToolBarButton removeFromSuperview];
    CGRect newRect = self.navigationController.toolbar.frame;
    newRect.origin.y -= 40;
    [UIView animateWithDuration:1.0
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.navigationController.toolbar.frame = newRect;
                         
                     }
                     completion:^(BOOL finished){
                         self.toolBarUsed=NO;
                     }];
    
}


- (IBAction)spinButtonPressed:(id)sender
{
    self.toolBarUsed=YES;
    [self spin:self];
}

- (void)spin:(id)sender
{
    if (self.colorWheelState == OUT_OF_FOCUS) {
        [self bringColorWheelIntoFocus];
    }
    
    if (self.colorWheelState == IN_FOCUS_WAITING) {
        // start spinning
        self.timer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        self.colorWheelState = SPINNING;
    }
    else if (self.colorWheelState == SPINNING) {
        [self.timer invalidate];
        [self.colorWheelView fade:YES];
        [self.colorWheelView removeGestureRecognizer:self.tapRecognizer];
        [self.colorWheelView setNeedsDisplay];
        [self.view bringSubviewToFront:self.headlinesView];
        self.colorWheelState = OUT_OF_FOCUS;
        int currentAngle = (int) ((self.colorWheelAngle+3.14159/2.0)/(2*3.14159)*9  );
        self.sourceChosen = currentAngle % 9;
        [self.rssManager getHeadlineFrom: self.sourceChosen];
    }
}

- (void) update
{
    self.colorWheelAngle += 3.14159/60.0;
    if (self.colorWheelAngle > 2*3.14159) {
        self.colorWheelAngle -= 2*3.14159;
    }
    self.colorWheelView.transform = CGAffineTransformMakeRotation(self.colorWheelAngle);
    [self.colorWheelView setNeedsDisplay];
    
}

- (void)newHeadline:(NSString *)headline
{
    
    int numHeadlinesAdded=[self.headlinesView addHeadline: headline withColor: [self.sourceManager colorForSource: self.sourceChosen]];
    if (numHeadlinesAdded==0) {
        [self.rssManager getHeadlineFrom: self.sourceChosen];
        NSLog(@"Bad headline from source: %d",self.sourceChosen);
        
    }
}

- (IBAction)reset:(id)sender {
    [self.headlinesView reset];
    [self bringColorWheelIntoFocus];
    self.toolBarUsed=YES;
}

- (IBAction)info:(id)sender {
    [self performSegueWithIdentifier:@"info" sender:self];
    self.toolBarUsed=YES;
}

- (IBAction)share:(id)sender
{
    NSLog(@"share");
    self.toolBarUsed=YES;
}

- (IBAction)save:(id)sender
{
    NSLog(@"save");
    self.toolBarUsed=YES;
}


- (IBAction)bringColorWheelIntoFocus
{
    [self.headlinesView endChain];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    [self.colorWheelView fade:NO];
    [self.view bringSubviewToFront:self.colorWheelView];
    [self.colorWheelView setNeedsDisplay];
    self.colorWheelState = IN_FOCUS_WAITING;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
