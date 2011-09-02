//
//  CKOptionPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKOptionPropertyCellController.h"
#import "CKLocalization.h"
#import "CKNSObject+Bindings.h"


@interface CKOptionPropertyCellController ()
@property (nonatomic,retain) NSArray* values;
@property (nonatomic,retain) NSArray* labels;
@property (nonatomic,readonly) BOOL multiSelectionEnabled;
@end

@implementation CKOptionPropertyCellController
@synthesize optionCellStyle;
@synthesize values;
@synthesize labels;
@synthesize multiSelectionEnabled;

- (id)init{
    self = [super init];
    self.cellStyle = CKTableViewCellStylePropertyGrid;
    self.optionCellStyle = CKTableViewCellStylePropertyGrid;
    return self;
}

- (void)dealloc{
    self.values = nil;
    self.labels = nil;
    [super dealloc];
}

- (void)setupLabelsAndValues{
    CKObjectProperty* property = [self objectProperty];
    CKObjectPropertyMetaData* metaData = [property metaData];
    NSDictionary* valuesAndLabels = nil;
    if(metaData.valuesAndLabels) valuesAndLabels = metaData.valuesAndLabels;
    else if(metaData.enumDescriptor) valuesAndLabels = metaData.enumDescriptor.valuesAndLabels;

    NSAssert(valuesAndLabels != nil,@"No valuesAndLabels or EnumDefinition declared for property %@",property);
    NSArray* orderedLabels = [[valuesAndLabels allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* str1 = _(obj1);
        NSString* str2 = _(obj2);
        return [str1 compare:str2];
    }];
    
    NSMutableArray* orderedValues = [NSMutableArray array];
    for(NSString* label in orderedLabels){
        id value = [valuesAndLabels objectForKey:label];
        [orderedValues addObject:value];
    }
    
    self.labels = orderedLabels;
    self.values = orderedValues;
}

- (BOOL)multiSelectionEnabled{
    CKObjectProperty* property = [self objectProperty];
    CKObjectPropertyMetaData* metaData = [property metaData];
    return metaData.multiselectionEnabled;
}

- (NSString *)labelForValue:(NSInteger)intValue {
	if (intValue < 0
		|| intValue == NSNotFound) {
		
		CKObjectProperty* property = [self objectProperty];
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		NSString* str = [NSString stringWithFormat:@"%@_PlaceHolder",descriptor.name];
		return _(str);
	}
	
	if(self.multiSelectionEnabled){
		NSMutableString* str = [NSMutableString string];
		for(int i= 0;i < [self.values count]; ++i){
			NSNumber* v = [self.values objectAtIndex:i];
			NSString* l = [self.labels objectAtIndex:i];
			if(intValue & [v intValue]){
				if([str length] > 0){
					[str appendFormat:@"%@%@",_(@"_|_"),_(l)];
				}
				else{
					[str appendString:_(l)];
				}
			}
		}
        return str;
	}
	else{
		NSInteger index = intValue;
        NSString* str = (self.labels && index != NSNotFound) ? [self.labels objectAtIndex:index] : [NSString stringWithFormat:@"%@", intValue];
		return _(str);
	}
	return nil;
}

- (NSArray*)indexesForValue:(NSInteger) value{
	NSMutableArray* indexes = [NSMutableArray array];
	NSInteger intValue = value;
	for(int i= 0;i < [self.values count]; ++i){
		NSNumber* v = [self.values objectAtIndex:i];
		if(intValue & [v intValue]){
			[indexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	return indexes;
}

- (NSInteger)currentValue{
    CKObjectProperty* property = [self objectProperty];
    if(self.multiSelectionEnabled){
        return [[property value]intValue];
    }
    else{
        NSInteger index = [self.values indexOfObject:[property value]];
        return index;
    }
    return -1;
}

//

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
    
    [self setupLabelsAndValues];
    
    if(self.readOnly){
        self.fixedSize = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        self.fixedSize = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CKObjectProperty* property = [self objectProperty];
    
    cell.textLabel.text = _(property.name);
	cell.detailTextLabel.text = [self labelForValue:[self currentValue]];

    [self beginBindingsContextByKeepingPreviousBindings];
    [property.object bind:property.keyPath withBlock:^(id value){
        self.tableViewCell.detailTextLabel.text = [self labelForValue:[self currentValue]];
    }];
    [self endBindingsContext];
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        }  
        else{
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  
    
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
    CKOptionPropertyCellController* staticController = (CKOptionPropertyCellController*)[params staticController];
    if(staticController.readOnly){
        return CKItemViewFlagNone;
    }
    return CKItemViewFlagSelectable;
}

- (void)didSelectRow {
	[super didSelectRow];
    
    CKObjectProperty* property = [self objectProperty];
    
    CKTableViewController* tableController = (CKTableViewController*)[self parentController];
	CKOptionTableViewController *optionTableController = nil;
	if(self.multiSelectionEnabled){
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self indexesForValue:[self currentValue]] multiSelectionEnabled:YES style:[tableController style]] autorelease];
	}
	else{
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self  currentValue] style:[tableController style]] autorelease];
	}
    optionTableController.optionCellStyle = self.optionCellStyle;
	optionTableController.title = _(property.name);
	optionTableController.optionTableDelegate = self;
	[self.parentController.navigationController pushViewController:optionTableController animated:YES];
}

//

- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index {
	if(self.multiSelectionEnabled){
		NSArray* indexes = tableViewController.selectedIndexes;
		NSInteger v = 0;
		for(NSNumber* index in indexes){
			v |= [[self.values objectAtIndex:[index intValue]]intValue];
		}
        
        [self setValueInObjectProperty:[NSNumber numberWithInt:v]];
    }
	else{
        NSInteger index = tableViewController.selectedIndex;
        id value = [self.values objectAtIndex:index];
        [self setValueInObjectProperty:value];
	}
	
	if(!self.multiSelectionEnabled){
		[self.parentController.navigationController popViewControllerAnimated:YES];
	}
}

@end