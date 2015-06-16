//
//  NSObject+Invocation.m
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSObject+Invocation.h"
#import "CKWeakRef.h"

typedef void(^CKInvokationBlock)();

static NSMutableDictionary* CKInvokationRegistry = nil;

@interface CKInvokationObject : NSObject
@property(nonatomic,copy)CKInvokationBlock block;
@property(nonatomic,retain)CKWeakRef* objectRef;
- (id)initWithObject:(id)object block:(CKInvokationBlock)theblock delay:(NSTimeInterval)delay;
- (void)cancel;
@end

@implementation CKInvokationObject
@synthesize block = _block;
@synthesize objectRef = _objectRef;

- (void)unregister{
    if(_objectRef){
        NSMutableArray* ar = [CKInvokationRegistry objectForKey:[NSValue valueWithNonretainedObject:self.objectRef.object]];
        if(ar){
            [ar removeObject:[NSValue valueWithNonretainedObject:self]];
            if([ar count] <= 0){
                [CKInvokationRegistry removeObjectForKey:[NSValue valueWithNonretainedObject:self.objectRef.object]];
            }
        }
        self.objectRef = nil;
    }
}

- (void)dealloc{
    [self unregister];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
    [_block release];
    [super dealloc];
}

- (id)initWithObject:(id)object block:(CKInvokationBlock)theblock delay:(NSTimeInterval)delay{
    return [self initWithObject:object block:theblock delay:delay modes:nil];
}

- (id)initWithObject:(id)object block:(CKInvokationBlock)theblock delay:(NSTimeInterval)delay modes:(NSArray*)modes{
    self = [super init];
    [self retain];
    self.block = theblock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKInvokationRegistry = [[NSMutableDictionary alloc]init];
    });
    
    NSMutableArray* ar = [CKInvokationRegistry objectForKey:[NSValue valueWithNonretainedObject:object]];
    if(!ar){
        ar = [NSMutableArray array];
        [CKInvokationRegistry setObject:ar forKey:[NSValue valueWithNonretainedObject:object]];
    }
    
    [ar addObject:[NSValue valueWithNonretainedObject:self]];
    
    __block CKInvokationObject* bself = self;
    self.objectRef = [CKWeakRef weakRefWithObject:object block:^(CKWeakRef *weakRef) {
        if(weakRef == bself.objectRef){
            [NSObject cancelPreviousPerformRequestsWithTarget:bself];
            [bself unregister];
            [bself autorelease];
        }
    }];
    
    if(modes){
        [self performSelector:@selector(execute) withObject:nil afterDelay:delay inModes:modes];
    }else{
        [self performSelector:@selector(execute) withObject:nil afterDelay:delay];
    }
    return self;
}


- (id)initWithObject:(id)object block:(CKInvokationBlock)theblock{
    return [self initWithObject:object block:theblock modes:nil];
}


- (id)initWithObject:(id)object block:(CKInvokationBlock)theblock modes:(NSArray*)modes{
    self = [super init];
    [self retain];
    
    self.block = theblock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKInvokationRegistry = [[NSMutableDictionary alloc]init];
    });
    
    NSMutableArray* ar = [CKInvokationRegistry objectForKey:[NSValue valueWithNonretainedObject:object]];
    if(!ar){
        ar = [NSMutableArray array];
        [CKInvokationRegistry setObject:ar forKey:[NSValue valueWithNonretainedObject:object]];
    }
    
    [ar addObject:[NSValue valueWithNonretainedObject:self]];
    
    __block CKInvokationObject* bself = self;
    self.objectRef = [CKWeakRef weakRefWithObject:object block:^(CKWeakRef *weakRef) {
        if(weakRef == bself.objectRef){
            [NSObject cancelPreviousPerformRequestsWithTarget:bself];
            [bself unregister];
            [bself autorelease];
        }
    }];
    
    if(modes){
        [self performSelectorOnMainThread:@selector(execute) withObject:nil waitUntilDone:NO modes:modes];
    }else{
        [self performSelectorOnMainThread:@selector(execute) withObject:nil waitUntilDone:NO];
    }
    return self;

}



