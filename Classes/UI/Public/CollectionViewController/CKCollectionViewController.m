//
//  CKCollectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionViewController.h"
#import "CKCollectionViewFlowLayout.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"
#import "CKVersion.h"

#import "CKSheetController.h"
#import "CKRuntime.h"
#import <objc/runtime.h>

@interface CKCollectionViewController()
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@property (nonatomic, assign, readwrite) BOOL scrolling;
@property(nonatomic,retain,readwrite) CKPassThroughView* backgroundView;
@property(nonatomic,retain,readwrite) CKPassThroughView* foregroundView;
@property(nonatomic,assign) BOOL collectionViewHasInitiatedSetup;
@end

@implementation CKCollectionViewController

- (instancetype)init{
    return [self initWithCollectionViewLayout:[[[CKCollectionViewFlowLayout alloc]init]autorelease]];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

- (void)postInit{
    [super postInit];
    self.collectionViewHasInitiatedSetup = NO;
    self.multiselectionEnabled = NO;
    self.stickySelectionEnabled = NO;
    self.scrolling = NO;
    self.sectionContainer = [[[CKSectionContainer alloc]initWithDelegate:self]autorelease];
}

- (void)dealloc{
    [self.backgroundView removeFromSuperview];
    [self.foregroundView removeFromSuperview];
    
    [self clearBindingsContextWithScope:@"foregroundView"];
    [self clearBindingsContextWithScope:@"backgroundView"];

    [_sectionContainer release];
    [_backgroundView release];
    [_foregroundView release];
    [super dealloc];
}

- (void)setCollectionViewLayout:(UICollectionViewLayout*)collectionViewLayout animated:(BOOL)animated{
    if([self isViewLoaded]){
        [self.collectionView setCollectionViewLayout:collectionViewLayout animated:animated];
    }else{
        //self.collectionViewLayout = collectionViewLayout;
        int i =3;
    }
}

#pragma Managing Decorator Views

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.backgroundView = [[[CKPassThroughView alloc]initWithFrame:[self backgroundViewFrame]]autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.backgroundView.flexibleSize = YES;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.clipsToBounds = YES;
    
    self.foregroundView = [[[CKPassThroughView alloc]initWithFrame:[self foregroundViewFrame]]autorelease];
    self.foregroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.foregroundView.flexibleSize = YES;
    self.foregroundView.backgroundColor = [UIColor clearColor];
    self.foregroundView.clipsToBounds = YES;

    
    self.collectionView.backgroundColor = [UIColor clearColor];
}


- (CGRect)backgroundViewFrame{
    CGRect backgroundViewRect = CGRectMake(0 + self.backgroundViewInsets.left,
                                           0 + self.backgroundViewInsets.top,
                                           self.collectionView.bounds.size.width - (self.backgroundViewInsets.left + self.backgroundViewInsets.right),
                                           self.collectionView.bounds.size.height - (self.backgroundViewInsets.top + self.backgroundViewInsets.bottom)) ;
    return backgroundViewRect;
}

- (void)setBackgroundViewInsets:(UIEdgeInsets)insets{
    _backgroundViewInsets = insets;
    [self.backgroundView setFrame:[self backgroundViewFrame] animated:NO];
}

- (void)presentsBackgroundView{
    if(self.view  && [self.backgroundView superview] == nil){
        [self.view insertSubview:self.backgroundView belowSubview:self.collectionView];
        
        __block CKCollectionViewController* bself = self;
        
        [self beginBindingsContextWithScope:@"backgroundView"];
        [self.collectionView bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
            [CATransaction setDisableActions:YES];
            [bself.backgroundView setFrame:[bself backgroundViewFrame] animated:NO];
            [CATransaction commit];
        }];
        [self.view bind:@"hidden" executeBlockImmediatly:YES withBlock:^(id value) {
            bself.foregroundView.hidden = bself.view.hidden;
        }];
        [self endBindingsContext];
    }
}

