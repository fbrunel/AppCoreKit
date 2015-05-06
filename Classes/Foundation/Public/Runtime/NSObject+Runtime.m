//
//  NSObject+Runtime.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSObject+Runtime.h"
#import "NSObject+Runtime_private.h"
#import "CKClassPropertyDescriptor_private.h"
#import <objc/runtime.h>
#import <Foundation/NSKeyValueCoding.h>
#import <malloc/malloc.h>
#import "CKDebug.h"

#include <execinfo.h>
#import "UIView+Introspection.h"

/*
 The property is read-only (readonly).
 C
 The property is a copy of the value last assigned (copy).
 &
 The property is a reference to the value last assigned (retain).
 N
 The property is non-atomic (nonatomic).
 G<name>
 The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
 S<name>
 The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
 D
 The property is dynamic (@dynamic).
 W
 The property is a weak reference (__weak).
 P
 The property is eligible for garbage collection.
 */


static NSString* getPropertyType(objc_property_t property) {
	if(property){
		const char *attributes = property_getAttributes(property);
		char buffer[1 + strlen(attributes)];
		strcpy(buffer, attributes);
		char *state = buffer, *attribute;
		while ((attribute = strsep(&state, ",")) != NULL) {
			if(strlen(attribute) > 4){
				if (attribute[0] == 'T' && attribute[1] == '@') {
					return [[NSString stringWithUTF8String:attribute] substringWithRange: NSMakeRange(3, strlen(attribute)-4)];
				}
			}
		}
	}
    return @"";
}


NSMutableSet *textInputsProperties = nil;
void introspectTextInputsProperties(){
    if (!textInputsProperties)
	{
		textInputsProperties = [[NSMutableSet alloc] init];
		unsigned int count = 0;
		objc_property_t *properties = protocol_copyPropertyList(@protocol(UITextInput), &count);
		for (unsigned int i = 0; i < count; i++)
		{
			objc_property_t property = properties[i];
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			[textInputsProperties addObject:propertyName];
		}
		free(properties);
        
        [textInputsProperties addObject:@"caretRect"];
	}
}


@implementation NSObject (CKRuntime)

+ (CKClassPropertyDescriptor*)propertyForDescriptor:(objc_property_t)descriptor{
	const char *propName = property_getName(descriptor);
    if(propName) {
        CKClassPropertyDescriptor* objectProperty = [[CKClassPropertyDescriptor alloc]init];
        
        @autoreleasepool {
            const char *attributes = property_getAttributes(descriptor);
            
            NSString *propType = getPropertyType(descriptor);
            Class returnType = NSClassFromString(propType);
            
            objectProperty.name = [NSString stringWithUTF8String:propName];
            objectProperty.type = returnType;
            objectProperty.className = [NSString stringWithUTF8String:class_getName(returnType)];
            objectProperty.attributes = [NSString stringWithUTF8String:attributes];
            objectProperty.extendedAttributesSelector = [NSObject propertyExtendedAttributesSelectorForProperty:objectProperty.name];
            
            if([NSObject isClass:returnType kindOfClass:[NSArray class]]){
                objectProperty.insertSelector = [NSObject insertSelectorForProperty:objectProperty.name];
                objectProperty.removeSelector = [NSObject removeSelectorForProperty:objectProperty.name];
                objectProperty.removeAllSelector = [NSObject removeAllSelectorForProperty:objectProperty.name];
            }
        }
		
		return [objectProperty autorelease];
	}
	return nil;
}

+ (CKClassPropertyDescriptor*)propertyDescriptorForObject:(id)object keyPath:(NSString*)keyPath{
	id subObject = object;
	
    if([keyPath rangeOfString:@"."].location != NSNotFound){
        NSArray * ar = [keyPath componentsSeparatedByString:@"."];
        for(int i=0;i<[ar count]-1;++i){
            NSString* path = [ar objectAtIndex:i];
            if(!class_getProperty([subObject class],[path UTF8String])){
                return nil;
            }
            //NSLog(@"\tsub finding property:'%@' in '%@'",path,subObject);
            subObject = [subObject valueForKey:path];
        }
        if(subObject == nil){
            CKDebugLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
            return nil;
        }
        return [self propertyDescriptorForClass:[subObject class] key:[ar objectAtIndex:[ar count] -1 ]];
    }
    
    return [self propertyDescriptorForClass:[subObject class] key:keyPath];
}


+ (CKClassPropertyDescriptor*)propertyDescriptorForClass:(Class)c key:(NSString*)key{
	return [[CKClassPropertyDescriptorManager defaultManager]property:key forClass:c];
}

- (CKClassPropertyDescriptor*)propertyDescriptorForKeyPath:(NSString*)keyPath{
	return [NSObject propertyDescriptorForObject:self keyPath:keyPath];
}

