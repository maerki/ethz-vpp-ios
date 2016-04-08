//
//  ETHPrintManager.h
//  Campus
//
//  Created by Nicolas Märki on 21.12.13.
//  Copyright (c) 2013 Nicolas Märki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ETHZPrintJob.h"

@interface ETHPrintManager : NSObject


+ (instancetype)sharedManager;


- (void)printJob:(ETHZPrintJob *)job withProgress:(void (^)(float progress))progressBlock completion:(void (^)(NSError *error))completionBlock;


@end
