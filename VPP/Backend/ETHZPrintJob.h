//
//  ETHZPrintJob.h
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *ETHZVPPFileChangedNotification = @"ETHZVPPFileChangedNotification";

typedef NS_ENUM(NSInteger, ETHZDuplexType)
{
    ETHZDuplexTypeNone,
    ETHZDuplexTypeLongbind,
    ETHZDuplexTypeShortbind
};

typedef NS_ENUM(NSInteger, ETHZPaperType)
{
    ETHZPaperTypeRecycled = 0,
    ETHZPaperTypeWhite = 1,
    ETHZPaperTypeHeavy = 2,
    ETHZPaperTypeFoil = 3
};

@interface ETHZPrintJob : NSObject<NSCoding>

+ (instancetype)sharedPrintJob;
- (void)writeToDisk;
- (void)postChangeNotification;

@property (nonatomic, readonly) NSURL *defaultFileURL;
@property (nonatomic, readonly) NSString *fileName;
- (void)copyFile:(NSURL *)fileURL;

@property (nonatomic, strong) NSString *room;
@property (nonatomic, strong) NSString *printer;

@property (nonatomic, strong) NSString *nethzName;

@property (nonatomic, strong) NSString *budget;
@property (nonatomic, strong) NSString *code;

@property (nonatomic) NSInteger copies;
@property (nonatomic) BOOL sorted;
@property (nonatomic) BOOL flagpage;

@property (nonatomic) NSInteger firstPage;
@property (nonatomic) NSInteger lastPage;
@property (nonatomic, readonly) NSInteger pageCount;

@property (nonatomic) ETHZDuplexType duplex;
@property (nonatomic) NSInteger pagesPerSheet;
@property (nonatomic) BOOL pagesPerSheet4Landscape;

@property (nonatomic) ETHZPaperType paper;
@property (nonatomic) NSInteger pageSizeA;

- (NSString *)formatString;
- (UIImage *)previewImage;
- (NSURL *)defaultFileURL;


@end
