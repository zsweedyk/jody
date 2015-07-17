//
//  ViewController.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak,nonatomic) IBOutlet UILabel* headlineLabel;
- (void)spinColorWheel;
- (IBAction)bringColorWheelIntoFocus:(id)sender;
- (void)newHeadline:(NSString*)headline;

@end

