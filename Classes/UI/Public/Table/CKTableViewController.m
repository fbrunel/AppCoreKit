//
//  CKTableViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKTableViewController.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"

//For CKTableViewCell
#import "CKTableViewCellController.h"
#import "CKSheetController.h"


@interface CKTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain,readwrite) UITableView* tableView;
@property(nonatomic,retain) NSMutableArray* keyboardObservers;
@end

@implementation CKTableViewController

- (void)postInit{
    [super postInit];
    self.adjustInsetsOnKeyboardNotification = YES;
    self.style = UITableViewStyleGrouped;
    self.endEditingViewWhenScrolling = YES;
}

- (void)dealloc{
    [self unregisterForKeyboardNotifications];
    [_tableView release];
    [super dealloc];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                                 UITableViewStylePlain,
                                                 UITableViewStyleGrouped );
}

- (Class)tableViewClass{
    return [UITableView class];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSMutableDictionary* stylesheet = [self controllerStyle];
    if([stylesheet containsObjectForKey:@"style"]){
        [NSValueTransformer transform:[stylesheet objectForKey:@"style"] inProperty:[CKProperty propertyWithObject:self keyPath:@"style"]];
    }
    
    self.tableView = [[[[self tableViewClass] alloc]initWithFrame:self.view.bounds style:self.style]autorelease];
    self.tableView.name = @"TableView";
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    [self registerForKeyboardNotifications];
    
    //for(NSIndexPath* indexPath in self.selectedIndexPaths){
    //    [self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    //}
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [self unregisterForKeyboardNotifications];
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion{
    [self.tableView beginUpdates];
    if(updates){
        updates();
    }
    [self.tableView endUpdates];
    
    if(completion){
        completion(YES);
    }
}

#pragma mark CKSectionedViewController protocol


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView insertSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView deleteSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (UIView*)contentView{
    return self.tableView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

#pragma mark Managing Content

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    return s.controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    CKTableViewCell* cell = (CKTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell = [[CKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    return (UITableViewCell*)[self viewForControllerAtIndexPath:indexPath reusingView:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
    return size.height;
}


- (void)invalidateSizeForControllerAtIndexPath:(NSIndexPath*)indexPath{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    if(controller.contentViewCell){
        CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return controller.estimatedRowHeight;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidAppear)
        return;
    
    if(controller.state != CKViewControllerStateWillAppear){
        [controller viewWillAppear:NO];
    }
    if(controller.state != CKViewControllerStateDidAppear){
        [controller viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidDisappear)
        return;
    
    if(controller.state != CKViewControllerStateWillDisappear){
        [controller viewWillDisappear:NO];
    }
    if(controller.state != CKViewControllerStateDidDisappear){
        [controller viewDidDisappear:NO];
    }
}


#pragma mark Managing section headers

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.headerViewController)
        return nil;
    
    NSString* reuseIdentifier = [s.headerViewController reuseIdentifier];
    
#ifdef USING_UITableViewHeaderFooterView
    UITableViewHeaderFooterView* view = (UITableViewHeaderFooterView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
#else
    UIView* view = nil;
#endif
    
    if(!view){
#ifdef USING_UITableViewHeaderFooterView
        view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier];
#else
        view = [[UIView alloc]init];
#endif
    }
    
    return [self viewForController:s.headerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.headerViewController)
        return UITableViewAutomaticDimension;
    
    return [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height ;
}

#ifdef USING_UITableViewHeaderFooterView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.headerViewController)
        return UITableViewAutomaticDimension;
    
    if(s.headerViewController.contentViewCell){
        CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return s.headerViewController.estimatedRowHeight;
}

#endif

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
    
    if(s.headerViewController.view != view || s.headerViewController.state == CKViewControllerStateDidAppear)
        return;
    
    if(s.headerViewController.state != CKViewControllerStateWillAppear){
        [s.headerViewController viewWillAppear:NO];
    }
    if(s.headerViewController.state != CKViewControllerStateDidAppear){
        [s.headerViewController viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
    if(s.headerViewController.view != view || s.headerViewController.state == CKViewControllerStateDidDisappear)
        return;
    
    if(s.headerViewController.state != CKViewControllerStateWillDisappear){
        [s.headerViewController viewWillDisappear:NO];
    }
    if(s.headerViewController.state != CKViewControllerStateDidDisappear){
        [s.headerViewController viewDidDisappear:NO];
    }
}


#pragma mark Managing section footers

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.footerViewController)
        return nil;
    
    NSString* reuseIdentifier = [s.footerViewController reuseIdentifier];

#ifdef USING_UITableViewHeaderFooterView
    UITableViewHeaderFooterView* view = (UITableViewHeaderFooterView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
#else
    UIView* view = nil;
#endif
    
    if(!view){
#ifdef USING_UITableViewHeaderFooterView
        view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier];
#else
        view = [[UIView alloc]init];
#endif
    }
    
    return [self viewForController:s.footerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    return [s.footerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height;
}

#ifdef USING_UITableViewHeaderFooterView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    if(s.footerViewController.contentViewCell){
        CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return s.footerViewController.estimatedRowHeight;
}
#endif

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
    
    if(s.footerViewController.view != view || s.footerViewController.state == CKViewControllerStateDidAppear)
        return ;
    
    if(s.footerViewController.state != CKViewControllerStateWillAppear){
        [s.footerViewController viewWillAppear:NO];
    }
    if(s.footerViewController.state != CKViewControllerStateDidAppear){
        [s.footerViewController viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
    
    if(s.footerViewController.view != view || s.footerViewController.state == CKViewControllerStateDidDisappear)
        return;
    
    if(s.footerViewController.state != CKViewControllerStateWillDisappear){
        [s.footerViewController viewWillDisappear:NO];
    }
    if(s.footerViewController.state != CKViewControllerStateDidDisappear){
        [s.footerViewController viewDidDisappear:NO];
    }
}

#pragma mark Managing selection and highlight


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    return controller.flags & CKItemViewFlagSelectable;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
     //TODO
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
     //TODO
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    BOOL bo = controller.flags & CKItemViewFlagSelectable;
    if(bo){
        return indexPath;
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
    [selected addObject:indexPath];
    self.selectedIndexPaths = selected;
    
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    [controller didSelect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //Cause didDeselectRowAtIndexPath is not called!
        NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
        [selected removeObject:indexPath];
        self.selectedIndexPaths = selected;
    });
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.selectedIndexPaths = selected;
}

#pragma mark Managing Edition

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//TODO
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//TODO
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    //TODO
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.endEditingViewWhenScrolling){
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
    }
}

- (void)registerForKeyboardNotifications
{
    if(!self.adjustInsetsOnKeyboardNotification)
        return;
    
    __unsafe_unretained CKTableViewController* bself = self;
    
    self.keyboardObservers = [NSMutableArray array];
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillShowNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
        [bself keyboardWasShown:note];
    }]];
    
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillHideNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
        [bself keyboardWillBeHidden:note];
    }]];
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:CKSheetWillShowNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       [bself keyboardWasShown:note];
                                                                                   }]];
    
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:CKSheetWillHideNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       [bself keyboardWillBeHidden:note];
                                                                                   }]];
}

