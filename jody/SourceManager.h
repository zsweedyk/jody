//
//  Sources.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//



#import "NWSource.h"
#import <Foundation/Foundation.h>

@protocol SourceDelegate <NSObject>

- (void)frontPagesCreated;

@end

@interface SourceManager : NSObject

@property (nonatomic, weak) id<SourceDelegate> delegate;

+ (id)sharedManager;
- (void) getSources;
- (bool) sourcesUpToDate;
- (NSString*) urlForSource: (int) i;
- (NSString*) rssFeedForSource: (int) i;
- (UIImage*) frontPageImageForSource: (int) i;
- (UIColor*) colorForSource: (int) i;
- (NSDate*) updateDateForSource: (int) i;
- (int) numberForSource: (NSString*) sourceName;



@end
