//
//  HeadlinesView.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/7/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadlinesView : UIView

@property (strong,nonatomic) NSMutableArray* headlines;
@property int chosenHeadline;

- (int) addHeadline: (NSString*) headline withColor: (UIColor*) color andFontSize: (int) fontSize;
- (void) reset;

@end
