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


+ (id)sharedManager;
- (void) getSources;
- (BOOL) sourcesUpToDate;
- (NSString*) rssFeedForSource: (int) i;
- (UIImage*) frontPageImageForSource: (int) i;
- (UIColor*) colorForSource: (int) i;




@end
