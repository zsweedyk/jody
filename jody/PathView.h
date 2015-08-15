//
//  PathView.h
//  jody
//
//  Created by Z Sweedyk on 8/14/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathView : UIImageView


- (void)drawLineFrom: (CGPoint) startPoint To: (CGPoint) endPoint;
- (void)eraseLineFrom: (CGPoint) startPoint To: (CGPoint) endPoint;

@end
