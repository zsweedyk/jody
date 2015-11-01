//
//  InfoViewController.m
//  jody
//
//  Created by Z Sweedyk on 8/5/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSMutableAttributedString* text=[[NSMutableAttributedString alloc] initWithString:@"Credits:\n"];
    NSRange cRange = NSMakeRange(0, text.length);
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor grayColor]
                 range:cRange];
    
    // credits
    NSMutableAttributedString* addText = [[NSMutableAttributedString alloc]  initWithString: [NSString stringWithFormat:
                                        @"%@\n%@\n\n%@\n",
                                          @"Concept/Design: Jody Zellen",
                                          @"Software Design/Development: Z Sweedyk",
                                          @"This project was funded in part though a 2016 Artists Fellowship grant from the City of Santa Monica."]];
    cRange = NSMakeRange(0, [addText length]);
    [addText addAttribute:NSForegroundColorAttributeName
                 value:[UIColor whiteColor]
                 range:cRange];
    [text appendAttributedString:addText];
    
    //instructions
    addText = [[NSMutableAttributedString alloc]  initWithString: @"\nInstructions\n"];
    cRange = NSMakeRange(0, [addText length]);
    [addText addAttribute:NSForegroundColorAttributeName
                    value:[UIColor grayColor]
                    range:cRange];
    [text appendAttributedString:addText];
    
    addText = [[NSMutableAttributedString alloc]  initWithString: [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n",
                                                                   @"\u2022Spin the wheel to reveal a new headline from today's news.",
                                                                   @"\u2022Tap the wheel or the 'spin' icon to start/stop spinning the wheel.",
                                                                   @"\u2022Drag a word to move it.",
                                                                   @"\u2022Tap a word to delete it.",
                                                                   @"\u2022Press and hold a word and then drag across other words to create a chain.\n"]
                                                                   ];
    cRange = NSMakeRange(0, [addText length]);
    [addText addAttribute:NSForegroundColorAttributeName
                    value:[UIColor whiteColor]
                    range:cRange];
    [text appendAttributedString:addText];
    
    // sources
    addText = [[NSMutableAttributedString alloc]  initWithString: @"\nSources\n"];
    cRange = NSMakeRange(0, [addText length]);
    [addText addAttribute:NSForegroundColorAttributeName
                    value:[UIColor grayColor]
                    range:cRange];
    [text appendAttributedString:addText];
    
    addText = [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
                                                                   @"AsianAge",
                                                                   @"Daily News",
                                                                   @"TheGuardian",
                                                                   @"The National",
                                                                   @"The New York times",
                                                                   @"The Los Angeles Times",
                                                                   @"The Philadelphia Inquirer",
                                                                   @"The Wall Street Joural",
                                                                   @"The Washington Post"]];
               
    cRange = NSMakeRange(0, [addText length]);
    [addText addAttribute:NSForegroundColorAttributeName
                    value:[UIColor whiteColor]
                    range:cRange];
    [text appendAttributedString:addText];
    

    self.textView.attributedText = text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
