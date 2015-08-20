//
//  HeadlinesView.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "MainViewController.h"
#import <UIKit/UIKit.h>

@interface HeadlinesView : UIView

@property (strong,nonatomic) NSMutableArray* headlines;
@property (strong,nonatomic) NSMutableArray* words;
@property (strong,nonatomic) NSMutableArray* wordChain;

@property int chosenHeadline;

- (int) addHeadline: (NSString*) headline withColor: (UIColor*) color;
- (void) endChain;
- (void) reset;

@end
