//
//  SharedImage.h
//  jody
//
//  Created by Z Sweedyk on 8/24/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Parse/Parse.h>

@interface NWSharedImage : PFObject <PFSubclassing>

@property (strong,nonatomic) PFFile* screenShot;
@property (strong,nonatomic) NSString* createdBy;

+ (NSString*) parseClassName;

@end
