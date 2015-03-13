//
//  CKPropertyExtendedAttributes+CKAttributes.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation CKPropertyExtendedAttributes (CKObject)
@dynamic comparable,serializable,copiable,deepCopy,hashable,creatable,validationPredicate,contentType,contentProtocol,dateFormat,enumDescriptor;

- (void)setComparable:(BOOL)comparable{
    [self.attributes setObject:[NSNumber numberWithBool:comparable] forKey:@"CKPropertyExtendedAttributes_CKObject_comparable"];
}

- (BOOL)comparable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_comparable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setSerializable:(BOOL)serializable{
    [self.attributes setObject:[NSNumber numberWithBool:serializable] forKey:@"CKPropertyExtendedAttributes_CKObject_serializable"];
}

- (BOOL)serializable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_serializable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setCopiable:(BOOL)copiable{
    [self.attributes setObject:[NSNumber numberWithBool:copiable] forKey:@"CKPropertyExtendedAttributes_CKObject_copiable"];
}

- (BOOL)copiable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_copiable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setDeepCopy:(BOOL)deepCopy{
    [self.attributes setObject:[NSNumber numberWithBool:deepCopy] forKey:@"CKPropertyExtendedAttributes_CKObject_deepCopy"];
}

- (BOOL)deepCopy{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_deepCopy"];
    if(value) return [value boolValue];
    return NO;
}

- (void)setHashable:(BOOL)hashable{
    [self.attributes setObject:[NSNumber numberWithBool:hashable] forKey:@"CKPropertyExtendedAttributes_CKObject_hashable"];
}

- (BOOL)hashable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_hashable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setCreatable:(BOOL)creatable{
    [self.attributes setObject:[NSNumber numberWithBool:creatable] forKey:@"CKPropertyExtendedAttributes_CKObject_creatable"];
}

- (BOOL)creatable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_creatable"];
    if(value) return [value boolValue];
    
    //TODO : Return YES if CKCollection !
    return NO;
}

- (void)setValidationPredicate:(NSPredicate *)validationPredicate{
    [self.attributes setObject:validationPredicate forKey:@"CKPropertyExtendedAttributes_CKObject_validationPredicate"];
}

- (NSPredicate*)validationPredicate{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_validationPredicate"];
    return value;
}

-(void)setContentType:(Class)contentType{
    [self.attributes setObject:[NSValue valueWithPointer:contentType] forKey:@"CKPropertyExtendedAttributes_CKObject_contentType"];
}

- (Class)contentType{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_contentType"];
    if(value) return [value pointerValue];
    return nil;
}

-(void)setContentProtocol:(Protocol*)protocol{
    //TODO
}

- (Protocol*)contentProtocol{
    //TODO
    return nil;
}

- (void)setDateFormat:(NSString *)dateFormat{
    [self.attributes setObject:dateFormat forKey:@"CKPropertyExtendedAttributes_CKObject_dateFormat"];
}

- (NSString*)dateFormat{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_dateFormat"];
    return value ? value : @"yyyy-MM-dd";
}


- (void)setEnumDescriptor:(CKEnumDescriptor *)enumDescriptor{
    [self.attributes setObject:enumDescriptor forKey:@"CKPropertyExtendedAttributes_CKObject_enumDescriptor"];
}

- (CKEnumDescriptor*)enumDescriptor{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_enumDescriptor"];
    return value;
}

@end

@implementation CKPropertyExtendedAttributes (CKPropertyGrid)
@dynamic editable,valuesAndLabels,cellControllerCreationBlock;

