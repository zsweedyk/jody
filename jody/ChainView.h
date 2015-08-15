//
//  ChainView.h
//  jody
//
//  Created by Z Sweedyk on 8/14/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChainView : UIView

@property int fontSize;
@property (strong,nonatomic) NSMutableArray* chain;


- (id) initWithFrame: (CGRect) frame andWords: (NSMutableArray*) words andDeletedFlags:(NSMutableArray*) deleted;
- (void) addFirstWord: (int) i atLocation: (CGPoint) position;
- (void) moveFingerTo: (CGPoint) location;
- (void) animateEnd;
- (void) reset;

@end
