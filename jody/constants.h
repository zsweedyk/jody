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
    IPHONE_4 = 0,
    IPHONE_5 = 1,
    IPHONE_6 = 2,
    IPHONE_6_PLUS = 3,
    IPAD = 4,
    IPAD_MINI = 5,
    UNKNOWN= 6
};


enum {
    NYTIMES=0,
    WASHINGTONPOST=1,
    GUARDIAN=2,
    LATIMES=3,
    WALLSTREETJOURNAL=4,
    NYPOST=5,
    NYDAILYNEWS=6,
    ASIANAGE=7,
    NATIONAL=8
};

FOUNDATION_EXPORT int const kSourceCount;
FOUNDATION_EXPORT int const kPDFWidth;
FOUNDATION_EXPORT int const kPDFHeight;
FOUNDATION_EXPORT float const basicColors[9][3];
FOUNDATION_EXPORT NSString* const kFontName;
FOUNDATION_EXPORT int const kHeadlineFontSize[7];
FOUNDATION_EXPORT int const kChainFontSize[7];
FOUNDATION_EXPORT int const kStartScreenSmallFontSize[7];
FOUNDATION_EXPORT int const kStartScreenLargeFontSize[7];
FOUNDATION_EXPORT int const kInfoScreenFontSize[7];
FOUNDATION_EXPORT int const kToolBarFontSize[7];

#endif
