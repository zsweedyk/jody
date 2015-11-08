//
//  ViewController.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak,nonatomic) IBOutlet UIBarButtonItem* infoButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* saveButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* shareButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* resetButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem* spinButton;



- (IBAction)info:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)spinButtonPressed:(id)sender;

- (void)newHeadline:(NSString*)headline;
- (void)showToolBar: (id)sender;

@end

