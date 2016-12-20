//
//  Sources.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface SourceManager : NSObject

@property (strong,nonatomic) UIImage* background;




+ (id)sharedManager;
- (void) updateBackground;
- (NSString*) rssFeedForSource: (int) i;
- (UIColor*) colorForSource: (int) i;




@end
