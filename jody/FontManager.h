//
//  FontManager.h
//  jody
//
//  Created by Z Sweedyk on 8/20/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontManager : NSObject

@property int headlineFontSize;
@property int chainFontSize;
@property int startScreenSmallFontSize;
@property int startScreenLargeFontSize;
@property int infoScreenFontSize;
@property int toolBarFontSize;

+ (id)sharedManager;


@end
