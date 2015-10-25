//
//  Source.m
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "NWSource.h"

@implementation NWSource

@dynamic sourceName;
@dynamic rssFeed;
@dynamic frontPageUrl;
@dynamic frontPagePdf;

+ (id)object {
    NWSource* source = [super object];
    return source;
}


+ (NSString*)parseClassName;
{
    return @"NWSource";
}

@end
