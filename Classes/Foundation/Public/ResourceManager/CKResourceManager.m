//
//  CKResourceManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceManager.h"
#import "NSObject+Invocation.h"
#import "CKVersion.h"


NSString* CKResourceManagerFileDidUpdateNotification = @"RMResourceManagerFileDidUpdateNotification";
NSString* CKResourceManagerApplicationBundlePathKey  = @"RMResourceManagerApplicationBundlePathKey";
NSString* CKResourceManagerRelativePathKey           = @"RMResourceManagerRelativePathKey";
NSString* CKResourceManagerMostRecentPathKey         = @"RMResourceManagerMostRecentPathKey";

NSString* CKResourceManagerDidEndUpdatingResourcesNotification = @"RMResourceManagerDidEndUpdatingResourcesNotification";
NSString* CKResourceManagerUpdatedResourcesPathKey             = @"RMResourceManagerUpdatedResourcesPathKey";


@implementation CKResourceManager


+ (NSMutableArray*)bundles{
    static NSMutableArray* CKResourceManagerBundles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKResourceManagerBundles = [[NSMutableArray alloc]init];
        [CKResourceManagerBundles addObject:[NSBundle mainBundle]];
    });
    return CKResourceManagerBundles;
}

+ (void)registerBundle:(NSBundle*)bundle{
    [[self bundles] addObject:bundle];
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]registerBundle:bundle];
    }
}

+ (BOOL)isResourceManagerConnected{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]isResourceManagerConnected];
    }
    return NO;
}

+ (Class)resourceManagerClass{
    static NSInteger kIsResourceManagerFrameworkAvailable = -1;
    static Class kResourceManagerClass = nil;
    if(kIsResourceManagerFrameworkAvailable == -1){
        kResourceManagerClass = NSClassFromString(@"RMResourceManager");
        kIsResourceManagerFrameworkAvailable = (kResourceManagerClass != nil);
    }
    return kResourceManagerClass;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathForResource:name ofType:ext];
    }
    
    for(NSBundle* bundle in [self bundles]){
        NSString* path = [bundle pathForResource:name ofType:ext];
        if(path) return path;
    }
    
    return nil;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSString* path))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathForResource:name ofType:ext observer:observer usingBlock:updateBlock];
    }
    
    
    
    for(NSBundle* bundle in [self bundles]){
        NSString* path = [bundle pathForResource:name ofType:ext];
        if(path) return path;
    }
    
    return nil;
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext];
    }
    
    NSMutableArray* allPaths = [NSMutableArray array];
    for(NSBundle* bundle in [self bundles]){
        NSArray* paths = [bundle pathsForResourcesOfType:ext inDirectory:nil];
        [allPaths addObjectsFromArray:paths];
    }
    
    return allPaths.count > 0 ? allPaths : nil;
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext localization:localizationName];
    }
    
    NSMutableArray* allPaths = [NSMutableArray array];
    
    for(NSBundle* bundle in [self bundles]){
        NSArray* paths = [bundle pathsForResourcesOfType:ext inDirectory:nil forLocalization:localizationName];
        [allPaths addObjectsFromArray:paths];
    }
    
    return allPaths.count > 0 ? allPaths : nil;
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext observer:observer usingBlock:updateBlock];
    }
    
    NSMutableArray* allPaths = [NSMutableArray array];
    for(NSBundle* bundle in [self bundles]){
        NSArray* paths = [bundle pathsForResourcesOfType:ext inDirectory:nil];
        [allPaths addObjectsFromArray:paths];
    }
    
    return allPaths.count > 0 ? allPaths : nil;
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext localization:localizationName observer:observer usingBlock:updateBlock];
    }
    
    NSMutableArray* allPaths = [NSMutableArray array];
    for(NSBundle* bundle in [self bundles]){
        NSArray* paths = [bundle pathsForResourcesOfType:ext inDirectory:nil forLocalization:localizationName];
        [allPaths addObjectsFromArray:paths];
    }
    
    return allPaths.count > 0 ? allPaths : nil;
}

+ (void)addObserverForResourcesWithExtension:(NSString*)ext object:(id)object usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]addObserverForResourcesWithExtension:ext object:object usingBlock:updateBlock];
    }
}

+ (void)addObserverForPath:(NSString*)path object:(id)object usingBlock:(void(^)(id observer, NSString* path))updateBlock{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]addObserverForPath:path object:object usingBlock:updateBlock];
    }
}

+ (void)removeObserver:(id)object{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]removeObserver:object];
    }
}

+ (UIImage*)imageNamed:(NSString*)name{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        if(path) return [UIImage imageWithContentsOfFile:path];
    }
    
    if([CKOSVersion() floatValue] >= 8){
        for(NSBundle* bundle in [self bundles]){
            UIImage* image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
            if(image)
                return image;
        }
    }else{
        UIImage* image = [UIImage imageNamed:name];
        if(!image) { NSLog(@"Could not find image %@. Asset Catalogs in bundles ar not supported on ios version < 8",name); }
        return image;
    }
    
    return nil;
}

+ (UIImage*)imageNamed:(NSString*)name update:(void(^)(UIImage* image))update{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        if(  path ) return [[UIImage class]performSelector:@selector(imageWithContentsOfFile:update:) withObject:path withObject:update];
    }
    
    if([CKOSVersion() floatValue] >= 8){
        for(NSBundle* bundle in [self bundles]){
            UIImage* image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
            if(image)
                return image;
        }
    }else{
        UIImage* image = [UIImage imageNamed:name];
        if(!image) { NSLog(@"Could not find image %@. Asset Catalogs in bundles ar not supported on ios version < 8",name); }
        return image;
    }
    
    return nil;
}

+ (NSString*)pathForImageNamed:(NSString*)name{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        return path;
    }
    
    NSLog(@"You should not use the method [CKResourceManager pathForImageNamed] without the ResourceManager framework linked to your app or it will return nil !!!");
    
    return nil;
}

+ (void)setHudTitle:(NSString*)title{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]setHudTitle:title];
    }
}

@end
