//
//  CKCollectionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionContainer.h"
#import "CKPassThroughView.h"

/**
 */
@interface CKReusableViewController(CKCollectionViewController)

/**
 */
@property(nonatomic,readonly) UICollectionViewCell* collectionViewCell;

@end



/**
 */
@interface CKCollectionViewController : UICollectionViewController<CKSectionContainerDelegate>

/**
 */
- (void)setCollectionViewLayout:(UICollectionViewLayout*)collectionViewLayout animated:(BOOL)animated;


/** By default, a CKPassThroughView transparent view that does catches touches. You can set your own backgroundview in viewDidLoad
 */
@property(nonatomic,retain) UIView* backgroundView;

/** By default, a CKPassThroughView transparent view that does catches touches. You can add views that must be displayed on top of the tableView here
 */
@property(nonatomic,retain) UIView* foregroundView;


/** Default is NO. If no, selected items will be deselected right after collection view formwarded a didSelect event.
 */
@property(nonatomic,assign) BOOL stickySelectionEnabled;

///-----------------------------------
/// @name Scrolling
///-----------------------------------
/**
 Returns the scrolling state of the table. Somebody can bind himself on this property to act depending on the scrolling state for example.
 */
@property (nonatomic, assign, readonly) BOOL scrolling;

/**
 */
- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated;


- (NSInteger)indexOfSection:(CKAbstractSection*)section;
- (NSIndexSet*)indexesOfSections:(NSArray*)sections;

- (id)sectionAtIndex:(NSInteger)index;
- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes;

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addSections:(NSArray*)sections animated:(BOOL)animated;
- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllSectionsAnimated:(BOOL)animated;
- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeSections:(NSArray*)sections animated:(BOOL)animated;
- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths;

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller;
- (NSArray*)indexPathsForControllers:(NSArray*)controllers;


@property(nonatomic,retain) NSArray* selectedIndexPaths;

@end
