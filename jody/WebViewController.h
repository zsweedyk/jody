//
//  WebViewController.h
//  jody
//
//  Created by Z Sweedyk on 11/8/15.
//  Copyright © 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong,nonatomic) IBOutlet UIWebView* webView;
@property (strong,nonatomic) IBOutlet UIButton* xButton;

- (IBAction)xButtonPressed:(id)sender;

@end
