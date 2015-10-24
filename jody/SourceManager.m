//
//  Sources.m
//  jody
//
//  Created by Z Sweedyk on 8/10/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//


#import "SourceManager.h"
#import "constants.h"


enum {
    NYTIMES=0,
    WASHINGTONPOST=1,
    GUARDIAN=2,
    LATIMES=3,
    WALLSTREETJOURNAL=4,
    NYPOST=5,
    NYDAILYNEWS=6,
    INDIANAGE=7,
    NATIONAL=8
};



@interface SourceManager ()

@property (strong,nonatomic) NSMutableArray* sources;
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
        self.sources = [[NSMutableArray alloc] initWithCapacity:kSourceCount];
        self.frontPageImages = [[NSMutableArray alloc] initWithCapacity:kSourceCount];
        
        self.sourceNames =@[@"N.Y. Times",
                                @"Washington Post",
                                @"Guardian",
                                @"L.A. Times",
                                @"Wall Street Journal",
                                @"Philadelphia Inquirer",
                                @"N.Y. Daily News",
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
        
        // we use dummy images initially so we can insert images at the appropriate index
        UIImage* dummy = [UIImage imageNamed:@"colorWheelSmall@2x.png"];
        for (int i=0;i<kSourceCount; i++) {
            [self.frontPageImages insertObject:dummy atIndex:i];
        }
        self.lastUpdate = [NSDate distantPast];
        
    }
    return self;
}

- (void)getSources {
    
    PFQuery *query = [PFQuery queryWithClassName:@"NWSource"];
    [query orderByDescending:@"createdAt"];
    self.imagesProcessed=0;
    self.pdfsSought=0;
    [query findObjectsInBackgroundWithBlock:^(NSArray* sources, NSError *error) {
        if (sources) {
            if ([sources count]==kSourceCount) {
                int updateDay = [self lastUpdateDayAtPdfSource];
                for (int i=0; i<kSourceCount; i++) {
                    NWSource* source = [sources objectAtIndex:i];
                    [self.sources insertObject:source atIndex:i];
                    
                    // check if the parse data is consistent with our class data (this allows us to change parse data by simply changing our constants in this class
                    int parseSourceNum = source.sourceNum;
                    if (![source.sourceName isEqualToString:self.sourceNames[parseSourceNum]] ||
                        ![source.rssFeed isEqualToString: self.rssFeeds[parseSourceNum]]) {
                        source.sourceName = self.sourceNames[parseSourceNum];
                        source.rssFeed = self.rssFeeds[parseSourceNum];
                        [source saveInBackground];
                    }
                    NSString* latestURL = [self createNewUrlForSource:parseSourceNum andUpdateDay:updateDay];
                    if (![latestURL isEqualToString:source.frontPageUrl]){
                        // we get the latest pdf -- we don't use it here but it will be available for other users
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [self savePdfForSource: source fromUrl:latestURL];
                        });
                        
                    }
                    
                    __block int sourceNum=i;
                    self.pdfsSought++;
                    [source.frontPagePdf getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!error) {
                                UIImage* newImage = [self imageFromPdf:data];
                                if (newImage) {
                                    [self.frontPageImages replaceObjectAtIndex: sourceNum withObject: newImage];
                                }
                                self.imagesProcessed++;
                                if (self.imagesProcessed==kSourceCount) {
                                    self.lastUpdate = [NSDate date];
                                    [self.delegate frontPagesCreated];
                                }}
                            
                            else {
                                self.imagesProcessed++;
                                NSLog(@"Couldn't retrieve front page pdf file.");
                                if (self.imagesProcessed==kSourceCount) {
                                    [self.delegate frontPagesCreated];
                                }
                            }
                        });
                    }];
                }
            }
        }
        else {
            NSLog(@"Unable to retrieve sources");
            [self initializeSourcesWithUpdate: NO];
        }
        
    }];
}


