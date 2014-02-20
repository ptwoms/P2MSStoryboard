//
//  AdditionalFunctions.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 17/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdditionalFunctions : NSObject

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (UIImage *)imageFromPath:(NSString *)path;

@end
