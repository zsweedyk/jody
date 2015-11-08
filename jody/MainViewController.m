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
    SPINNING = 2,
};

#import "FontManager.h"
#import "NWSharedImage.h"
#import "SourceManager.h"
#import "MainViewController.h"
#import "HeadlinesView.h"
#import "ColorWheelView.h"
#import "RSSManager.h"
#import "BackgroundGenerator.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@property (strong,nonatomic) SourceManager* sourceManager;
@property (strong,nonatomic) HeadlinesView* headlinesView;
@property (strong,nonatomic) ColorWheelView* colorWheelView;
@property (strong,nonatomic) UIButton* showToolBarButton;
@property (strong,nonatomic) NSTimer* colorWheelTimer;
@property (strong,nonatomic) UIGestureRecognizer* tapRecognizer;
@property (weak,nonatomic) RSSManager* rssManager;
@property (weak,nonatomic) BackgroundGenerator* bgManager;
@property (strong,nonatomic) UIImageView* background;
@property (strong,nonatomic) UIImage* backgroundImage;
@property (strong,nonatomic) UIImage* fadedBackgroundImage;
@property int sourceChosen;
@property int colorWheelState;
@property double colorWheelAngle;
@property double finalAngle;
@property BOOL toolBarUsed;
@property (strong,nonatomic) UILabel* shareConfirmationLabel;
@property (strong,nonatomic) UILabel* saveConfirmationLabel;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sourceChosen=-1;
    
    // turn off nav bar
    [self.navigationController setNavigationBarHidden:YES];
    
    // set up tool bar
    [self setUpToolBar];
    
    // set up confirmation label (for saving sharing image)
    [self setUpConfirmationLabels];
    
    // create source manager
    self.sourceManager = [SourceManager sharedManager];

    // create frame for color wheel
    CGRect myFrame = self.view.frame;
    CGFloat diameter = MIN(myFrame.size.width, myFrame.size.height);
    CGFloat colorWheelFrameSize = floor(diameter*.90);
    // we get artifacts if the frame isn't an even integers
    if ((colorWheelFrameSize/2)*2 != colorWheelFrameSize) {
        colorWheelFrameSize +=-1;
    }
    CGFloat leftX= (myFrame.size.width - colorWheelFrameSize)/2.0;
    CGFloat topY = (myFrame.size.height-colorWheelFrameSize)/2.0;
    CGRect colorWheelFrame = CGRectMake(leftX, topY, colorWheelFrameSize, colorWheelFrameSize);
    
    // create background view
    self.bgManager = [BackgroundGenerator sharedManager];
    self.bgManager.diameter = colorWheelFrameSize;
    self.backgroundImage = [self.bgManager createBackground];
    self.fadedBackgroundImage = [self.bgManager createFadedBackgroundFromBackground:self.backgroundImage];

    // create color wheel view
    self.colorWheelView = [[ColorWheelView alloc] initWithFrame: colorWheelFrame withBackgroundImage: self.backgroundImage andFadedBackgroundImage:self.fadedBackgroundImage];
    [self.view addSubview:self.colorWheelView];
    
    // add gesture recognizer for color wheel
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spin:)];
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    
    // set up color wheel state
    self.colorWheelState = IN_FOCUS_WAITING;
    [self.colorWheelView addGestureRecognizer:self.tapRecognizer];
    
    // create headlines view
    CGRect toolBarFrame = self.navigationController.toolbar.frame;
    CGRect headlineFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - toolBarFrame.size.height);
    self.headlinesView = [[HeadlinesView alloc] initWithFrame:headlineFrame];
    [self.view addSubview:self.headlinesView];
    self.headlinesView.startX = leftX + diameter/2.0;
    self.headlinesView.startY = topY;
    [self.headlinesView addGestureRecognizer:self.tapRecognizer];
    
    // create rss manager
    self.rssManager = [RSSManager sharedManager];
    self.rssManager.mainVC = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self hideToolBarWithDelay:1.0];
}

-(BOOL) shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - tool bar methods
- (void)setUpToolBar
{
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.backgroundColor = [UIColor blackColor];
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
    self.navigationController.toolbar.translucent = NO;

    // set text on tool bar
    // need to set up sizes for different devices
    FontManager* fontManager = [FontManager sharedManager];
    NSUInteger size = fontManager.toolBarFontSize;
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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkToolBarTimer) userInfo:nil repeats:YES];
    self.toolBarUsed=NO;
}

