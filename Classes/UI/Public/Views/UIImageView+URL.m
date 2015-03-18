//
//  UIImageView+URL.m
//  MightyCast-iOS.sample
//
//  Created by Sebastien Morel on 4/2/2014.
//  Copyright (c) 2014 MightyCast, Inc. All rights reserved.
//

#import "UIImageView+URL.h"
#import <AppCoreKit/AppCoreKit.h>
#import <objc/runtime.h>

static char* UIImageViewImageLoaderKey;
static char* UIImageViewImageLoaderCompletionBlockKey;

@implementation UIImageView (URL)

- (CKImageLoader*)imageLoader
{
    CKImageLoader* l = objc_getAssociatedObject(self, &UIImageViewImageLoaderKey);
    if(!l){
        l = [[CKImageLoader alloc]initWithDelegate:self];
        objc_setAssociatedObject(self, &UIImageViewImageLoaderKey, l, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return l;
}

- (void)setImageLoaderCompletionBlock:(void(^)(UIImage* image,NSError* error))completion{
    objc_setAssociatedObject(self, &UIImageViewImageLoaderCompletionBlockKey, [completion copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UIImage* image,NSError* error))imageLoaderCompletionBlock
{
    return objc_getAssociatedObject(self, &UIImageViewImageLoaderCompletionBlockKey);
}

- (void)loadImageWithUrl:(NSURL*)url completion:(void(^)(UIImage* image,NSError* error))completion
{
    [self cancelNetworkOperations];
    [self setImageLoaderCompletionBlock:completion];
    [[self imageLoader]loadImageWithContentOfURL:url];
}

- (void)cancelNetworkOperations
{

    [[self imageLoader]cancel];
}

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached
{

    self.image = image;
    
    void(^completionBlock)(UIImage* image,NSError* error) = [self imageLoaderCompletionBlock];
    if(!completionBlock)
        return;
    
    completionBlock(image,nil);
}

- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error
{

    void(^completionBlock)(UIImage* image,NSError* error) = [self imageLoaderCompletionBlock];
    if(!completionBlock)
        return;
    
    completionBlock(nil,error);
}

@end