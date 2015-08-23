//
//  StartViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//
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
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation) {
        NSLog(@"Problem.");
    }
    
    //TODO: change font size depending on device
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
     self.navigationController.navigationBarHidden=YES;
    
//    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc]  initWithString:@"News "];
//    [attributedString1 addAttribute:NSBackgroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,5)];
//    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontName size:48] range:NSMakeRange(0,5)];
//    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
//    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(1,2)];
//    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(2,3)];
//    
//    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:@"Wheel  " ];
//    [attributedString2 addAttribute:NSBackgroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,6)];
//    [attributedString2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontName size:48] range:NSMakeRange(0,6)];
//    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,1)];
//    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(1,2)];
//    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(2,3)];
//    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3,4)];
//  
//
//
//    [attributedString1 appendAttributedString:attributedString2];
//    self.titleLabel.attributedText = attributedString1;
//    
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontName size:48]};
//    CGSize labelSize = [@"News Wheel  " sizeWithAttributes:attributes];
//    CGFloat x = (self.view.frame.size.width - labelSize.width)/2.0;
//    CGFloat y = (self.view.frame.size.height - labelSize.height)/2.0;
//    CGRect frame = CGRectMake(x, y, labelSize.width, labelSize.height);
//    NSLog(@"old frame Width %f",self.titleLabel.frame.size.width);
//    self.titleLabel.frame = frame;
//    
//    
    self.sourceManager = [SourceManager sharedManager];
    self.sourceManager.delegate = self;

    
}

- (void)viewDidAppear:(BOOL)animated
{

    if (!self.sourceManager.sourcesUpToDate) {
        [self.sourceManager getSources];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(frontPagesCreated) userInfo:nil repeats:NO];
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
