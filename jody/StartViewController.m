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
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation) {
        NSLog(@"Problem.");
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    self.navigationController.navigationBarHidden=YES;
    self.navigationController.toolbarHidden = YES;
    self.sourceManager = [SourceManager sharedManager];
    self.sourceManager.delegate = self;
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Default-Portrait@2x~ipad" ofType:@"png"];
//    FontManager* fontManager = [FontManager sharedManager];
//    UIImage* startImage;
//if (fontManager.device == IPAD) {
//        startImage = [UIImage imageWithContentsOfFile:path];
//        [self.imageView setImage:startImage];
//    }
//    else {
//        // add case for mini
//    }
    //[self.imageView setImage:startImage];
    
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