- (void)checkToolBarTimer
{
    static int cyclesWaited=0;
    // tool bar is shown and wheel is not spinning
    if (self.showToolBarButton.enabled==NO && !(self.colorWheelState==SPINNING)) {
        // we wait until it has been unused for three full cycle to hide it
        
        if (!self.toolBarUsed) {
            if (cyclesWaited>=3) {
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
    self.showToolBarButton.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:self.showToolBarButton];
    [UIView animateWithDuration:1.0
                          delay:delay
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.showToolBarButton.backgroundColor=[UIColor blackColor];
                     }
                     completion:^(BOOL finished){
                         self.showToolBarButton.enabled=YES;
                         self.toolBarUsed=NO;
                     }];
}

- (void)showToolBar: (id)sender {
    self.showToolBarButton.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:self.showToolBarButton];
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.showToolBarButton.backgroundColor=[UIColor clearColor];
                         
                     }
                     completion:^(BOOL finished){
                         self.showToolBarButton.enabled=NO;
                         [self.showToolBarButton removeFromSuperview];
                         self.toolBarUsed=NO;
                     }];
}

#pragma mark - spin methods

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
        self.headlinesView.enableInput=NO; // we disable input on the headline view while the color wheel is spinning
        self.colorWheelTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.colorWheelTimer forMode:NSDefaultRunLoopMode];
        self.colorWheelState = SPINNING;
        [self.view bringSubviewToFront:self.headlinesView];
    }
    else if (self.colorWheelState == SPINNING) {
        self.finalAngle = self.colorWheelAngle+3.14159;
        [self colorWheelStoppedSpinning];
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

- (void) colorWheelStoppedSpinning
{
    [self.colorWheelTimer invalidate];
    self.sourceChosen= ((int) ((self.colorWheelAngle+3.14159/4.0)/(2*3.14159)*9  )+2)%9;
    [self.colorWheelView fade:YES];
    self.colorWheelState = OUT_OF_FOCUS;
    [self.colorWheelView setNeedsDisplay];
    [self.view bringSubviewToFront:self.headlinesView];
    self.headlinesView.enableInput=YES;
    [self.rssManager getHeadlineFrom: self.sourceChosen];
}

- (void)newHeadline:(NSString *)headline
{
    int numHeadlinesAdded=[self.headlinesView addHeadline: headline withColor: [self.sourceManager colorForSource: self.sourceChosen]];
    if (numHeadlinesAdded==0) {
        [self.rssManager getHeadlineFrom: self.sourceChosen];
    }
}

#pragma mark - other IBActions

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
    [self showConfirmationMessage:self.shareConfirmationLabel];
    UIImage* screenShot = [self getScreenShot];
    NSData * imgData = UIImagePNGRepresentation(screenShot);
    if(imgData) {
        NWSharedImage* sharedImage = [[NWSharedImage alloc] init];
        sharedImage.screenShot = [PFFile fileWithData:imgData];
    
        [sharedImage.screenShot saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [sharedImage saveInBackground];
            }
        }];
    }
    else {
        NSLog(@"error while taking screenshot");
    }
}

- (IBAction)save:(id)sender
{
    [self showConfirmationMessage:self.saveConfirmationLabel];
    UIImage* screenShot = [self getScreenShot];
    UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil);
    self.toolBarUsed=YES;
}

- (IBAction)bringColorWheelIntoFocus
{
    [self.headlinesView endChain];
    [self.colorWheelView fade:NO];
    [self.view bringSubviewToFront:self.colorWheelView];
    [self.colorWheelView setNeedsDisplay];
    self.colorWheelState = IN_FOCUS_WAITING;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - confirmation message handlers

- (void) setUpConfirmationLabels
{
    
    self.saveConfirmationLabel = [self createConfirmationLabelForText: @" Saved to camera roll. "];
    self.shareConfirmationLabel = [self createConfirmationLabelForText: @" Shared at www.newswheel.info/gallery.  "];
}

- (UILabel*) createConfirmationLabelForText: (NSString*)text;
{
    FontManager* fontManager = [FontManager sharedManager];
    int fontSize = fontManager.infoScreenFontSize;
    UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    int x = (self.view.frame.size.width-textSize.width*1.5)/2.0;
    int y = (self.view.frame.size.height-textSize.height*3)/2.0;
    CGRect frame = CGRectMake(x, y, textSize.width*1.5, textSize.height*3);
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.text = text;
    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void) showConfirmationMessage: (UILabel*) label
{
    __block UILabel* theLabel = label;
    theLabel.alpha = 1;
    [self.view addSubview:theLabel];
    
    [UIView animateWithDuration:0.5
                          delay:2.0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         theLabel.alpha=0;
                     }
                     completion:^(BOOL finished){
                         [theLabel removeFromSuperview];
                     }];
}

#pragma mark - helpers

- (UIImage*)getScreenShot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenShot =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShot;
}



@end
