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
    
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.backgroundColor = [UIColor blackColor];
  
    self.rssManager = [RSSManager sharedManager];
    self.rssManager.mainVC = self;
    
    self.bgManager = [BackgroundGenerator sharedManager];
 
    
    // create headlines view
    self.headlinesView = [[HeadlinesView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.headlinesView];
    
    // create frame for color wheel
    CGFloat diameter = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat colorWheelFrameSize = diameter*.75;
    CGFloat leftX= (self.view.frame.size.width - colorWheelFrameSize)/2.0;
    CGFloat topY = (self.view.frame.size.height-colorWheelFrameSize)/2.0;
    CGRect colorWheelFrame = CGRectMake(leftX, topY, colorWheelFrameSize, colorWheelFrameSize);
    
    // create background of color wheel
    self.bgManager.radius = diameter/2.0;
    self.background = [[UIImageView alloc] initWithFrame:colorWheelFrame];
    self.background.image = [self.bgManager createBackgroundWithRadius:colorWheelFrameSize/2.0];
//    self.background.image = [UIImage imageNamed:@"newspaperCircle.png"];
//    self.background.contentMode=UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.background];

    
    // create foreground of color wheel

    self.colorWheelView = [[ColorWheelView alloc] initWithFrame: colorWheelFrame];
    self.colorWheelView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.view addSubview:self.colorWheelView];
    
  

    
    // add gesture recognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spinColorWheel)];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];

    // set up animation parameters
    self.spinning=false;
    self.transition=false;
    
    // set up RSS Manager

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
- (IBAction)bringColorWheelIntoFocus:(id)sender
{
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    self.colorWheelView.fade=NO;
    [self.view bringSubviewToFront:self.colorWheelView];
    [self.colorWheelView setNeedsDisplay];
}

- (void) update
{
    if (self.spinning && !self.transition) {
        double oldAngle=self.colorWheelView.angle;
        self.colorWheelView.angle += 3.14159/60.0;
        if (self.colorWheelView.angle > 2*3.14159) {
            self.colorWheelView.angle -= 2*3.14159;
        }
        self.colorWheelView.fade=NO;
        [self.colorWheelView setNeedsDisplay];
        self.background.transform = CGAffineTransformMakeRotation(self.colorWheelView.angle-oldAngle);
    }
    else if (self.transition) {
        [self.timer invalidate];
        self.spinning = false;
        self.transition = false;
        self.colorWheelView.fade=YES;
        [self.colorWheelView removeGestureRecognizer:self.tapRecognizer];
        [self.colorWheelView setNeedsDisplay];
        [self.view bringSubviewToFront:self.headlinesView];

        
        self.sourceChosen = (int) (self.colorWheelView.angle/(2*3.14159)*9 +.5);
        self.sourceChosen = self.sourceChosen % 10;
        
        
        [self.rssManager getHeadlineFrom: self.sourceChosen];
    }
}

- (void)newHeadline:(NSString *)headline
{
    
    [self.headlinesView addHeadline: headline withColor: [self.colorWheelView.colors objectAtIndex:_sourceChosen]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
