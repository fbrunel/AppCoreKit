//
//  CKObject.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObject.h"
#import <objc/runtime.h>
#import "NSObject+Invocation.h"
#import "CKLocalization.h"
#import "CKDebug.h"
#import "CKCollection.h"
#import "CKPropertyExtendedAttributes.h"
#import "NSObject+Runtime_private.h"
#import <objc/runtime.h>
#import "CKConfiguration.h"

//nothing

static NSString* CKObjectAllPropertyNamesKey = @"CKModelObjectAllPropertyNamesKey";

@interface CKObject()
- (void)initializeProperties;
- (void)uninitializeProperties;
- (void)initializeKVO;
- (void)uninitializeKVO;


@property (nonatomic,readwrite) BOOL isSaving;
@property (nonatomic,readwrite) BOOL isLoading;

@end


@implementation CKObject{
	BOOL _saving;
	BOOL _loading;
}

@synthesize uniqueId,objectName;
@synthesize isSaving = _isSaving;
@synthesize isLoading = _isLoading;

- (void)uniqueIdExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.editable = NO;
}

- (void)isSavingExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.editable = NO;
}

- (void)isLoadingExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.editable = NO;
}

- (BOOL)isSaving{
	return _saving;
}

- (BOOL)isLoading{
	return _loading;
}

- (void)setLoading:(NSNumber*)number{
	_loading = [number boolValue];
}


- (void)setUniqueId:(NSString *)uid{
	_loading = YES;
	[uniqueId release];
	uniqueId = [uid copy];
	if(self.objectName == nil){
		self.objectName = uid;
	}
	_loading = NO;
}

+ (id)object{
	return [[[[self class]alloc]init]autorelease];
}

- (void)postInit{
}

- (void)initializeProperties{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			if(property.propertyType == CKClassPropertyDescriptorTypeObject){
				CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
				if(attributes.creatable){
					id p = [[[property.type alloc]init]autorelease];
					[self setValue:p forKey:property.name];
				}
			}
		}
	}
}

- (void)initializeKVO{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			SEL changeSelector =  [NSObject selectorForProperty:property.name suffix:@"Changed"];
			if([self respondsToSelector:changeSelector]){
				[self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
//				CKDebugLog(@"register <%p> of type <%@> as observer on <%p,%@>",self,[self class],self,property.name);
			}
			else if([NSObject isClass:property.type kindOfClass:[NSArray class]] 
					|| [NSObject isClass:property.type kindOfClass:[NSSet class]]
					|| [NSObject isClass:property.type kindOfClass:[CKCollection class]]){
				SEL addsSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsAdded:atIndexes:"];
				SEL removeSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsRemoved:atIndexes:"];
				SEL replaceSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:addsSelector] || [self respondsToSelector:removeSelector] || [self respondsToSelector:replaceSelector]){
                    if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                        //Watches the content updates
                        CKCollection* collection = [self valueForKey:property.name];
                        [collection addObserver:self];
                        
                        //watches the property update itself
                        [self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
                    }else{
                        [self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
                    }
				}
			}
		}
	}
}


- (void)uninitializeProperties{
   // if([[CKConfiguration sharedInstance]usingARC])
  //      return;
    
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			if((property.propertyType == CKClassPropertyDescriptorTypeObject) && 
			   ((property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy) || (property.assignementType == CKClassPropertyDescriptorAssignementTypeRetain))) {
				id object = [self valueForKey:property.name];
				if(object){
					[object release];
				}
				//[self setValue:nil forKey:property.name];
			}
		}
	}
}

- (void)uninitializeKVO{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			SEL changeSelector =  [NSObject selectorForProperty:property.name suffix:@"Changed"];
			if([self respondsToSelector:changeSelector]){
//				CKDebugLog(@"unregister <%p> of type <%@>  as observer on <%p,%@>",self,[self class],self,property.name);
				[self removeObserver:self forKeyPath:property.name];
			}
			
			else if([NSObject isClass:property.type kindOfClass:[NSArray class]] 
					|| [NSObject isClass:property.type kindOfClass:[NSSet class]]
					|| [NSObject isClass:property.type kindOfClass:[CKCollection class]]){
				SEL addsSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsAdded:atIndexes:"];
				SEL removeSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsRemoved:atIndexes:"];
				SEL replaceSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:addsSelector] || [self respondsToSelector:removeSelector] || [self respondsToSelector:replaceSelector]){
                    if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                        CKCollection* collection = [self valueForKey:property.name];
                        [collection removeObserver:self];
                        [self removeObserver:self forKeyPath:property.name];
                    }else{
                        [self removeObserver:self forKeyPath:property.name];
                    }
				}
			}
		}
	}
}

- (id)init{
	if (self = [super init]) {
      	[self initializeProperties];
        [self initializeKVO];
        [self postInit];
    }
	return self;
}