- (void) initializeSourcesWithUpdate: (BOOL)update {
    
    // we can recreate what is in parse -- it is just very slow
    
    int sourceCount = (int)[self.sourceNames count];
    NSAssert (sourceCount == [self.urlEnds count] && sourceCount==[self.rssFeeds count], @"Source names, urls, and rss feeds don't have same size.\n");
    
    self.sources = [[NSMutableArray alloc] initWithCapacity:sourceCount];
    
    int day = [self lastUpdateDayAtPdfSource];
    for (int i=0; i<sourceCount; i++) {
        
        NWSource* source = [[NWSource alloc] init];
        source.sourceNum = i;
        source.sourceName = [self.sourceNames objectAtIndex:i];
        source.rssFeed = [self.rssFeeds objectAtIndex:i];
        source.frontPageUrl = [self createNewUrlForSource:i andUpdateDay:day];
        NSData* pdfPageData = [self pdfDataFromUrl:source.frontPageUrl];
        source.frontPagePdf = [PFFile fileWithData:pdfPageData];
        UIImage* pdfImage = [self imageFromPdf:pdfPageData];
        [self.frontPageImages insertObject:pdfImage atIndex:i];
        [self.sources insertObject:source atIndex:i];
        
        // this is useful for initially creating the parse db
        // doing it with an existing db will cause duplication of records -- which is problematicc
        //        if (update) {
        //            // save pffiles then the object
        //            [source.frontPagePdf saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //                if (succeeded) {
        //                    [source saveInBackground];
        //                }
        //                else {
        //                    NSLog(@"Error saving PDF.");
        //                }
        //
        //            }];
        //        }
        //        else {
        //            [self.delegate frontPagesCreated];
        //        }
        
    }
    self.lastUpdate = [NSDate date];
    [self.delegate frontPagesCreated];
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


- (void) savePdfForSource: (NWSource*) source fromUrl: (NSString*) url
{
    source.frontPageUrl = url;
    NSData* pdfPageData = [self pdfDataFromUrl:source.frontPageUrl];
    if (pdfPageData) {
        source.frontPagePdf = [PFFile fileWithData:pdfPageData];
        
        // save pffiles then the object
        [source.frontPagePdf saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [source saveInBackground];
            }
        }];
    }
}

- (NSData*) pdfDataFromUrl: (NSString*)pathUrl
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pathUrl]];
    return data;
}

- (UIImage*) imageFromPdf: (NSData*) pdf
{
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)pdf);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(provider);
    CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
    UIGraphicsBeginImageContext(CGSizeMake(kPDFWidth,kPDFHeight)); // A4 size for pdf
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextDrawPDFPage (currentContext, page);  // draws the page in the graphics contex
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSString*) rssFeedForSource:(int)i
{
    NSAssert(i>=0 && i<[self.sources count], @"RSS feed url requested for non-existent source.");
    return ((NWSource*)[self.sources objectAtIndex:i]).rssFeed;
}

- (NSString*) urlForSource:(int)i {
    NSAssert(i>=0 && i<[self.sources count], @"Front page requested for non-existent source.");
    NWSource* source = (NWSource*)[self.sources objectAtIndex:i];
    return source.frontPageUrl;
}

- (NSDate*) updateDateForSource:(int)i
{
    NSAssert(i>=0 && i<[self.sources count], @"Update date requested for non-existent source.");
    NWSource* source = (NWSource*)[self.sources objectAtIndex:i];
    return source.updatedAt;
}

- (UIImage*) frontPageImageForSource: (int) i
{
    NSAssert(i>=0 && i<kSourceCount, @"Image requested for non-existent source.");
    return [self.frontPageImages objectAtIndex: i];
}

- (UIColor*) colorForSource:(int)i
{
    NSAssert(i>=0 && i<kSourceCount, @"Image requested for non-existent source.");
    NWSource* source = (NWSource*)[self.sources objectAtIndex:i];
    int sourceNum = source.sourceNum;
    float red = basicColors[sourceNum][0];
    float green = basicColors[sourceNum][1];
    float blue = basicColors[sourceNum][2];
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
