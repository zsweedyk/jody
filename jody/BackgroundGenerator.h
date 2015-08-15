//
//  BackgroundGenderator.h
//  jody
//
//  Created by Z Sweedyk on 7/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "frontPage.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundGenerator : NSObject


@property CGFloat diameter;

+ (id)sharedManager;
- (UIImage*)createBackground;
- (UIImage*) createFadedBackgroundFromBackground: (UIImage*)background;

@end
