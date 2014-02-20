//
//  LazyImageDownloader.m
//  P2MSLib
//
//  Created by Pyae Phyo Myint Soe on 3/7/12.
//  Copyright (c) 2012 P2MS. All rights reserved.
//

#import "LazyImageDownloader.h"
#import "AdditionalFunctions.h"

@implementation LazyImageDownloader

- (void) startDownload:(NSString *) urlString{
    activeDownload = [NSMutableData data];
    NSURLConnection *con = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] delegate:self];
    imgCon = con;
}

- (void) startURLDownload:(NSURL *) url{
    activeDownload = [NSMutableData data];
    NSURLConnection *con = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    imgCon = con;
}

- (void) cancelDownload{
    [imgCon cancel];
    imgCon = nil;
}

#pragma mark (NSURLConnectionDelegate)
- (void)connection: (NSURLConnection *)connection didReceiveData:(NSData *)data{
    [activeDownload appendData:data];
}

- (void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Connection failed %@", [error description]);
    activeDownload = nil;
    imgCon = nil;
    if (self.retryCount) {
        self.retryCount--;
        //retry to download after 1 second
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startURLDownload:[[connection originalRequest]URL]];
        });
    }else{
        NSDictionary *dict = [error userInfo];
        [self.delegate imageDidFail:self forURLString:[dict objectForKey:NSURLErrorFailingURLErrorKey]];
    }
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection{
    UIImage *downloadedImage = [[UIImage alloc]initWithData:activeDownload];
    activeDownload = nil;
    if (_cacheName) {
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Pictures"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_cacheName];
        [UIImagePNGRepresentation(downloadedImage) writeToFile:filePath atomically:YES];
        [AdditionalFunctions addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
    }
    [self.delegate imageDidLoad:_returnPath withImage:downloadedImage];
    imgCon = nil;

}

@end