- (void)execute{
    [self unregister];
    self.objectRef = nil;
    if(_block){
        _block();
    }
    [self autorelease];
}

- (void)cancel{
    [self unregister];
    self.objectRef = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self autorelease];
}

@end




@implementation NSObject (CKNSObjectInvocation)

- (void)delayedPerformSelector:(NSArray*)args{
	NSValue* selectorValue = [args objectAtIndex:0];
	SEL selector = [selectorValue pointerValue];
	[self performSelector:selector onThread:[NSThread currentThread] withObjects:[args subarrayWithRange:NSMakeRange(1, [args count] - 1 )] waitUntilDone:YES];
}

- (void)performSelector:(SEL)selector withObject:(id)arg withObject:(id)arg2 afterDelay:(NSTimeInterval)delay {
	[self performSelector:@selector(delayedPerformSelector:) withObject:[NSArray arrayWithObjects:[NSValue valueWithPointer:selector],arg, arg2, nil] afterDelay:delay];
}


- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg withObject:(id)arg2 waitUntilDone:(BOOL)wait {
	[self performSelector:selector onThread:[NSThread mainThread] withObjects:[NSArray arrayWithObjects:arg, arg2, nil] waitUntilDone:wait];
}

- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg withObject:(id)arg2 withObject:(id)arg3 waitUntilDone:(BOOL)wait {
	[self performSelector:selector onThread:[NSThread mainThread] withObjects:[NSArray arrayWithObjects:arg, arg2, arg3, nil] waitUntilDone:wait];
}

- (id)performSelector:(SEL)selector withObjects:(NSArray*)objects{
	return [self performSelector:selector onThread:[NSThread currentThread] withObjects:objects waitUntilDone:YES];
}

- (id)performSelector:(SEL)selector onThread:(NSThread *)thread withObjects:(NSArray *)args waitUntilDone:(BOOL)wait {
    if ([self respondsToSelector:selector]) {
        
        NSMethodSignature *signature = [self methodSignatureForSelector:selector];
        if (signature) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			
			[invocation setTarget:self];
			[invocation setSelector:selector];
				
			if (args) {
				NSInteger i = 2;
				for (NSObject *object in args) {
                    if(i < [signature numberOfArguments]){
                        [invocation setArgument:&object atIndex:i];
                    }
                    ++i;
				}
			}
				
			[invocation retainArguments];

			[invocation performSelector:@selector(invoke)
							   onThread:thread
							 withObject:nil
						  waitUntilDone:wait];
            
            if([signature methodReturnLength] > 0){
                void* returnValue = nil;
                [invocation getReturnValue:&returnValue];
                
                
                return (id)returnValue;      
            }
		}
	}
    return nil;
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    [[[CKInvokationObject alloc]initWithObject:self block:block delay:delay]autorelease];
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay inModes:(NSArray*)modes{
    [[[CKInvokationObject alloc]initWithObject:self block:block delay:delay modes:modes]autorelease];
}

- (void)performBlockOnMainThread:(void (^)())block{
    [[[CKInvokationObject alloc]initWithObject:self block:block]autorelease];
}

- (void)performBlockOnMainThread:(void (^)())block inModes:(NSArray*)modes{
    [[[CKInvokationObject alloc]initWithObject:self block:block modes:modes]autorelease];
}

- (void)cancelPerformBlock{
    
    NSMutableArray* ar = [CKInvokationRegistry objectForKey:[NSValue valueWithNonretainedObject:self]];
    [ar retain];
    while([ar count] > 0){
        NSValue* v = [ar objectAtIndex:0];
        CKInvokationObject* invokation = [v nonretainedObjectValue];
        [invokation cancel];
    }
    [ar release];
}

- (void)cancelPeformBlock{
    [self cancelPerformBlock];
}

@end
