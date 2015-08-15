//
//  StartViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//
#import "SourceManager.h"
#import "StartViewController.h"

@interface StartViewController()

@property (strong,nonatomic) SourceManager* sourceManager;

@end


@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation) {
        NSLog(@"Problem.");
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
     self.navigationController.navigationBarHidden=YES;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:@"News Wheel"];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,10)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(1,1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(2,3)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(3,4)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(4,5)];
    //[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(6,7)];

    self.titleLabel.attributedText = attributedString;
    
    self.sourceManager = [SourceManager sharedManager];
    self.sourceManager.delegate = self;

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.activityIndicator startAnimating];
    if (!self.sourceManager.sourcesUpToDate) {
        [self.sourceManager getSources];
    }
    else {
        [self performSegueWithIdentifier:@"colorWheel" sender:self];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)frontPagesCreated {
    [self performSegueWithIdentifier:@"colorWheel" sender:self];
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