- (void)setEditable:(BOOL)editable{
    [self.attributes setObject:[NSNumber numberWithBool:editable] forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_editable"];
}

- (BOOL)editable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_editable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setValuesAndLabels:(NSDictionary*)valuesAndLabels{
    [self.attributes setObject:valuesAndLabels forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_valuesAndLabels"];
}

- (NSDictionary*)valuesAndLabels{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_valuesAndLabels"];
    return value;
}

- (void)setCellControllerCreationBlock:(CKCellControllerCreationBlock)cellControllerCreationBlock{
    [self.attributes setObject:[[cellControllerCreationBlock copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_cellControllerCreationBlock"];
}

- (CKCellControllerCreationBlock)cellControllerCreationBlock{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_cellControllerCreationBlock"];
    return value;
}

@end

@implementation CKPropertyExtendedAttributes (CKNSNumberPropertyCellController)
@dynamic minimumValue,maximumValue;

- (void)setMinimumValue:(NSNumber*)minimumValue{
    [self.attributes setObject:minimumValue forKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_minimumValue"];
}

- (NSNumber*)minimumValue{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_minimumValue"];
    return value;
}

- (void)setMaximumValue:(NSNumber*)maximumValue{
    [self.attributes setObject:maximumValue forKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_maximumValue"];
}

- (NSNumber*)maximumValue{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_maximumValue"];
    return value;
}




@end


@implementation CKPropertyExtendedAttributes (CKMultilineNSStringPropertyCellController)
@dynamic multiLineEnabled;

- (void)setMultiLineEnabled:(BOOL)multiLineEnabled{
    [self.attributes setObject:[NSNumber numberWithBool:multiLineEnabled] forKey:@"CKPropertyExtendedAttributes_CKMultilineNSStringPropertyCellController_multiLineEnabled"];
}

- (BOOL)multiLineEnabled{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKMultilineNSStringPropertyCellController_multiLineEnabled"];
    if(value) return [value boolValue];
    return NO;
}

@end


@implementation CKPropertyExtendedAttributes (CKOptionPropertyCellController)
@dynamic multiSelectionEnabled;
@dynamic sortingBlock;
@dynamic presentationStyle;
@dynamic optionCellControllerCreationBlock;

- (void)setMultiSelectionEnabled:(BOOL)multiSelectionEnabled{
    [self.attributes setObject:[NSNumber numberWithBool:multiSelectionEnabled] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_multiSelectionEnabled"];
}

- (BOOL)multiSelectionEnabled{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_multiSelectionEnabled"];
    if(value) return [value boolValue];
    return NO;
}

- (void)setPresentationStyle:(CKOptionPropertyCellControllerPresentationStyle)presentationStyle{
    [self.attributes setObject:[NSNumber numberWithInt:presentationStyle] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_presentationStyle"];
}

- (CKOptionPropertyCellControllerPresentationStyle)presentationStyle{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_presentationStyle"];
    if(value) return (CKOptionPropertyCellControllerPresentationStyle)[value integerValue];
    return CKOptionPropertyCellControllerPresentationStyleDefault;
}

- (void)setSortingBlock:(CKOptionPropertyCellControllerSortingBlock)block{
    [self.attributes setObject:[[block copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_sortingBlock"];
}

- (CKOptionPropertyCellControllerSortingBlock)sortingBlock{
    return [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_sortingBlock"];
}

- (void)setOptionCellControllerCreationBlock:(CKTableViewCellController *(^)(NSString *, id))optionCellControllerCreationBlock{
    [self.attributes setObject:[[optionCellControllerCreationBlock copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_optionCellControllerCreationBlock"];
}

- (CKTableViewCellController *(^)(NSString *, id))optionCellControllerCreationBlock{
    return [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_optionCellControllerCreationBlock"];
}

@end



@implementation CKPropertyExtendedAttributes (CKNSDateViewController)
@dynamic minimumDate,maximumDate,minuteInterval;

- (void)setMinimumDate:(NSDate *)minimumDate{
    [self.attributes setObject:minimumDate forKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_minimumDate"];
}

- (NSDate*)minimumDate{
    return [self.attributes valueForKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_minimumDate"];
}

- (void)setMaximumDate:(NSDate *)maximumDate{
    [self.attributes setObject:maximumDate forKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_maximumDate"];
}

- (NSDate*)maximumDate{
    return [self.attributes valueForKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_maximumDate"];
}
- (void)setMinuteInterval:(NSInteger)minuteInterval{
    [self.attributes setObject:[NSNumber numberWithInteger:minuteInterval] forKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_minuteInterval"];
}

- (NSInteger)minuteInterval{
    id obj = [self.attributes valueForKey:@"CKPropertyExtendedAttributes_CKNSDateViewController_minuteInterval"];
    return obj ? [obj integerValue] : -1;
}

@end