- (void)_introspection:(Class)c array:(NSMutableArray*)array{
    introspectTextInputsProperties();
    
	unsigned int outCount, i;
    objc_property_t *ps = class_copyPropertyList(c, &outCount);
    for(i = 0; i < outCount; i++) {
        @autoreleasepool {
            objc_property_t property = ps[i];
            const char *propName = property_getName(property);
            
            NSString* name = [NSString stringWithUTF8String:propName];
            if([textInputsProperties containsObject:name]){
                //CKDebugLog(@"INTROSPECTION : Skipping property %ls on class %@ because it is an unsupported protocol UITextInput yet",propName,c);
            }
            else{
                CKClassPropertyDescriptor* objectProperty = [NSObject propertyForDescriptor:property ];
                if([objectProperty.name isEqualToString:@"topLayoutGuide"]
                   || [objectProperty.name isEqualToString:@"bottomLayoutGuide"]
                   || [objectProperty.name hasPrefix:@"_"]){
                    //http://stackoverflow.com/questions/18972762/uitableview-not-scrolling-after-switching-to-ios-7
                    //BYPass as it's causing UI Issues
                }else{
                    [array addObject:objectProperty];
                }
            }
        }
    }
    free(ps);	
    
	Class f = class_getSuperclass(c);
	if(f && ![NSObject isClass:f exactKindOfClass:[NSObject class]]){
		[self _introspection:f array:array];
	}
	
}

- (NSArray*)allViewsPropertyDescriptors{
	return [[CKClassPropertyDescriptorManager defaultManager]allViewsPropertyForClass:[self class]];
}

- (NSArray*)allPropertyDescriptors{
	return [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:[self class]];
}

- (NSArray*)allPropertyNames{
	return [[CKClassPropertyDescriptorManager defaultManager]allPropertieNamesForClass:[self class]];
}

+ (NSArray*)allViewsPropertyDescriptorsForClass:(Class)c{
	return [[CKClassPropertyDescriptorManager defaultManager]allViewsPropertyForClass:c];
}

+ (NSArray*)allPropertyDescriptorsForClass:(Class)c{
	return [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:c];
}

+ (NSArray*)allPropertyNamesForClass:(Class)c{
    return [[CKClassPropertyDescriptorManager defaultManager]allPropertieNamesForClass:c];
}

- (NSString*)className{
	return NSStringFromClass([self class]);
}

+ (NSArray*)superClassesForClass:(Class)c{
    NSMutableArray* classes = [NSMutableArray array]; 
    Class p = class_getSuperclass(c);
    while(p){
        [classes addObject:(id)p];
        p = class_getSuperclass(p);
    }
    return classes;
}

+ (BOOL)isClass:(Class)type kindOfClass:(Class)parentType{
	if(parentType){
		if([NSObject isClass:type exactKindOfClass:parentType])
			return YES;
		Class p = class_getSuperclass(type);
		if(p)
			return [NSObject isClass:p kindOfClass:parentType];
		return NO;
	}
	return YES;
}

+ (BOOL)isClass:(Class)type kindOfClassNamed:(NSString*)parentClassName{
    if(parentClassName){
		if([NSObject isClass:type exactKindOfClassNamed:parentClassName])
			return YES;
		Class p = class_getSuperclass(type);
		if(p)
			return [NSObject isClass:p kindOfClassNamed:parentClassName];
		return NO;
	}
	return YES;
}

+ (BOOL)isClass:(Class)type exactKindOfClass:(Class)parentType{
	if(parentType){
        if(type == parentType)
            return YES;
        
		//const char* t1 = class_getName(type);
		//const char* t2 = class_getName(parentType);
		//if(strcmp(t1,t2) == 0)
		//	return YES;
        
		return NO;
	}
	return YES;
}


+ (BOOL)isClass:(Class)type exactKindOfClassNamed:(NSString*)parentClassName{
    Class parentType = NSClassFromString(parentClassName);
    return [self isClass:type exactKindOfClass:parentType];
    
    /*if(parentClassName){
		const char* t1 = class_getName(type);
		const char* t2 = [parentClassName UTF8String];
		if(strcmp(t1,t2) == 0)
			return YES;
		return NO;
	}
	return YES;*/
}

+ (NSArray*)allClasses{
    return [NSObject allClassesKindOfClass:nil];
}

+ (NSArray*)allClassesKindOfClass:(Class)filter{
    int numClasses;
    Class * classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
     
        NSMutableArray* ret = [NSMutableArray arrayWithCapacity:numClasses];
        for(int i =0;i<numClasses; ++i){
            @autoreleasepool {
                Class theClass = classes[i];
                NSString* className = [NSString stringWithUTF8String:class_getName(theClass)];
                if([className hasPrefix:@"NSKVONotifying_"]){
                    //IGNORE
                }
                else{
                    if(filter){
                        if([NSObject isClass:theClass kindOfClass:filter]){
                            [ret addObject:(id)theClass];
                        }
                    }
                    else{
                        [ret addObject:(id)theClass];
                    }
                }
            }
        }
        
        free(classes);
        
        return ret;
    } 
    
    return nil;
}


