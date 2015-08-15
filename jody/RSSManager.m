//
//  RSSManager.m
//  jody
//
//  Created by Z Sweedyk on 7/17/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "SourceManager.h"
#import "RSSManager.h"
#import "AFNetworking.h"


@interface RSSManager()

@property (weak,nonatomic) SourceManager* sourceManager;

@end


@implementation RSSManager

+ (id)sharedManager {
    static RSSManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });

    return sharedMyManager;
}



- (void)getHeadlineFrom: (int) sourceNum {
    
    if (!self.sourceManager) {
        self.sourceManager = [SourceManager sharedManager];
    }
    
    self.headlines = [[NSMutableArray alloc] init];
    NSString* string = [self.sourceManager rssFeedForSource:sourceNum];
    NSAssert(string,@"Headline requested from bad source.");
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // Make sure to set the responseSerializer correctly
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        [XMLParser setShouldProcessNamespaces:YES];
        
        // Leave these commented for now (you first need to add the delegate methods)
        XMLParser.delegate = self;
        [XMLParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Headline"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
    [operation start];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        
        [feeds addObject:[item copy]];
        
        [self.headlines addObject: title];
        
    }
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    

    int numHeadlines = (int)[self.headlines count];
    int choice = arc4random()%numHeadlines;
    if (choice >= [self.headlines count]) {
        NSLog(@"Bad choice of headline.");
    }
    [self.mainVC newHeadline:[self.headlines objectAtIndex:choice]];
    
}



@end