- (void)unregisterForKeyboardNotifications
{
    for(id observer in self.keyboardObservers){
        [[NSNotificationCenter defaultCenter]removeObserver:observer];
    }
    self.keyboardObservers = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = CGSizeZero;
    if([info objectForKey:CKSheetFrameEndUserInfoKey]){
        kbSize = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue].size;
    }else{
        kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                  self.tableView.contentInset.left,
                                                  self.tableView.contentInset.bottom + kbSize.height,
                                                  self.tableView.contentInset.right);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = CGSizeZero;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    if([info objectForKey:CKSheetFrameEndUserInfoKey]){
        kbSize = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue].size;
        animationCurve = (UIViewAnimationCurve)[[info objectForKey:CKSheetAnimationCurveUserInfoKey] integerValue];
        animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
    }else{
        kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                  self.tableView.contentInset.left,
                                                  self.tableView.contentInset.bottom - kbSize.height,
                                                  self.tableView.contentInset.right);
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

@end




@implementation CKCollectionCellContentViewController(CKTableViewController)
@dynamic tableViewCell;

- (CKTableViewCell*)tableViewCell{
    if([self.contentViewCell isKindOfClass:[CKTableViewCell class]])
        return (CKTableViewCell*)self.contentViewCell;
    return nil;
}

#ifdef USING_UITableViewHeaderFooterView
- (UITableViewHeaderFooterView*)headerFooterView{
    if([self.contentViewCell isKindOfClass:[UITableViewHeaderFooterView class]])
        return (UITableViewHeaderFooterView*)self.contentViewCell;
    return nil;
}
#endif

@end