- (CGRect)foregroundViewFrame{
    CGRect foregroundViewRect = CGRectMake(0 + self.foregroundViewInsets.left,
                                           0 + self.foregroundViewInsets.top,
                                           self.collectionView.bounds.size.width - (self.foregroundViewInsets.left + self.foregroundViewInsets.right),
                                           self.collectionView.bounds.size.height - (self.foregroundViewInsets.top + self.foregroundViewInsets.bottom)) ;
    return foregroundViewRect;
}

- (void)presentsForegroundView{
    if(self.view  && [self.foregroundView superview] == nil){
        [self.view insertSubview:self.foregroundView aboveSubview:self.collectionView];
        
        __block CKCollectionViewController* bself = self;
        
        [self beginBindingsContextWithScope:@"foregroundView"];
        [self.collectionView bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
            [CATransaction setDisableActions:YES];
            [bself.foregroundView setFrame:[bself foregroundViewFrame] animated:NO];
            [CATransaction commit];
        }];
        [self.view bind:@"hidden" executeBlockImmediatly:YES withBlock:^(id value) {
            bself.foregroundView.hidden = bself.view.hidden;
        }];
        [self endBindingsContext];
    }
}

- (void)setForegroundViewInsets:(UIEdgeInsets)insets{
    _foregroundViewInsets = insets;
    [self.foregroundView setFrame:[self foregroundViewFrame] animated:NO];
}

- (void)dismissBackgroundView{
    [self beginBindingsContextWithScope:@"backgroundView"];
    [self.backgroundView removeFromSuperview];
}

- (void)dismissForegroundView{
    [self beginBindingsContextWithScope:@"foregroundView"];
    [self.foregroundView removeFromSuperview];
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self presentsBackgroundView];
    [self presentsForegroundView];
}

#pragma Managing Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self fetchMoreData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Support for navigation push transitions:
    // [self.sectionContainer handleViewDidAppearAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[self.view superview] endEditing:YES];
    
    //Support for navigation push transitions:
    // [self.sectionContainer handleViewWillDisappearAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //Support for navigation push transitions:
    //[self.sectionContainer handleViewDidDisappearAnimated:animated];
    [self dismissBackgroundView];
    [self dismissForegroundView];
}


#pragma Managing Batch Updates

- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL finished))completion{
    if((self.state == CKViewControllerStateDidAppear || self.state == CKViewControllerStateWillAppear) && self.collectionViewHasInitiatedSetup){
        [self.collectionView performBatchUpdates:updates completion:completion];
    }else{
        if(updates){
            updates();
        }
        if(completion){
            completion(YES);
        }
    }
}


#pragma mark CKSectionedViewController protocol


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(!self.collectionViewHasInitiatedSetup){
        sectionUpdate();
        return;
    }
    
    if(animated){
        [self performBatchUpdates:^{
            sectionUpdate();
            [self.collectionView insertSections:indexes];
        } completion:nil];
    }else{
        sectionUpdate();
        [self.collectionView insertSections:indexes];
        [self.collectionView invalidateLayout];
        
    }
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(!self.collectionViewHasInitiatedSetup){
        sectionUpdate();
        return;
    }
    
    if(animated){
        [self performBatchUpdates:^{
            sectionUpdate();
            [self.collectionView deleteSections:indexes];
        } completion:nil];
    }else{
        sectionUpdate();
        [self.collectionView deleteSections:indexes];
        [self.collectionView invalidateLayout];
    }
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(!self.collectionViewHasInitiatedSetup){
        sectionUpdate();
        return;
    }
    
    if(animated){
        [self performBatchUpdates:^{
            sectionUpdate();
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } completion:nil];
    }else{
        sectionUpdate();
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        [self.collectionView invalidateLayout];
    }
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(!self.collectionViewHasInitiatedSetup){
        sectionUpdate();
        return;
    }
    
    if(animated){
        [self performBatchUpdates:^{
            sectionUpdate();
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        } completion:nil];
    }else{
        sectionUpdate();
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        [self.collectionView invalidateLayout];
    }
}

- (UIView*)contentView{
    return self.collectionView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:animated ];
}


