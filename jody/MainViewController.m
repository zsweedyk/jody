//
//  ViewController.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "MainViewController.h"
#import "HeadlinesView.h"
#import "ColorWheelView.h"
#import "RSSManager.h"
#import "BackgroundGenerator.h"

@interface MainViewController ()

@property (strong,nonatomic) HeadlinesView* headlinesView;
@property (strong,nonatomic) ColorWheelView* colorWheelView;
@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) UIGestureRecognizer* tapRecognizer;
@property (weak,nonatomic) RSSManager* rssManager;
@property (weak,nonatomic) BackgroundGenerator* bgManager;
@property (strong,nonatomic) UIImageView* background;
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
    
    // create rss manager
    self.rssManager = [RSSManager sharedManager];
    self.rssManager.mainVC = self;
    
    // create background manager
    self.bgManager = [BackgroundGenerator sharedManager];
    
    // create headlines view
    self.headlinesView = [[HeadlinesView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.headlinesView];
    
    // determine font size
    [self determineFontSize];
    
    // create frame for color wheel
    CGFloat diameter = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat colorWheelFrameSize = diameter*.75;
    CGFloat leftX= (self.view.frame.size.width - colorWheelFrameSize)/2.0;
    CGFloat topY = (self.view.frame.size.height-colorWheelFrameSize)/2.0;
    CGRect colorWheelFrame = CGRectMake(leftX, topY, colorWheelFrameSize, colorWheelFrameSize);
    
    // create background of color wheel
    self.bgManager.radius = diameter/2.0;
    self.background = [[UIImageView alloc] initWithFrame:colorWheelFrame];
    self.background.image = [self.bgManager createBackground];
    [self.view addSubview:self.background];
    
    
    // create foreground of color wheel
    self.colorWheelView = [[ColorWheelView alloc] initWithFrame: colorWheelFrame];
    self.colorWheelView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.view addSubview:self.colorWheelView];
    
    // add gesture recognizer for color wheel
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spinColorWheel)];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    
    // set up animation parameters
    self.spinning=false;
    self.transition=false;
    
    // set up color wheel button on tool bar
    [self.colorWheelToolBarButton setImage:[[UIImage imageNamed:@"colorWheelSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // turn off nav bar
    [self.navigationController setNavigationBarHidden:YES];
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
        self.colorWheelView.fade=NO;
        self.background.transform = CGAffineTransformMakeRotation(angle);
        self.colorWheelView.transform = CGAffineTransformMakeRotation(angle);
        [self.colorWheelView setNeedsDisplay];
        [self.background setNeedsDisplay];
        
    }
    else if (self.transition) {
        [self.timer invalidate];
        self.spinning = false;
        self.transition = false;
        self.colorWheelView.fade=YES;
        [self.colorWheelView removeGestureRecognizer:self.tapRecognizer];
        [self.colorWheelView setNeedsDisplay];
        [self.view bringSubviewToFront:self.headlinesView];
        
        
        self.sourceChosen = (int) (angle/(2*3.14159)*9 +.5);
        self.sourceChosen = self.sourceChosen % 9;
        
        
        [self.rssManager getHeadlineFrom: self.sourceChosen];
    }
}

- (void)newHeadline:(NSString *)headline
{
    
    int numHeadlinesAdded=[self.headlinesView addHeadline: headline withColor: [self.colorWheelView.colors objectAtIndex:self.sourceChosen] andFontSize:self.fontSize];
    if (numHeadlinesAdded==0) {
        [self.rssManager getHeadlineFrom: self.sourceChosen];
        NSLog(@"Bad headline from source: %d",self.sourceChosen);
        
    }
    
}

- (void)determineFontSize {
    // 72 pt font is about 1" max in height non-retina
    // 96 pt font is good for full ipad, which is 1024x768 points
    //
    int mySize = MIN(self.view.frame.size.height,self.view.frame.size.width);
    if (mySize>=700) {
        self.fontSize = 96;
    }
    else if (mySize>=400){
        self.fontSize = 72;
    }
    else {
        self.fontSize=56;
    }
    
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
    self.colorWheelView.fade=NO;
    [self.view bringSubviewToFront:self.colorWheelView];
    [self.colorWheelView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
