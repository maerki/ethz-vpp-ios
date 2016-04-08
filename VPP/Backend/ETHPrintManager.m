//
//  ETHPrintManager.m
//  Campus
//
//  Created by Nicolas Märki on 21.12.13.
//  Copyright (c) 2013 Nicolas Märki. All rights reserved.
//

#import "ETHPrintManager.h"

#import "AFHTTPRequestOperationManager.h"

@implementation ETHPrintManager

static ETHPrintManager *sharedManager;


+ (instancetype)sharedManager {
    if (!sharedManager) {
        if (!sharedManager) {
            sharedManager = [ETHPrintManager new];
        }
    }
    
    return sharedManager;
}





- (void)printJob:(ETHZPrintJob *)job withProgress:(void (^)(float progress))progressBlock completion:(void (^)(NSError *error))completionBlock {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = job.nethzName;
    parameters[@"destination"] = job.room;
    
   
    parameters[@"device"] = job.printer;
    
    
    parameters[@"form"] = job.formatString;
    
    parameters[@"copies"] = @(job.copies);
    if (job.sorted) {
        parameters[@"sortcopies"] = @"1";
    }
    
    if (job.firstPage > 1 || job.lastPage < job.pageCount) {
        parameters[@"startpage"] = @(job.firstPage);
        parameters[@"endpage"] = @(job.lastPage);
    }
    
    if (!job.flagpage) {
        parameters[@"noflag"] = @"noflag";
    }
    
    if (job.pagesPerSheet == 2) {
        parameters[@"nup"] = @"2";
    }
    else if (job.pagesPerSheet == 4) {
        if (job.pagesPerSheet4Landscape) {
            parameters[@"nup"] = @"4l";
        }
        else {
            parameters[@"nup"] = @"4";
        }
    }
    
    
    parameters[@"notify"] = @"";
    parameters[@"note"] = @"Printed with ETHZ Campus App";
    parameters[@"-ip-"] = @"SPP";
    
    
    
    
    AFHTTPRequestOperation *op = [manager POST:@"http://idvpp01.ethz.ch/cgi-bin/vpppdf.cgi" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:job.defaultFileURL name:@"file1" error:nil];
    } success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Success: %@", html);
        if ([html rangeOfString:@"transferred to VPP"].length > 0) {
            completionBlock(nil);
        }
        else {
            completionBlock([NSError errorWithDomain:@"ch.nitschi.campusapp" code:1000 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unerwartete Rückmeldung vom VPP Backend. Der Druckauftrag wird möglicherweise nicht ausgeführt.", nil)}]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(error);
    }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%lld %lld",totalBytesWritten, totalBytesExpectedToWrite);
        progressBlock((float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    }];
    
    [op setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
    }];
}




@end
