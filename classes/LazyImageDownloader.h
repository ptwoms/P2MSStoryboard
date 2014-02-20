//
//  LazyImageDownloader.h
//  P2MSLib
//
//  Created by Pyae Phyo Myint Soe on 3/7/12.
//  Copyright (c) 2012 P2MS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LazyImageDownloader;

@protocol LazyImageDownloaderDelegate
- (void) imageDidLoad:(id) returnPath withImage:(UIImage *) image;
- (void) imageDidFail:(LazyImageDownloader *) imageDownloader forURLString:(NSString *)url;
@end


@interface LazyImageDownloader : NSObject{
    NSURLConnection *imgCon;
    NSMutableData *activeDownload;
}

@property (unsafe_unretained, nonatomic) id<LazyImageDownloaderDelegate> delegate;
@property (nonatomic, retain) id returnPath;
@property (nonatomic, retain) NSString *cacheName;
@property (nonatomic) NSInteger retryCount;

- (void) startDownload:(NSString *) urlString;
- (void) startURLDownload:(NSURL *) url;
- (void) cancelDownload;

@end
