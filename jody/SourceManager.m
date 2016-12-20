//
//  Sources.m
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import <sys/utsname.h>
#import "SourceManager.h"
#import "constants.h"
#import "UIImage+PDF.h"
@import CoreGraphics;
#import "math.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))


@interface SourceManager ()

//@property (strong,nonatomic) NSMutableArray* sources;
@property (strong,nonatomic) NSArray* rssFeeds;
@property (strong, nonatomic) NSDate* lastUpdate;
@property (strong,nonatomic) NSString* frontPageUrl;



@end

@implementation SourceManager

+ (id)sharedManager {
    static SourceManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self) {
    
        
        self.rssFeeds =@[@"https://feeds.feedburner.com/nytimes/gTKh",
                             @"https://feeds.feedburner.com/washingtonpost/HBJr",
                             @"https://feeds.feedburner.com/theguardian/bKzI",
                             @"https://feeds.feedburner.com/latimes/Wxwm",
                             @"https://feeds.feedburner.com/wsj/tGpR",
                             @"https://feeds.feedburner.com/philly/oyxv",
                             @"https://feeds.feedburner.com/nydailynews/Fhuw",
                             @"https://feeds.feedburner.com/asianage/Knmy",
                             @"https://feeds.feedburner.com/thenational/uNww"];
        
        
        
        NSString* deviceSize = [self getDeviceSize];
        _frontPageUrl = [NSString stringWithFormat:@"https://www.cs.hmc.edu/~z/newsWheel/nwImage_%@.jpg",deviceSize];
        _lastUpdate = [NSDate distantPast];
        [self updateBackground];
        
    }
    return self;
}

- (NSString*) getDeviceSize {
    NSString* deviceSizeString;
    NSLog(@"%f\n",SCREEN_MAX_LENGTH);
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
        deviceSizeString = @"2048_2732";
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* deviceCode =[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([deviceCode isEqualToString:@"iPad2,5"] ||
            [deviceCode isEqualToString:@"iPad4,4"] ||
            [deviceCode isEqualToString:@"iPad4,5"]) {
            //self.device = IPAD_MINI;
            deviceSizeString = @"1536_2048";
        }
    }
    else {

        if (SCREEN_MAX_LENGTH == 480)
        {
            //self.device = IPHONE_4;
            deviceSizeString = @"640_960";
        }
        if (SCREEN_MAX_LENGTH == 568.0) {
            //self.device = IPHONE_5;
            deviceSizeString = @"640_1136";
        }
        else if (SCREEN_MAX_LENGTH == 667.0) {
            //self.device = IPHONE_6;
            deviceSizeString = @"750_1334";
        }
        else if (SCREEN_MAX_LENGTH == 736.0) {
            //self.device = IPHONE_6_PLUS;
            deviceSizeString = @"1242_2208";
            
        }
        else {
            NSLog(@"size %f", SCREEN_MAX_LENGTH);
        }
    }
    return deviceSizeString;

}


- (void)updateBackground
{
    if (![self sourcesUpToDate]) {

        NSString* deviceSizeString = [self getDeviceSize];
        NSString* path = [NSString stringWithFormat:@"https://www.cs.hmc.edu/~z/newsWheel/nwImage_%@.jpg",deviceSizeString];
        NSURL *url = [NSURL URLWithString:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        UIImage* frontPage = [UIImage imageWithCGImage: image.CGImage scale: 1.0f orientation: UIImageOrientationDownMirrored];
        self.background = nil;
        self.background = frontPage;
        self.lastUpdate = [self lastUpdateDateAtPdfSource];

    }
}


- (BOOL)sourcesUpToDate
{
    // sources are up to date if they have been updated since the source was last update
    NSDate* lastSourceUpdate = [self lastUpdateDateAtPdfSource];
    NSTimeInterval timeInterval = [self.lastUpdate timeIntervalSinceDate: lastSourceUpdate];
    
    bool retVal = ((int) timeInterval)>=0;
    return retVal;
}

- (NSDate*) lastUpdateDateAtPdfSource
{
    // we assume the pdfs at newseum are updated by 6am PST
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate* gmtNow = [NSDate date];
    NSTimeZone* pstZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSInteger interval = [pstZone secondsFromGMTForDate:gmtNow];
    NSDate* pstNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:gmtNow];
    
    NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:pstNow];
    if ((int)[components hour]<6) {
        [components setHour:-24];
    }
    NSDate* lastUpdate = [cal dateByAddingComponents:components toDate:gmtNow options:0];
    lastUpdate = [cal dateBySettingHour:6 minute:0 second:0 ofDate:lastUpdate options:0];
    
    return lastUpdate;
}

- (int) lastUpdateDayAtPdfSource
{
    // we assume the pdfs at newseum are updated by 6am PST
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate* gmtNow = [NSDate date];
    NSTimeZone* pstZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSInteger interval = [pstZone secondsFromGMTForDate:gmtNow];
    NSDate* pstNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:gmtNow];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:pstNow];
    return (int)[components day];
}



- (NSString*) rssFeedForSource:(int)i
{
    NSAssert(i>=0 && i<kSourceCount, @"RSS feed url requested for non-existent source.");
    return (NSString*)([self.rssFeeds objectAtIndex:i]);
}



- (UIColor*) colorForSource:(int)i
{
    float red = basicColors[i][0];
    float green = basicColors[i][1];
    float blue = basicColors[i][2];
    return [UIColor colorWithRed:red green:green blue:blue alpha:.5];
}


- (NSDate*) todaysUpdateDate {
    NSDate* today = [[NSDate alloc] init];
    
    // we update at 6AM
    NSDate* todayUpdateTime = [NSDate dateWithTimeInterval: 60*60*6 sinceDate: today];
    
    return todayUpdateTime;
}

- (BOOL) needToUpdateFrom: (NSDate*) lastUpdateDate{
    
    NSDate* today = [[NSDate alloc] init];
    
    // we update at 6AM
    NSDate* todayUpdateTime = [NSDate dateWithTimeInterval: 60*60*6 sinceDate: today];
    
    // if the last update was before today's update time we need to update
    if ([todayUpdateTime timeIntervalSinceDate:lastUpdateDate] >= 0) {
        return YES;
    }
    
    return NO;
}




@end
