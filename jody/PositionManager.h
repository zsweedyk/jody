//
//  PositionManager.h
//  jody
//
//  Created by Z Sweedyk on 8/15/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface PositionManager : NSObject

+ (id)sharedManager;


- (NSMutableArray*) positionForWordsWithSizes: (NSArray*) wordSizes inFrame: (CGRect) frame maxWordHeight: (CGFloat) maxWordHeight andMinSpaceBetweenWords: (CGFloat) minSpaceBetweenWords withRandomness: (bool) randomness;

@end
