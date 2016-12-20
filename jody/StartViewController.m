//
//  StartViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//
#import "FontManager.h"
#import "SourceManager.h"
#import "StartViewController.h"
#import "constants.h"

@interface StartViewController()

@property (strong,nonatomic) SourceManager* sourceManager;


@end


@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sourceManager = [SourceManager sharedManager];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.sourceManager updateBackground];
    
    [self performSegueWithIdentifier:@"segueToMainScreen" sender:self];
//    else {
//        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(frontPagesCreated) userInfo:nil repeats:NO];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)frontPagesCreated {
//    [self performSegueWithIdentifier:@"segueToMainScreen" sender:self];
//}

-(BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
