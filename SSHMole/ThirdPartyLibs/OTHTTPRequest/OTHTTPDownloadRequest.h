//
//  OTHTTPDownloadRequest.h
//  DownloadTest
//
//  Created by openthread on 12/17/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTHTTPDownloadRequest;

@protocol OTHTTPDownloadRequestDelegate <NSObject>

@required

/*
 Download finished
 */
- (void)downloadRequestFinished:(OTHTTPDownloadRequest *)request;

/*
 Download failed
 */
- (void)downloadRequestFailed:(OTHTTPDownloadRequest *)request error:(NSError *)error;

/*
 Write file failed, due to disk full or other reason. With a system exception callback.
 You should IMPLEMENT AT LEAST ONE method in `downloadRequestWriteFileFailed:` and `downloadRequestWriteFileFailed:exception:`.
 */
- (void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request exception:(NSException *)exception;

@optional

/*
 Write file failed, due to disk full or other reason.
 You should IMPLEMENT AT LEAST ONE method in `downloadRequestWriteFileFailed:` and `downloadRequestWriteFileFailed:exception:`.
 */
- (void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request NS_DEPRECATED(10_0, 10_0, 2_0, 2_0, "Use downloadRequestWriteFileFailed:exception: instead");;

/*
 Response received. If block thread in this method, data transfer will be block too.
 You can cancel download request if receivced a unexpected response in this method.
 */
- (void)downloadRequestReceivedResponse:(OTHTTPDownloadRequest *)request;

/*
 Downloaded data callback
 */
- (void)downloadRequest:(OTHTTPDownloadRequest *)request
 currentProgressUpdated:(float)progress
                  speed:(float)bytesPerSecond
               received:(NSUInteger)received
          totalReceived:(long long)totalReceived
       expectedDataSize:(long long)expectedDataSize;

@end

@interface OTHTTPDownloadRequest : NSObject

//Create download request with `urlString`, `cacheFileFullPath` and `finishedFileFullPath`
//Default timeout interval is 15 seconds
+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;

//Create download request with `urlString`, `cacheFileFullPath`, `finishedFileFullPath` and `timeoutInterval`
+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;

@property (nonatomic, weak) id<OTHTTPDownloadRequestDelegate> delegate;
@property (nonatomic, strong) id userInfo;

//Check response Status Code. If haven't receive response yet, return NSNotFound
@property (nonatomic,readonly) NSUInteger responseStatusCode;

//Check response MIME type. If haven't receive response yet, return nil
@property (nonatomic,readonly) NSString *responseMIMEType;

//Cache file path
@property (nonatomic,readonly) NSString *cacheFilePath;

//Finished file path
@property (nonatomic,readonly) NSString *finishedFilePath;

//Request URL
@property (nonatomic,readonly) NSString *requestURL;

//Check if download
@property (nonatomic,readonly) BOOL isDownloading;

//Interval for each progress callback `downloadRequest:currentProgressUpdated:speed:received:totalReceived:expectedDataSize:`, default is 0.2.
@property (nonatomic,assign) NSTimeInterval downloadProgressCallbackInterval;

//Average download speed
@property (nonatomic,readonly) double averageDownloadSpeed;

//Check downloaded file size
@property (nonatomic,readonly) long long downloadedFileSize;

//Check expected file size
@property (nonatomic,readonly) long long expectedFileSize;

//Set if this is a low priority request. Set this property before call `start` to take effect.
//Default value is `YES`.
//When set to `NO`, download will be started at default priority.
@property (nonatomic,assign) BOOL isLowPriority;

//Current retried times after download failed.
//If request not started or paused, call `start` will reset this property.
@property (nonatomic, readonly) NSUInteger currentRetriedTimes;

//Retry times for download failed due to response errors or network failed reasons.
//Default is 1.
@property (nonatomic,assign) NSUInteger retryTimes;

//If download failed, and current retried times < `retryTimes`, then retry after `retryAfterFailedDuration`
//Default is 0.5 second.
@property (nonatomic,assign) NSTimeInterval retryAfterFailedDuration;

//pause download
- (void)pause;

//begin or resume download
- (void)start;

//set cookie. If you need to set cookie, you must do this before call start.
//Each object in `cookie` is an `NSHTTPCookie`
- (void)setCookies:(NSArray *)cookies;

/*!
 @method addValue:forHTTPHeaderField:
 @abstract Adds an HTTP header field in the current header
 dictionary.
 @discussion This method provides a way to add values to header
 fields incrementally. If a value was previously set for the given
 header field, the given value is appended to the previously-existing
 value. The appropriate field delimiter, a comma in the case of HTTP,
 is added by the implementation, and should not be added to the given
 value by the caller. Note that, in keeping with the HTTP RFC, HTTP
 header field names are case-insensitive.
 @param value the header field value.
 @param field the header field name (case-insensitive).
 */
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
