//
//  UIImage+crop.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (crop)

- (UIImage*)crop: (CGRect) rect;
- (UIImage *)scaleImageToSize:(CGSize)newSize;
@end
