//
//  StartViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//
#import <sys/utsname.h>
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
    
   
    self.sourceManager = [SourceManager sharedManager];
    self.sourceManager.delegate = self;
    
    // set up start screen image
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    if (screenSize.width == 640) {
        if (screenSize.height == 1136) {
            [self.imageView setImage: [UIImage imageNamed: @"default-portrait-640x1136.png"]];
        }
        else {
            [self.imageView setImage: [UIImage imageNamed: @"default-portrait-640x960.png"]];
        }
    }
    else if (screenSize.width == 750) {
        [self.imageView setImage: [UIImage imageNamed: @"default-portrait-750x1334.png"]];
        
    }
    else if (screenSize.width == 768) {
        [self.imageView setImage: [UIImage imageNamed: @"default-portrait-768x1024.png"]];
        
    }
    else if (screenSize.width == 1242) {
        [self.imageView setImage: [UIImage imageNamed: @"default-portrait-1242x2208.png"]];
        
    }
    else if (screenSize.width == 1536) {
        [self.imageView setImage: [UIImage imageNamed: @"default-portrait-1536x2048.png"]];
    }
    else {
        [self.imageView setImage: [UIImage imageNamed: @"default-portrait-640x960.png"]];
    }
    
    
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
    [self performSegueWithIdentifier:@"ColorWheel" sender:self];
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
