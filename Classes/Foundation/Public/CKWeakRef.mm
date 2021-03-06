//
//  CKWeakRef.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWeakRef.h"
#import "NSObject+Invocation.h"
#import <objc/runtime.h>

#include <ext/hash_set>

using namespace std;
using namespace __gnu_cxx;

namespace __gnu_cxx{
template<> struct hash< CKWeakRef* >
{
    size_t operator()( CKWeakRef* x ) const{
        return (size_t)x;
    }
};
}


typedef hash_set<CKWeakRef*> CKWeakRefSet;

static char NSObjectWeakRefObjectKey;

//CKWeakRefAssociatedObject

@interface CKWeakRefAssociatedObject : NSObject{
    CKWeakRefSet _weakRefSet;
}
- (void)registerWeakRef:(CKWeakRef*)ref;
- (void)unregisterWeakRef:(CKWeakRef*)ref;
- (void)flushUsingObject:(id)object;
@end

//CKWeakRef PRIVATE

@interface CKWeakRef ()
@property(nonatomic,retain)CKCallback* callback;
@end


//CKWeakRefAssociatedObject

@implementation CKWeakRefAssociatedObject

- (void)dealloc{
	_weakRefSet.clear();
	[super dealloc];
}

- (void)registerWeakRef:(CKWeakRef*)ref{
	_weakRefSet.insert(ref);
}

- (void)unregisterWeakRef:(CKWeakRef*)ref{
	_weakRefSet.erase(ref);
}

- (void)flushUsingObject:(id)object{
    while(_weakRefSet.begin() !=  _weakRefSet.end()){
        CKWeakRef* ref = [*_weakRefSet.begin() retain];
        if(ref.callback){
            [ref.callback execute:ref];
        }
        
        //In case it has been unregistered in callback
        if(_weakRefSet.find(ref) != _weakRefSet.end()){
            ref.object = nil;//this will call unregister ...
            [ref release];
        }
    }
    _weakRefSet.clear();
}

@end


//NSObject (CKWeakRefAdditions)


@interface NSObject (CKWeakRefAdditions)
@property (nonatomic,retain)CKWeakRefAssociatedObject* weakRefObject;
@end


@implementation NSObject (CKWeakRefAdditions)

- (void)setWeakRefObject:(CKWeakRefAssociatedObject *)object {
    objc_setAssociatedObject(self, 
                             &NSObjectWeakRefObjectKey,
                             object,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKWeakRefAssociatedObject *)weakRefObject {
    return objc_getAssociatedObject(self, &NSObjectWeakRefObjectKey);
}

- (void) weakRef_dealloc {
	CKWeakRefAssociatedObject* weakRefObj = [self weakRefObject];
	if(weakRefObj){
        [weakRefObj flushUsingObject:self];
		objc_setAssociatedObject(self, 
								 &NSObjectWeakRefObjectKey,
								 nil,
								 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[self weakRef_dealloc];
}

@end

//CKWeakRef

@interface CKWeakRef ()
- (void)registerToObject:(id)object;
- (void)unregisterToObject:(id)object;
@end

static BOOL swizzlingDone = NO;

@implementation CKWeakRef{
	id _object;
	CKCallback* _callback;
}


@synthesize object = _object;
@synthesize callback = _callback;

+ (void)executeSwizzling{
    if(!swizzlingDone){
        Method origMethod = class_getInstanceMethod([NSObject class], @selector(dealloc));
        Method newMethod = class_getInstanceMethod([NSObject class], @selector(weakRef_dealloc));
        if (class_addMethod([NSObject class], @selector(dealloc), method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod([NSObject class], @selector(weakRef_dealloc), method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        }
        else {
            method_exchangeImplementations(origMethod, newMethod);
        }
        swizzlingDone = YES;
    }
}

+ (void)load{
	[self executeSwizzling];
}

- (void)dealloc{
    [self unregisterToObject:_object];
	
	_object = nil;
	[_callback release];
	_callback = nil;
	[super dealloc];
}

- (id)initWithObject:(id)theObject{
    [[self class] executeSwizzling];
    if (self = [self init]) {
        self.object = theObject;
    }
    return self;
}

- (id)initWithObject:(id)theObject callback:(CKCallback*)callback{
	[[self class] executeSwizzling];
	if (self = [super init]) {
        self.object = theObject;
        self.callback = callback;
    }
	return self;
}

- (id)initWithObject:(id)object block:(void (^)(CKWeakRef* weakRef))block{
    self = [self initWithObject:object callback:[CKCallback callbackWithBlock:^(id callbackObject){
		block((CKWeakRef*)callbackObject);
		return (id)nil;
	}]];
	return self;
}

- (id)initWithObject:(id)object target:(id)target action:(SEL)action{
	self = [self initWithObject:object callback:[CKCallback callbackWithTarget:target action:action]];
	return self;
}


- (void)registerToObject:(id)theobject{
    if(theobject){
        CKWeakRefAssociatedObject* targetWeakRefObject = [theobject weakRefObject];
        if(targetWeakRefObject == nil){
            targetWeakRefObject = [[[CKWeakRefAssociatedObject alloc]init]autorelease];
            [theobject setWeakRefObject:targetWeakRefObject];
        }
        [targetWeakRefObject registerWeakRef:self];
    }
}

- (void)unregisterToObject:(id)theobject{
    if(theobject){
		CKWeakRefAssociatedObject* targetWeakRefObject = [theobject weakRefObject];
		if(targetWeakRefObject){
			[targetWeakRefObject unregisterWeakRef:self];
		}
	}
}

- (void)setObject:(id)theobject{
    if(_object == theobject)
        return;
    
    if(_object){
        [self unregisterToObject:_object];
    }
    _object = theobject;
    if(_object){
        [self registerToObject:_object];
    }
}

+ (CKWeakRef*)weakRefWithObject:(id)object{
	return [[[CKWeakRef alloc]initWithObject:object]autorelease];
}

+ (CKWeakRef*)weakRefWithObject:(id)object callback:(CKCallback*)callback{
	return [[[CKWeakRef alloc]initWithObject:object callback:callback]autorelease];
}

+ (CKWeakRef*)weakRefWithObject:(id)object block:(void (^)(CKWeakRef* weakRef))block{
	return [[[CKWeakRef alloc]initWithObject:object block:block]autorelease];
}

+ (CKWeakRef*)weakRefWithObject:(id)object target:(id)target action:(SEL)action{
	return [[[CKWeakRef alloc]initWithObject:object target:target action:action]autorelease];
}

- (id)copyWithZone:(NSZone *)zone{
    return [[CKWeakRef allocWithZone:zone]initWithObject:self.object callback:self.callback];
}

- (NSUInteger)hash {
	return [self.object hash] + [self.callback hash];
}

- (BOOL)isEqual:(id)object{
    if(![object isKindOfClass:[CKWeakRef class]])
        return NO;
    
    CKWeakRef* other = (CKWeakRef*)object;
    
    BOOL bo = (other.object == self.object) && (other.callback == self.callback);
    return bo;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@<%p> : { object : %@<%p> }",[self class],self,[self.object class],self.object];
}

@end
