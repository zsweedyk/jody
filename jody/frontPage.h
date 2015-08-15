//
//  frontPage.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Parse/Parse.h>

@interface frontPage : PFObject

@property (strong,nonatomic) NSString* source;
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) PFFile* pdf;

@end