+ (NSArray*)allClassesWithPrefix:(NSString*)prefix{
    int numClasses;
    Class * classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        NSMutableArray* ret = [NSMutableArray arrayWithCapacity:numClasses];
        for(int i =0;i<numClasses; ++i){
            @autoreleasepool {
                
                Class theClass = classes[i];
                NSString* className = [NSString stringWithUTF8String:class_getName(theClass)];
                if(prefix){
                    if([className hasPrefix:prefix]){
                        [ret addObject:(id)theClass];
                    }
                }
                else{
                    [ret addObject:(id)theClass];
                }
                
            }
        }
        
        free(classes);
        
        return ret;
    }
    
    return nil;

}

+ (NSArray*)allClassesConformToProtocol:(Protocol*)filter{
    int numClasses;
    Class * classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        NSMutableArray* ret = [NSMutableArray arrayWithCapacity:numClasses];
        for(int i =0;i<numClasses; ++i){
            @autoreleasepool {
                
                Class theClass = classes[i];
                NSString* className = [NSString stringWithUTF8String:class_getName(theClass)];
                if([className hasPrefix:@"NSKVONotifying_"]){
                    //IGNORE
                }
                else{
                    if(filter){
                        if([NSObject isClass:theClass kindOfClass:[NSObject class]]){
                            if([theClass conformsToProtocol:filter]){
                                [ret addObject:(id)theClass];
                            }
                        }
                    }
                    else{
                        [ret addObject:(id)theClass];
                    }
                }
            }
        }
        
        free(classes);
        
        return ret;
    }
    
    return nil;
}

- (BOOL)hasPropertyNamed:(NSString*)propertyName{
    objc_property_t property = class_getProperty([self class],[propertyName UTF8String]);
    return property != nil;
}


+ (NSArray*)allMethodsForClass:(Class)c{
    unsigned int numMethods;
    Method * methods = class_copyMethodList(c, &numMethods);
    if(numMethods == 0)
        return nil;
    
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:numMethods];
    for(int i =0;i<numMethods; ++i){
        Method theMethod = methods[i];
        NSValue* v = [NSValue valueWithBytes:&theMethod objCType:@encode(Method)];
        [ret addObject:v];
    }
    
    free(methods);
    
    return ret;
}

+ (NSArray*)allMethodNamesForClass:(Class)c{
    unsigned int numMethods;
    Method * methods = class_copyMethodList(c, &numMethods);
    if(numMethods == 0)
        return nil;
    
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:numMethods];
    for(int i =0;i<numMethods; ++i){
        Method theMethod = methods[i];
        SEL sel = method_getName(theMethod);
        [ret addObject:NSStringFromSelector(sel)];
    }
    
    free(methods);
    
    return ret;
}


- (NSArray*)allMethods{
    return [NSObject allMethodsForClass:[self class]];
}

@end



@implementation NSObject (CKRuntime_private)

- (void)introspection:(Class)c array:(NSMutableArray*)array{
	[self _introspection:c array:array];
	if([c respondsToSelector:@selector(additionalClassPropertyDescriptors)]){
		NSArray* additionalProperties = [c performSelector:@selector(additionalClassPropertyDescriptors)];
		[array addObjectsFromArray:additionalProperties];
	}
}

+ (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix{
	NSString* firstChar = [input substringWithRange: NSMakeRange (0, 1)];
	NSString* rest = [input substringWithRange: NSMakeRange (1, [input length] - 1)];
	return [NSString stringWithFormat:@"%@%@%@%@",prefix,[firstChar uppercaseString],rest,suffix];
}

+ (SEL)selectorForProperty:(NSString*)property prefix:(NSString*)prefix suffix:(NSString*)suffix{
	CKAssert(prefix && (prefix.length > 0), @"prefix should not be empty.");
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:property prefix:prefix suffix:suffix];
	return NSSelectorFromString(selectorName);
}

+ (SEL)selectorForProperty:(NSString*)property suffix:(NSString*)suffix{
	NSString* selectorName = [NSString stringWithFormat:@"%@%@",property,suffix];
	return NSSelectorFromString(selectorName);
}

+ (SEL)insertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)keyValueInsertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:forKey:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)typeCheckSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"is" suffix:@"CompatibleWith:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)setSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"set" suffix:@":"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyExtendedAttributesSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@ExtendedAttributes:",propertyName];
	return NSSelectorFromString(selectorName);
}

+ (SEL)insertSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"insert" suffix:@"Objects:atIndexes:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)removeSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"remove" suffix:@"ObjectsAtIndexes:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)removeAllSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"removeAll" suffix:@"Objects"];
	return NSSelectorFromString(selectorName);
}

@end