#pragma mark Managing Content

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    self.collectionViewHasInitiatedSetup = YES;
    return self.sectionContainer.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    return s.controllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    //  NSLog(@"self %p collectionView %p cellForIndexPath %@",self,collectionView,indexPath);
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    UICollectionViewCell* cell = (UICollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.contentView.flexibleSize = YES;
    return (UICollectionViewCell*)[self.sectionContainer viewForControllerAtIndexPath:indexPath reusingView:cell];
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidAppear)
        return;
    
    if(controller.state != CKViewControllerStateWillAppear){
        [controller viewWillAppear:NO];
    }
    if(controller.state != CKViewControllerStateDidAppear){
        [controller viewDidAppear:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidDisappear)
        return;
    
    if(controller.state != CKViewControllerStateWillDisappear){
        [controller viewWillDisappear:NO];
    }
    if(controller.state != CKViewControllerStateDidDisappear){
        [controller viewDidDisappear:NO];
    }
}

#pragma mark Managing Supplementary Views

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
        if(!s.headerViewController)
            return nil;
        
        NSString* reuseIdentifier = [s.headerViewController reuseIdentifier];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
        
        UICollectionReusableView* view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        view.flexibleSize = YES;
        
        return (UICollectionReusableView*)[self.sectionContainer viewForController:s.headerViewController reusingView:view];
    }else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
        if(!s.footerViewController)
            return nil;
        
        NSString* reuseIdentifier = [s.footerViewController reuseIdentifier];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
        
        UICollectionReusableView* view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        view.flexibleSize = YES;
        
        return (UICollectionReusableView*)[self.sectionContainer viewForController:s.footerViewController reusingView:view];

    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
    
    if([elementKind isEqualToString:UICollectionElementKindSectionHeader]){
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
    }else if([elementKind isEqualToString:UICollectionElementKindSectionFooter]){
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
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
    
    if([elementKind isEqualToString:UICollectionElementKindSectionHeader]){
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
    }else if([elementKind isEqualToString:UICollectionElementKindSectionFooter]){
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
    
}

#pragma mark Managing selection and highlight

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    return controller.flags & CKViewControllerFlagsSelectable;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    [controller didHighlight];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    [controller didUnhighlight];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    
    BOOL selectable = controller.flags & CKViewControllerFlagsSelectable;
    
    if(self.collectionView.indexPathsForSelectedItems.count == 1 && !self.multiselectionEnabled){
        NSIndexPath* selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
        //if([selectedIndexPath isEqual:indexPath]){
            [self deselectItemAtIndexPath:selectedIndexPath];
        //}
        
        selectable = NO;
    }
    
    return selectable;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected addObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    [controller didSelect];
    
    if(!self.stickySelectionEnabled){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            
            //Cause didDeselectRowAtIndexPath is not called!
            NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
            [selected removeObject:indexPath];
            self.sectionContainer.selectedIndexPaths = selected;
            [controller didDeselect];
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* controller = [cell reusableViewController];
    [controller didDeselect];
}

- (void)selectItemAtIndexPath:(NSIndexPath*)indexPath{
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally];
}

/**
 */
- (void)deselectItemAtIndexPath:(NSIndexPath*)indexPath{
    //Support for navigation push transitions:
    
    //CKReusableViewController* selectedController = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CKReusableViewController* selectedController = [cell reusableViewController];
    //------
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //Cause didDeselectRowAtIndexPath is not called!
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    [selectedController didDeselect];
}

/*
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout{
    
}
*/

- (void)invalidateControllerAtIndexPath:(NSIndexPath*)indexPath{
    if(indexPath == nil)
        return;
    
    UICollectionViewLayoutInvalidationContext* context = [[[[[self.collectionViewLayout class] invalidationContextClass] alloc]init]autorelease];
    if([CKOSVersion() floatValue] >= 8){

        if([indexPath isSectionHeaderIndexPath]){
            [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionHeader atIndexPaths:@[indexPath]];
        }else if([indexPath isSectionFooterIndexPath]){
            [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionFooter atIndexPaths:@[indexPath]];
        }else{
            [context invalidateItemsAtIndexPaths:@[indexPath]];
        }
        [self.collectionViewLayout invalidateLayoutWithContext:context];
    }else{
        [self performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark Flow Layout Management


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self controllerAtIndexPath:indexPath];

    if([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]){
        CGSize result = [controller preferredSizeConstraintToSize:CGSizeMake(self.collectionView.width,self.collectionView.height)];
        return result;
    }else{
        return controller.estimatedSize;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
        if(!s.headerViewController)
            return CGSizeZero;
        
        return [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.collectionView.width,self.collectionView.height)];
    }else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        CKAbstractSection* s = [self.sectionContainer sectionAtIndex:indexPath.section];
        if(!s.footerViewController)
            return CGSizeZero;
        
        return [s.footerViewController preferredSizeConstraintToSize:CGSizeMake(self.collectionView.width,self.collectionView.height)];
    }

    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}


