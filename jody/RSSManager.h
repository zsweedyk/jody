//
//  RSSManager.h
//  jody
//
//  Created by Z Sweedyk on 7/17/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"

@interface RSSManager : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
}

@property (strong, nonatomic) NSString* headline;
@property (weak,nonatomic) MainViewController* mainVC;
@property (strong,nonatomic) NSMutableArray* headlines;

+ (id)sharedManager;
- (void)getHeadlineFrom: (int) source;

@end
