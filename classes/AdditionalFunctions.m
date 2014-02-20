//
//  AdditionalFunctions.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 17/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "AdditionalFunctions.h"
#import <sys/xattr.h>
#import "NSString+MD5.h"

@implementation AdditionalFunctions

//https://developer.apple.com/library/ios/qa/qa1719/_index.html#//apple_ref/doc/uid/DTS40011342
//http://stackoverflow.com/questions/9620651/use-nsurlisexcludedfrombackupkey-without-crashing-on-ios-5-0
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    if (&NSURLIsExcludedFromBackupKey == nil) {
        // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else {
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                NSLog(@"Removed extended attribute on file %@", URL);
            }
        }
        // Set the new key
        return [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

+ (UIImage *)imageFromPath:(NSString *)path{
    NSString *fileName = [path lastPathComponent];
    if (fileName.length == path.length) {
        return [UIImage imageNamed:fileName];
    }else if ([path rangeOfString:@"://"].length > 0){
        NSString *baseFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Pictures"];
        return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/img_%@_%@", baseFilePath, [path MD5String], fileName]];
    }else{
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
        return [UIImage imageWithContentsOfFile:filePath];
    }
}

@end
