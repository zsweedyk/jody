//
//  HeadlinesViewController.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "HeadlinesViewController.h"
#import "AFNetworking.h"

@implementation HeadlinesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";

        NSString *string = [NSString stringWithFormat:@"%@weather.php?format=json", BaseURLString];
        NSURL *url = [NSURL URLWithString:string];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            self.weather = (NSDictionary *)responseObject;            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        // 5
        [operation start];
    


}


@end
