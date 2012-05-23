//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

OBJC_EXPORT NSString * const CKWebRequestHTTPErrorDomain;

@interface CKWebRequest : NSObject

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, copy) void (^completionBlock)(id response, NSHTTPURLResponse *urlResponse, NSError *error);
@property (nonatomic, copy) id (^transformBlock)(id value);

@property (nonatomic, assign) id<NSURLConnectionDelegate, NSURLConnectionDataDelegate> delegate;//Forward URL connection if nessesary
@property (nonatomic, retain, readonly) NSString *downloadPath;
@property (nonatomic, readonly) CGFloat progress;

+(NSCachedURLResponse *)cachedResponseForURL:(NSURL *)anURL;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;
- (id)initWithURL:(NSURL*)url completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURL:(NSURL*)url transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

- (void)start; //Start on the currentRunLoop. Recommended to schedule with CKWebRequestManager
- (void)startOnRunLoop:(NSRunLoop*)runLoop;
- (void)cancel;

@end
