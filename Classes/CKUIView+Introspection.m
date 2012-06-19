//
//  CKUIView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"
#import "CKUIViewAutoresizing+Additions.h"
#import "CKVersion.h"

@implementation UIView (CKIntrospectionAdditions)

- (void)subviewsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.contentType = [UIView class];
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)insertSubviewsObjects:(NSArray *)views atIndexes:(NSIndexSet*)indexes{
	
	int i = 0;
	unsigned currentIndex = [indexes firstIndex];
	while (currentIndex != NSNotFound) {
		UIView* view = [views objectAtIndex:i];
		[self insertSubview:view atIndex:currentIndex];
		currentIndex = [indexes indexGreaterThanIndex: currentIndex];
		++i;
	}
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeSubviewsObjectsAtIndexes:(NSIndexSet*)indexes{
	NSArray* views = [self.subviews objectsAtIndexes:indexes];
	for(UIView* view in views){
		[view removeFromSuperview];
	}
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeAllSubviewsObjects{
	NSArray* views = [NSArray arrayWithArray:self.subviews];
	for(UIView* view in views){
		[view removeFromSuperview];
	}
}

- (void)setSubviews:(NSArray *)subviews{
    [self removeAllSubviewsObjects];
    for(id object in subviews){
        UIView* view = nil;
        if([object isKindOfClass:[UIView class]]){
            view = (UIView*)object;
        }else if([object isKindOfClass:[NSDictionary class]]){
            view = [NSValueTransformer objectFromDictionary:object];
        }else{
            NSAssert(NO,@"Non supported format");
        }
        [self addSubview:view];
    }
}

- (void)autoresizingMaskExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKBitMaskDefinition(@"UIViewAutoresizing",
                                                    UIViewAutoresizingNone,
                                                    UIViewAutoresizingFlexibleLeftMargin,
                                                    UIViewAutoresizingFlexibleWidth,
                                                    UIViewAutoresizingFlexibleRightMargin,
                                                    UIViewAutoresizingFlexibleTopMargin,
                                                    UIViewAutoresizingFlexibleHeight,
                                                    UIViewAutoresizingFlexibleBottomMargin,
                                                    UIViewAutoresizingFlexibleAll,
                                                    UIViewAutoresizingFlexibleSize,
                                                    UIViewAutoresizingFlexibleAllMargins,
                                                    UIViewAutoresizingFlexibleHorizontalMargins,
                                                    UIViewAutoresizingFlexibleVerticalMargins);
}

- (void)contentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIViewContentMode",
                                                 UIViewContentModeScaleToFill,
                                                 UIViewContentModeScaleAspectFit,
                                                 UIViewContentModeScaleAspectFill,
                                                 UIViewContentModeRedraw,
                                                 UIViewContentModeCenter,
                                                 UIViewContentModeTop,
                                                 UIViewContentModeBottom,
                                                 UIViewContentModeLeft,
                                                 UIViewContentModeRight,
                                                 UIViewContentModeTopLeft,
                                                 UIViewContentModeTopRight,
                                                 UIViewContentModeBottomLeft,
                                                 UIViewContentModeBottomRight);
}

+ (NSArray*)additionalClassPropertyDescriptors{
	NSMutableArray* properties = [NSMutableArray array];
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"backgroundColor"
																		   withClass:[UIColor class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeCopy
																			readOnly:NO]];
#if !TARGET_IPHONE_SIMULATOR
    NSString *appliedStyleDescription = @"appliedStyle";
#else
    NSString *appliedStyleDescription = @"debugAppliedStyle";
#endif
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:appliedStyleDescription
																		   withClass:[NSMutableDictionary class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeRetain
																			readOnly:YES]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"bounds"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"center"
																		   structName:@"CGPoint"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGPoint)]
																		   structSize:sizeof(CGPoint)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"subviews"
																		   withClass:[NSArray class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeCopy
																			readOnly:YES]];
	
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"clearsContextBeforeDrawing"
																		   readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"clipsToBounds"
																		   readOnly:NO]];
    if([CKOSVersion() floatValue] >= 6){
        [properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"hidden"
                                                                               readOnly:NO]];
    }
	[properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"contentMode"
																		  readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor floatDescriptorForPropertyNamed:@"contentScaleFactor"
																			readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"contentStretch"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"frame"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"transform"
																		   structName:@"CGAffineTransform"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGAffineTransform)]
																		   structSize:sizeof(CGAffineTransform)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"autoresizingMask"
																		  readOnly:NO]];
	
	/*
	 @property(nonatomic, getter=isHidden) BOOL hidden
	 */
	
	return properties;
}

@end

