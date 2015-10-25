//
//  Source.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface NWSource : PFObject <PFSubclassing>


@property (strong,nonatomic) NSString* sourceName;
@property (strong,nonatomic) NSString* rssFeed;
@property (strong,nonatomic) NSString* frontPageUrl;
@property (strong,nonatomic) PFFile* frontPagePdf;

+ (NSString*) parseClassName;

@end
