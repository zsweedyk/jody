//
//  Sources.m
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "SourceManager.h"
#import "constants.h"
#import "UIImage+PDF.h"


@interface SourceManager ()

//@property (strong,nonatomic) NSMutableArray* sources;
@property (strong,nonatomic) NSArray* defaultFrontPages;
@property (strong,nonatomic) NSMutableArray* frontPageImages;
@property (strong,nonatomic) NSMutableArray* frontPageImageUrl;
@property (strong,nonatomic) NSArray* sourceNames;
@property (strong,nonatomic) NSArray* urlEnds;
@property (strong,nonatomic) NSArray* rssFeeds;
@property (strong, nonatomic) NSDate* lastUpdate;

@property int imagesProcessed;
@property int pdfsSought;

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

        self.frontPageImages = [[NSMutableArray alloc] initWithCapacity:kSourceCount];
        
        
        self.defaultFrontPages = @[@"NY_NYT.png",
                                   @"DC_WP.png",
                                   @"UK_TG.png",
                                   @"CA_LAT.png",
                                   @"WSJ.png",
                                   @"PA_PI.png",
                                   @"NY_DN.png",
                                   @"IND_AGE.png",
                                   @"UAE_TN.png"];
        
        self.sourceNames =@[@"New York Times",
                                @"Washington Post",
                                @"Guardian",
                                @"Los Angeles Times",
                                @"Wall Street Journal",
                                @"Philadelphia Inquirer",
                                @"New York Daily News",
                                @"Asian Age",
                                @"National"];
        
        self.urlEnds =@[@"/NY_NYT.pdf",
                        @"/DC_WP.pdf",
                        @"/UK_TG.pdf",
                        @"/CA_LAT.pdf",
                        @"/WSJ.pdf",
                        @"/PA_PI.pdf",
                        @"/NY_DN.pdf",
                        @"/IND_AGE.pdf",
                        @"/UAE_TN.pdf"];
        
        self.rssFeeds =@[@"https://feeds.feedburner.com/nytimes/gTKh",
                             @"https://feeds.feedburner.com/washingtonpost/HBJr",
                             @"https://feeds.feedburner.com/theguardian/bKzI",
                             @"https://feeds.feedburner.com/latimes/Wxwm",
                             @"https://feeds.feedburner.com/wsj/tGpR",
                             @"https://feeds.feedburner.com/philly/oyxv",
                             @"https://feeds.feedburner.com/nydailynews/Fhuw",
                             @"https://feeds.feedburner.com/asianage/Knmy",
                             @"https://feeds.feedburner.com/thenational/uNww"];
        
        for (int i=0;i<kSourceCount; i++) {
            [self.frontPageImages insertObject:[UIImage imageNamed: [self.defaultFrontPages objectAtIndex:i]] atIndex:i];
            [self.frontPageImageUrl insertObject: @"" atIndex:i];
        }
        self.lastUpdate = [NSDate distantPast];
        
    }
    return self;
}

- (void)getSources {
    
    for (int i=0; i<kSourceCount; i++) {
        int updateDay = [self lastUpdateDayAtPdfSource];
        NSString* latestURLString = [self createNewUrlForSource:i andUpdateDay:updateDay];
        if (![latestURLString isEqualToString: self.frontPageImageUrl[i]]) {
            NSLog(@"Getting image for source %d\n",i);
            NSData* pdfData = [NSData dataWithContentsOfURL:[NSURL URLWithString:latestURLString]];
            UIImage *image = (UIImage *) [UIImage originalSizeImageWithPDFData:pdfData];
            if (image) {
                [self.frontPageImages replaceObjectAtIndex:i withObject: image];
                self.frontPageImageUrl[i] = latestURLString;
            }
        }
    }
}

- (BOOL)sourcesUpToDate
{
    // sources are up to date if they have been updated since the source was last update
    NSDate* lastSourceUpdate = [self lastUpdateDateAtPdfSource];
    NSTimeInterval timeInterval = [self.lastUpdate timeIntervalSinceDate: lastSourceUpdate];
    return timeInterval>=0;
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


- (NSString*) createNewUrlForSource: (int) i andUpdateDay: (int) day
{
    NSAssert(i>=0 && i<kSourceCount, @"URL requested for non-existent source.");
    NSString* urlStart =@"http://webmedia.newseum.org/newseum-multimedia/dfp/pdf";
    NSString* url = [NSString stringWithFormat:@"%@%d%@",urlStart,day,self.urlEnds[i]];
    return url;
}


- (NSData*) pdfDataFromUrl: (NSString*)pathUrl
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pathUrl]];
    return data;
}


- (NSString*) rssFeedForSource:(int)i
{
    NSAssert(i>=0 && i<kSourceCount, @"RSS feed url requested for non-existent source.");
    return (NSString*)([self.rssFeeds objectAtIndex:i]);
}

- (NSString*) urlForSource:(int)i {
    NSAssert(i>=0 && i<kSourceCount, @"Front page requested for non-existent source.");
    return (NSString*)[self.frontPageImageUrl objectAtIndex:i];
 
}


- (UIImage*) frontPageImageForSource: (int) i
{
    NSAssert(i>=0 && i<kSourceCount, @"Image requested for non-existent source.");
    return [self.frontPageImages objectAtIndex: i];
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
