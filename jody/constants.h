//
//  constants.h
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#ifndef jody_constants_h
#define jody_constants_h


enum {
    UNKNOWN = 0,
    IPHONE_5 = 1,
    IPHONE_6 = 2,
    IPHONE_6_PLUS = 3,
    IPAD = 4,
    IPAD_MINI = 5
};

FOUNDATION_EXPORT int const kSourceCount;
FOUNDATION_EXPORT int const kPDFWidth;
FOUNDATION_EXPORT int const kPDFHeight;
FOUNDATION_EXPORT float const basicColors[9][3];
FOUNDATION_EXPORT NSString* const kFontName;
FOUNDATION_EXPORT int const kHeadlineFontSize[6];
FOUNDATION_EXPORT int const kChainFontSize[6];
FOUNDATION_EXPORT int const kStartScreenSmallFontSize[6];
FOUNDATION_EXPORT int const kStartScreenLargeFontSize[6];

#endif
