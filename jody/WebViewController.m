//
//  WebViewController.m
//  jody
//
//  Created by Z Sweedyk on 11/8/15.
//  Copyright © 2015 Z Sweedyk. All rights reserved.
//

#import "FontManager.h"
#import "WebViewController.h"

@interface WebViewController ()
@property (strong,nonatomic) NSString* infoHtml;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor=[UIColor blackColor];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
    self.webView.scalesPageToFit=YES;
    
    FontManager* fontManager = [FontManager sharedManager];
    int fontSize = fontManager.infoScreenFontSize;
    UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [self.xButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    self.infoHtml = [htmlString stringByReplacingOccurrencesOfString: @"font-size:TITLE_FONT_SIZE" withString:[NSString stringWithFormat:@"font-size:%dpx",fontSize+2]];
    self.infoHtml = [self.infoHtml stringByReplacingOccurrencesOfString: @"font-size:BODY_FONT_SIZE" withString:[NSString stringWithFormat:@"font-size:%dpx",fontSize]];
    [self.webView loadHTMLString:self.infoHtml baseURL:nil];
}

- (IBAction)xButtonPressed:(id)sender {
    NSString *currentURL = self.webView.request.URL.absoluteString;
    if ([(NSString*)currentURL isEqualToString:@"about:blank"]) {
         [self.navigationController popViewControllerAnimated:NO];
    }
    else {
        [self.webView loadHTMLString:self.infoHtml baseURL:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSURL *currentURL = [[webView request] URL];
    NSLog(@"%@",[currentURL description]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
