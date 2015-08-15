//
//  ViewController.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak,nonatomic) IBOutlet UIBarButtonItem* resetButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* colorWheelToolBarButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* infoButton;


- (void)spinColorWheel;
- (IBAction)reset:(id)sender;
- (IBAction)bringColorWheelIntoFocus:(id)sender;
- (IBAction)info:(id)sender;
- (void)newHeadline:(NSString*)headline;

@end

