//
//  BackgroundGenderator.h
//  jody
//
//  Created by Z Sweedyk on 7/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundGenerator : NSObject

@property(strong,nonatomic) NSArray* sources;
@property CGFloat radius;

+ (id)sharedManager;
- (UIImage*)createBackground;

@end
