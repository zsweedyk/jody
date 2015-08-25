//
//  SharedImage.m
//  jody
//
//  Created by Z Sweedyk on 8/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "NWSharedImage.h"

@implementation NWSharedImage

@dynamic screenShot;
@dynamic createdBy;


+ (id)object {
    NWSharedImage* sharedImage = [super object];
    return sharedImage;
}


+ (NSString*)parseClassName;
{
    return @"NWSharedImage";
}

@end
