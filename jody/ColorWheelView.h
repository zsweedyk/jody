//
//  colorWheelView.h
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface ColorWheelView : UIImageView

//@property double angle;
@property (strong,nonatomic) UIImage* myBackgroundImage;
@property (strong,nonatomic) UIImage* myFadedBackgroundImage;
@property NSMutableArray* colors;

- (void)initBackgroundImage: (UIImage*) backgroundImage andFadedBackgroundImage: (UIImage*)fadedBackgroundImage;
//- (id)initWithFrame: (CGRect) frame withBackgroundImage: (UIImage*) withBackgroundImage andFadedBackgroundImage: (UIImage*) fadedBackgroundImage;
- (void)fade: (bool) fade;

@end
