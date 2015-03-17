//
//  CKPickerViewViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPickerViewViewController.h"
#import "UIView+Name.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"

@interface CKPickerViewViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,retain,readwrite) UIPickerView* pickerView;
@end

@implementation CKPickerViewViewController

- (void)dealloc{
    [_pickerView release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.pickerView = [[[UIPickerView alloc]initWithFrame:self.view.bounds]autorelease];
    self.pickerView.name = @"PickerView";
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    
    [self.view addSubview:self.pickerView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView reloadAllComponents];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
}


- (void)reloadComponentsMatchingIndexPaths:(NSArray*)indexPaths{
    NSMutableIndexSet* sections = [NSMutableIndexSet indexSet];
    for(NSIndexPath* indexPath in indexPaths){
        [sections addIndex:indexPath.section];
    }
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self.pickerView reloadComponent:idx];
    }];
}

- (void)willInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    
}

- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.pickerView reloadAllComponents];
}

- (void)willRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.pickerView reloadAllComponents];
}

- (void)willInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    [self reloadComponentsMatchingIndexPaths:indexPaths];
}

- (void)willRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    [self reloadComponentsMatchingIndexPaths:indexPaths];
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion{
    [super performBatchUpdates:updates completion:completion];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.sections.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    CKAbstractSection* section = [self sectionAtIndex:component];
    return section.controllers.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if(component >= self.sections.count)
        return 0.0f;
    
    return self.sections.count > 0 ? self.view.width / self.sections.count : self.view.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if(component >= self.sections.count)
        return 0.0f;
    
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:component]];
    CGFloat width = [self pickerView:pickerView widthForComponent:component];
    
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(width,MAXFLOAT)];
    return size.height;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    return [self viewForControllerAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component] reusingView:view];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
    [controller didSelect];
}

@end
