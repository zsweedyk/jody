//
//  InfoViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "FontManager.h"
#import "SourceManager.h"
#import "InfoViewController.h"
#import "constants.h"

@interface InfoViewController ()

@property (strong,nonatomic) UIFont* font;
@property (strong,nonatomic) NSDictionary* attrsDictionary;


@end

@implementation InfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FontManager* fontManager = [FontManager sharedManager];
    int fontSize = fontManager.infoScreenFontSize;
    self.font = [UIFont fontWithName:@"Arial" size:fontSize];
    self.attrsDictionary = [NSDictionary dictionaryWithObject:self.font
                                                                forKey:NSFontAttributeName];
    
    self.xButton.titleLabel.font = self.font;
    [self.label setFont:[UIFont fontWithName:@"Arial" size:fontSize+2]];
  
    
    // credits
    NSMutableAttributedString* text = [self createText:@"Credits" withColor:[UIColor grayColor] link:nil newlineCount:2];
    [text appendAttributedString:[self createText:@"Concept/Design: " withColor:[UIColor whiteColor] link:nil newlineCount:0]];
    [text appendAttributedString:[self createText:@"Jody Zellen"  withColor:[UIColor whiteColor] link:@"http://jodyzellen.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Sofware Design/Development: " withColor:[UIColor whiteColor] link:nil newlineCount:0]];
    [text appendAttributedString:[self createText:@"Z Sweedyk" withColor:[UIColor whiteColor] link:@"http://cs.hmc.edu/~z" newlineCount:2]];
    [text appendAttributedString:[self createText:@"This project was funded in part though a 2015 Artists Fellowship grant from the City of Santa Monica." withColor:[UIColor whiteColor] link:nil newlineCount:3]];

    
    //instructions
    [text appendAttributedString:[self createText:@"Instructions" withColor:[UIColor grayColor] link:nil newlineCount:2]];
    [text appendAttributedString:[self createText:@"Spin the wheel to reveal a new headline from today's news." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Tap the wheel or the 'spin' icon to start/stop spinning the wheel." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Drag a word to move it." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Tap a word to delete it." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Press and hold a word and then drag across other words to create a chain." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Tap Save to save screenshot to camera roll." withColor:[UIColor whiteColor] link:nil newlineCount:1]];
    [text appendAttributedString:[self createText:@"Tap share to save to " withColor:[UIColor whiteColor] link:nil newlineCount:0]];
    [text appendAttributedString:[self createText:@"our gallery." withColor:[UIColor whiteColor] link:@"http://www.newswheel.info/gallery.html" newlineCount:3]];
    
    // sources
    [text appendAttributedString:[self createText:@"Sources" withColor:[UIColor grayColor] link:nil newlineCount:2]];
    [text appendAttributedString:[self createText:@"Asian Age" withColor:[UIColor whiteColor] link:@"http://www.asianage.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Guardian" withColor:[UIColor whiteColor] link:@"https://www.theguardian.com/uk" newlineCount:1]];
    [text appendAttributedString:[self createText:@"New York Daily News" withColor:[UIColor whiteColor] link:@"https://www.nydailynews.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"New York Times" withColor:[UIColor whiteColor] link:@"https://www.nytimes.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Los Angeles Times" withColor:[UIColor whiteColor] link:@"https://www.latimes.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"National" withColor:[UIColor whiteColor] link:@"http://www.thenational.ae/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Philadelphia Inquirer" withColor:[UIColor whiteColor] link:@"http://www.philly.com/inquirer/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Wall Street Journal" withColor:[UIColor whiteColor] link:@"http://www.wsj.com/" newlineCount:1]];
    [text appendAttributedString:[self createText:@"Washington Post" withColor:[UIColor whiteColor] link:@"https://www.washingtonpost.com/" newlineCount:1]];
    
    self.textView.attributedText = text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableAttributedString*) createText:(NSString*) string withColor: (UIColor*) color link: (NSString*)url newlineCount: (int) newlineCount
{
    
    self.attrsDictionary = [NSDictionary dictionaryWithObject:self.font
                                                       forKey:NSFontAttributeName];
    NSDictionary *dictionary = @{NSFontAttributeName: self.font,
                                 NSForegroundColorAttributeName: color};

    NSMutableString* newString = [NSMutableString stringWithString:string];
    for (int i=0;i<newlineCount;i++) {
        [newString appendFormat:@"\n"];
    }
    NSMutableAttributedString* newAttString = [[NSMutableAttributedString alloc] initWithString:(NSString*)newString attributes:dictionary];
    
    if (url) {
        NSRange cRange = NSMakeRange(0, newAttString.length);
        [newAttString addAttribute: NSLinkAttributeName value: url range: cRange];
    }
    return newAttString;
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