#pragma mark Managing Scrolling

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrolling = YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self fetchMoreData];
    
    self.scrolling = NO;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)fetchMoreData{
    NSMutableIndexSet* sectionsIndexes = [NSMutableIndexSet indexSet];
    NSMutableDictionary* lastRowForSections = [NSMutableDictionary dictionary];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        NSInteger section = indexPath.section;
        [sectionsIndexes addIndex:indexPath.section];
        
        NSNumber* lastRow = [lastRowForSections objectForKey:@(section)];
        if(lastRow){
            if([lastRow integerValue] < indexPath.row){
                [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
            }
        }else{
            [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
        }
    }
    
    if(lastRowForSections.count == 0){
        for(CKSection* section in self.sectionContainer.sections){
            if([section isKindOfClass:[CKCollectionSection class]]){
                [sectionsIndexes addIndex:section.sectionIndex];
                [lastRowForSections setObject:@(0) forKey:@(section.sectionIndex)];
            }
        }
    }
    
    for(NSNumber* section in [lastRowForSections allKeys]){
        NSNumber* row = [lastRowForSections objectForKey:section];
        
        CKAbstractSection* abstractSection = [self sectionAtIndex:[section integerValue]];
        [abstractSection fetchNextPageFromIndex:[row integerValue]];
    }
}



/* Forwarding calls to section container
 */

- (NSInteger)indexOfSection:(CKAbstractSection*)section{
    return [self.sectionContainer indexOfSection:section];
}

- (NSIndexSet*)indexesOfSections:(NSArray*)sections{
    return [self.sectionContainer indexesOfSections:sections];
}

- (id)sectionAtIndex:(NSInteger)index{
    return [self.sectionContainer sectionAtIndex:index];
}

- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes{
    return [self.sectionContainer sectionsAtIndexes:indexes];
}

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer addSection:section animated:animated];
}

- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer insertSection:section atIndex:index animated:animated];
}

- (void)addSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer addSections:sections animated:animated];
}

- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer insertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    [self.sectionContainer removeAllSectionsAnimated:animated];
}

- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer removeSection:section animated:animated];
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer removeSectionAtIndex:index animated:animated];
}

- (void)removeSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer removeSections:sections animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer removeSectionsAtIndexes:indexes animated:animated];
}

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    return [self.sectionContainer controllerAtIndexPath:indexPath];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    return [self.sectionContainer controllersAtIndexPaths:indexPaths];
}

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller{
    return [self.sectionContainer indexPathForController:controller];
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    return [self.sectionContainer indexPathsForControllers:controllers];
}

- (void)setSelectedIndexPaths:(NSArray*)selectedIndexPaths{
    self.sectionContainer.selectedIndexPaths = selectedIndexPaths;
}

- (NSArray*)selectedIndexPaths{
    return self.sectionContainer.selectedIndexPaths;
}


@end



@implementation CKReusableViewController(CKCollectionViewController)
@dynamic collectionViewCell,collectionView;

- (UICollectionViewCell*)collectionViewCell{
    if([self.contentViewCell isKindOfClass:[UICollectionViewCell class]])
        return (UICollectionViewCell*)self.contentViewCell;
    return nil;
}

- (UICollectionView*)collectionView{
    if([self.contentView isKindOfClass:[UICollectionView class]])
        return (UICollectionView*)self.contentView;
    return nil;
}


@end