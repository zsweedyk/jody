//
//  InfoViewController.h
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (weak,nonatomic) IBOutlet UIWebView* webView;

-(IBAction)close:(id)sender;

@end