- (void)dealloc{
	[self uninitializeKVO];
	[self uninitializeProperties];
	[super dealloc];
}

- (NSString*)description{
	NSMutableString* desc = [NSMutableString stringWithFormat:@"%@ : <%p> {\n",[self className],self];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
            NSString* propertyString = nil;
            if([object isKindOfClass:[CKObject class]]){
                propertyString = [NSMutableString stringWithFormat:@"%@ : {%@ : <%p>}\n",property.name,[object className],object];
            }
            else{
                propertyString = [NSString stringWithFormat:@"%@ = %@\n",property.name,[object description]];
            }
			[desc appendString:propertyString];
		}
	}
	[desc appendString:@"}"];
    
	return desc;
}

- (id) copyWithZone:(NSZone *)zone {
	CKObject* copied = [[[self class] allocWithZone:zone] init];
    [copied copyPropertiesFromObject:self];
	return copied;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	CKAssert([aDecoder allowsKeyedCoding],@"CKObject does not support sequential archiving.");
    if (self = [super init]) {
		[self initializeProperties];
		[self initializeKVO];
		[self postInit];
		
		//FUCK names est mal serialize !!!!!!!!!
		NSArray* names = [aDecoder decodeObjectForKey:CKObjectAllPropertyNamesKey];
		NSMutableArray* allPropertiesInDecoder = [NSMutableArray arrayWithArray:names];
		
		NSArray* allProperties = [self allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in allProperties){
			CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
			if(attributes.serializable == YES){
				if([aDecoder containsValueForKey:property.name]){
					id objectFromDecoder = [aDecoder decodeObjectForKey:property.name];
					if([NSObject isClass:[objectFromDecoder class] kindOfClass:property.type]){
						[self setValue:objectFromDecoder forKey:property.name];
					}
					else if(objectFromDecoder){
						if(attributes.creatable){
							id p = [self valueForKey:property.name];
							if(p == nil){
								p = [[[property.type alloc]init]autorelease];
								[self setValue:p forKey:property.name];
							}
						}
						[self propertyChanged:property serializedObject:objectFromDecoder];
					}
				}else{
					if(attributes.creatable){
						id p = [self valueForKey:property.name];
						if(p == nil){
							p = [[[property.type alloc]init]autorelease];
							[self setValue:p forKey:property.name];
						}
					}
					
					[self propertyAdded:property];
				}
				
				[allPropertiesInDecoder removeObject:property.name];
			}
		}
			
		for(NSString* propertyName in allPropertiesInDecoder){
			id objectFromDecoder = [aDecoder decodeObjectForKey:propertyName];
			[self propertyRemoved:propertyName serializedObject:objectFromDecoder];
		}
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	CKAssert([aCoder allowsKeyedCoding],@"CKObject does not support sequential archiving.");
	NSMutableArray* names = [NSMutableArray arrayWithArray:[self allPropertyNames]];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
			CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
			if(attributes.serializable){
				[aCoder encodeObject:object forKey:property.name];
			}
			else{
				[names removeObject:property.name];
			}
		}
	}
	[aCoder encodeObject:names forKey:CKObjectAllPropertyNamesKey];
}

/*
- (NSUInteger)hash {
	NSMutableArray* allValues = [NSMutableArray array];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
			CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
			if(object && attributes.hashable){
				[allValues addObject:object];
			}
		}
	}
	return (NSUInteger)[allValues hash];
}*/


//For Migration
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object{
	CKDebugLog(@"property %@ type %@ found in archive has differs from current property type %@\nDo migration if needed.",property.name,[object className],[property className]);
}

- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object{
	CKDebugLog(@"property %@ in archive disappeard in model object of type %@\nDo migration if needed.",propertyName,[self className]);
}

- (void)propertyAdded:(CKClassPropertyDescriptor*)property{
	CKDebugLog(@"property %@ not found in archive for object of type %@\nDo migration if needed.",property.name,[self className]);
}

