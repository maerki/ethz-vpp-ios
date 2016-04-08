//
//  ETHZPrintJob.m
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHZPrintJob.h"

@interface ETHZPrintJob ()

@property (nonatomic, readwrite) NSInteger pageCount;

@end

@implementation ETHZPrintJob

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:self.fileName forKey:@"fileName"];

    [aCoder encodeObject:self.room forKey:@"room"];
    [aCoder encodeObject:self.printer forKey:@"printer"];

    [aCoder encodeObject:self.nethzName forKey:@"nethzName"];

    [aCoder encodeObject:self.budget forKey:@"budget"];
    [aCoder encodeObject:self.code forKey:@"code"];

    [aCoder encodeInteger:self.copies forKey:@"copies"];
    [aCoder encodeBool:self.sorted forKey:@"sorted"];
    [aCoder encodeBool:self.flagpage forKey:@"flagpage"];

    [aCoder encodeInteger:self.firstPage forKey:@"firstPage"];
    [aCoder encodeInteger:self.lastPage forKey:@"lastPage"];
    [aCoder encodeInteger:self.pageCount forKey:@"pageCount"];

    [aCoder encodeInteger:self.duplex forKey:@"duplex"];
    [aCoder encodeInteger:self.pagesPerSheet forKey:@"pagesPerSheet"];

    [aCoder encodeInteger:self.paper forKey:@"paper"];
    [aCoder encodeInteger:self.pageSizeA forKey:@"pageSizeA"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    _fileName = [aDecoder decodeObjectForKey:@"fileName"];

    _room = [aDecoder decodeObjectForKey:@"room"];
    _printer = [aDecoder decodeObjectForKey:@"printer"];

    _nethzName = [aDecoder decodeObjectForKey:@"nethzName"];

    _budget = [aDecoder decodeObjectForKey:@"budget"];
    _code = [aDecoder decodeObjectForKey:@"code"];

    _copies = [aDecoder decodeIntegerForKey:@"copies"];
    _sorted = [aDecoder decodeBoolForKey:@"sorted"];
    _flagpage = [aDecoder decodeBoolForKey:@"flagpage"];

    _firstPage = [aDecoder decodeIntegerForKey:@"firstPage"];
    _lastPage = [aDecoder decodeIntegerForKey:@"lastPage"];
    _pageCount = [aDecoder decodeIntegerForKey:@"pageCount"];

    _duplex = [aDecoder decodeIntegerForKey:@"duplex"];
    _pagesPerSheet = [aDecoder decodeIntegerForKey:@"pagesPerSheet"];

    _paper = [aDecoder decodeIntegerForKey:@"paper"];
    _pageSizeA = [aDecoder decodeIntegerForKey:@"pageSizeA"];

    return self;
}

+ (NSString *)sharedPrintJobURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"printjob"];
}

+ (instancetype)sharedPrintJob
{

    static ETHZPrintJob *job;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                              {
        job = [NSKeyedUnarchiver unarchiveObjectWithFile:[self sharedPrintJobURL]];
        
        #ifdef DEBUG
        //job = nil;
        #endif

        if(!job)
        {
            job = [ETHZPrintJob new];
            job.room = @"CABSTUD";
            job.printer = @"";
            job.copies = 1;
            job.flagpage = YES;
            job.duplex = ETHZDuplexTypeLongbind;
            job.pagesPerSheet = 1;
            job.pageSizeA = 4;
            job.pageCount = 1;
            job.paper = ETHZPaperTypeRecycled;
            [job writeToDisk];
        }
    });

    return job;
}

- (NSString *)formatString {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"A%ld",(long)self.pageSizeA]];
    
    switch (self.paper) {
        case ETHZPaperTypeRecycled:
            break;
            
        case ETHZPaperTypeFoil:
            [array addObject:@"FOIL"];
            break;
            
        case ETHZPaperTypeHeavy:
            [array addObject:@"HEAVY"];
            break;
            
        case ETHZPaperTypeWhite:
            [array addObject:@"WHITE"];
            break;
            
    }
    
    switch (self.duplex) {
        case ETHZDuplexTypeNone:
            break;
            
        case ETHZDuplexTypeLongbind:
            [array addObject:@"LONGBIND"];
            break;
            
        case ETHZDuplexTypeShortbind:
            [array addObject:@"SHORTBIND"];
            break;
            
    }
    
    return [array componentsJoinedByString:@"."];
    
}

- (void)writeToDisk
{
    BOOL suc = [NSKeyedArchiver archiveRootObject:self toFile:[[self class] sharedPrintJobURL]];
    if(!suc)
    {
        NSLog(@"Error, couldn't write job to disk");
    }
}

- (NSURL *)defaultFileURL {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:@"document.pdf"];
    
    return [NSURL fileURLWithPath:file isDirectory:NO];
    
}

- (void)copyFile:(NSURL *)fileURL
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[self defaultFileURL] error:nil];
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[self defaultFileURL] error:&error];
    
      _fileName = fileURL.lastPathComponent;
    
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
    
    if (!document) {
        [[[UIAlertView alloc] initWithTitle:@"Fehler" message:@"PDF konnte nicht gelesen werden. Keine Ahnung, was jetzt passiert." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        _pageCount = MAX(1, CGPDFDocumentGetNumberOfPages(document));
        _firstPage = 1;
        _lastPage = _pageCount;
    }
    
    [self writeToDisk];
    [self postChangeNotification];

    
}


- (void)postChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ETHZVPPFileChangedNotification object:nil];
}

- (UIImage *)previewImage {
    
    const float width = 200;
    
    // Get the page
    CGPDFPageRef myPageRef = CGPDFDocumentGetPage(CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.defaultFileURL), 1);
    
    if (myPageRef) {
        CGRect pageRect = CGPDFPageGetBoxRect(myPageRef, kCGPDFMediaBox);
        CGFloat pdfScale = width/pageRect.size.width;
        pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
        pageRect.origin = CGPointZero;
        
        
        UIGraphicsBeginImageContext(pageRect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // White BG
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        CGContextFillRect(context,pageRect);
        
        CGContextSaveGState(context);
        
        
        CGContextTranslateCTM(context, 0.0, pageRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFMediaBox, pageRect, 0, true));
        
        CGContextDrawPDFPage(context, myPageRef);
        CGContextRestoreGState(context);
        
        UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        return thm;
        
    }
    
    return nil;
    
}


@end
