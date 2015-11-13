//
//  FontManager.m
//  jody
//
//  Created by Z Sweedyk on 8/20/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "FontManager.h"
#import "UIKit/UIKit.h"
#import "constants.h"
#import <sys/utsname.h>


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

@interface FontManager()



@end

@implementation FontManager

+ (id)sharedManager {
    static FontManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.device = UNKNOWN;
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
            self.device = IPAD;
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString* deviceCode =[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            if ([deviceCode isEqualToString:@"iPad2,5"] ||
                [deviceCode isEqualToString:@"iPad4,4"] ||
                [deviceCode isEqualToString:@"iPad4,5"]) {
                self.device = IPAD_MINI;
            }
        }
        else {
            if (SCREEN_MAX_LENGTH == 480)
            {
                self.device = IPHONE_4;
            }
            if (SCREEN_MAX_LENGTH == 568.0) {
                self.device = IPHONE_5;
            }
            else if (SCREEN_MAX_LENGTH == 667.0) {
                self.device = IPHONE_6;
            }
            else if (SCREEN_MAX_LENGTH == 736.0) {
                self.device = IPHONE_6_PLUS;
            }
            else {
                NSLog(@"size %f", SCREEN_MAX_LENGTH);
            }
        }
        self.headlineFontSize = kHeadlineFontSize[self.device];
        self.chainFontSize = kChainFontSize[self.device];
        self.startScreenLargeFontSize = kStartScreenLargeFontSize[self.device];
        self.startScreenSmallFontSize = kStartScreenSmallFontSize[self.device];
        self.infoScreenFontSize = kInfoScreenFontSize[self.device];
        self.toolBarFontSize = kToolBarFontSize[self.device];
    }
    
    return self;

}


@end