- (id)valueForUndefinedKey:(NSString *)key{
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {

    if([object isKindOfClass:[CKCollection class]]){
        for(CKClassPropertyDescriptor* descriptor in [self allPropertyDescriptors]){
            if([NSObject isClass:descriptor.type kindOfClass:[CKCollection class]] ){
                id value = [self valueForKey:descriptor.name ];
                if(value == object){
                    theKeyPath = descriptor.name;
                    object = self;
                    context = self;
                    break;
                }
            }
        }
    }else{
		NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
        if(kind == NSKeyValueChangeSetting){
            CKClassPropertyDescriptor* descriptor = [object propertyDescriptorForKeyPath:theKeyPath];
            if([NSObject isClass: descriptor.type kindOfClass:[CKCollection class]]){
                SEL addsSelector =  [NSObject selectorForProperty:descriptor.name suffix:@"ObjectsAdded:atIndexes:"];
                SEL removeSelector =  [NSObject selectorForProperty:descriptor.name suffix:@"ObjectsRemoved:atIndexes:"];
                SEL replaceSelector =  [NSObject selectorForProperty:descriptor.name suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
                if([object respondsToSelector:addsSelector] || [object respondsToSelector:removeSelector] || [object respondsToSelector:replaceSelector]){
                    //Check if the collection property itself has been mutated and register to the new instance and unregister from the old instance
                    
                    CKCollection* oldCollection =  [change objectForKey: NSKeyValueChangeOldKey];
                    CKCollection* newCollection =  [change objectForKey: NSKeyValueChangeNewKey];
                    
                    [oldCollection removeObserver:self];
                    [newCollection addObserver:self];
                }
            }
        }
    }
    
	if(object == context && object == self){
		NSIndexSet* indexes = [change objectForKey: NSKeyValueChangeIndexesKey];
		NSArray *oldModels =  [change objectForKey: NSKeyValueChangeOldKey];
		NSArray *newModels =  [change objectForKey: NSKeyValueChangeNewKey];
		
		NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
		switch(kind){
			case NSKeyValueChangeSetting:{
				SEL changeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"Changed"];
				if([self respondsToSelector:changeSelector]){
					[self performSelector:changeSelector];
				}
				break;
			}
			case NSKeyValueChangeInsertion:{
				SEL addsSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsAdded:atIndexes:"];
				if([self respondsToSelector:addsSelector]){
					[self performSelector:addsSelector withObject:newModels withObject:indexes];
				}
				SEL changeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"Changed"];
				if([self respondsToSelector:changeSelector]){
					[self performSelector:changeSelector];
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				SEL removeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsRemoved:atIndexes:"];
				if([self respondsToSelector:removeSelector]){
					[self performSelector:removeSelector withObject:oldModels withObject:indexes];
				}
				SEL changeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"Changed"];
				if([self respondsToSelector:changeSelector]){
					[self performSelector:changeSelector];
				}
				break;
			}
			case NSKeyValueChangeReplacement:{
				SEL replaceSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:replaceSelector]){
					[self performSelector:replaceSelector withObjects:[NSArray arrayWithObjects:oldModels,newModels,indexes,nil]];
				}
				SEL changeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"Changed"];
				if([self respondsToSelector:changeSelector]){
					[self performSelector:changeSelector];
				}
				break;
			}
		}
	}
}



@end

@implementation NSObject (CKObject)

- (void)copyPropertiesFromObject : (id)other{
	NSArray* allProperties = [other allPropertyDescriptors ];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:other];
			if(attributes.copiable){
				id value = [other valueForKey:property.name];
				if(attributes.deepCopy){
                    if([value isKindOfClass:[CKCollection class]]){
                        CKCollection* collection = value;
                        if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy){
                            value = [[property.type alloc]init];
                            [value setFeedSource:collection.feedSource];
                        }
                        else{
                            [collection removeAllObjects];
                        }
                        for(id object in [collection allObjects]){
                            [value addObject:[object copy]];
                        }
                    }
                    else if([value isKindOfClass:[NSArray class]]){
                        NSArray* array = value;
                        if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy){
                            value = [[NSMutableArray array]retain];
                        }
                        else{
                            [value removeAllObjects];
                        }
                        for(id object in array){
                            [value addObject:[object copy]];
                        }
                    }
                    else if([value isKindOfClass:[NSDictionary class]]){
                        NSDictionary* dico = value;
                        if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy){
                            value = [[NSMutableDictionary dictionary]retain];
                        }
                        else{
                            [value removeAllObjects];
                        }
                        for(id key in [dico allKeys]){
                            id object = [dico objectForKey:key];
                            [value setObject:[object copy] forKey:key];
                        }
                    }
                    else if([value isKindOfClass:[NSSet class]]){
                        NSMutableSet* set = value;
                        if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy){
                            value = [[NSMutableSet set]retain];
                        }
                        else{
                            [value removeAllObjects];
                        }
                        for(id object in set){
                            [value addObject:[object copy]];
                        }
                    }
                    if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy){
                        [value autorelease];
                    }
                }
				[self setValue:value forKey:property.name];
			}
		}
	}
}

- (BOOL)isEqualToObject:(id)other{
	if ([other isKindOfClass:[self class]]) {
		BOOL result = YES;
		NSArray* allProperties = [self allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in allProperties){
			if(property.isReadOnly == NO){
				id object = [self valueForKey:property.name];
                CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
				if(attributes.comparable){
					id otherObject = [other valueForKey:property.name];
					BOOL propertyEqual = ((object == nil && otherObject == nil) || [object isEqual:otherObject]);;
					if(!propertyEqual){
						result = NO;
					}
				}
			}
		}
		return result;
	}
	return NO;
}

@end