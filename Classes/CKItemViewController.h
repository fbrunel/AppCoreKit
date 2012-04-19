//
//  CKItemViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
#import "CKCallback.h"
#import "CKWeakRef.h"


/** TODO
 */
enum{
	CKItemViewFlagNone = 1UL << 0,
	CKItemViewFlagSelectable = 1UL << 1,
	CKItemViewFlagEditable = 1UL << 2,
	CKItemViewFlagRemovable = 1UL << 3,
	CKItemViewFlagMovable = 1UL << 4,
	CKItemViewFlagAll = CKItemViewFlagSelectable | CKItemViewFlagEditable | CKItemViewFlagRemovable | CKItemViewFlagMovable
};
typedef NSUInteger CKItemViewFlags;


@class CKItemViewContainerController;

/** TODO
 */
@interface CKItemViewController : NSObject


///-----------------------------------
/// @name Identifying the Controller at runtime
///-----------------------------------

@property (nonatomic, retain) NSString *name;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;

- (NSString*)identifier;

///-----------------------------------
/// @name Managing Content
///-----------------------------------

@property (nonatomic, assign, readonly) CKItemViewContainerController* containerController;
@property (nonatomic, retain) id value;
@property (nonatomic, assign) UIView *view;

///-----------------------------------
/// @name Customizing the Controller Interactions And Visual Appearance
///-----------------------------------

@property (nonatomic, assign) CKItemViewFlags flags;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, retain) CKCallback* createCallback;
@property (nonatomic, retain) CKCallback* initCallback;
@property (nonatomic, retain) CKCallback* setupCallback;
@property (nonatomic, retain) CKCallback* selectionCallback;
@property (nonatomic, retain) CKCallback* accessorySelectionCallback;
@property (nonatomic, retain) CKCallback* becomeFirstResponderCallback;
@property (nonatomic, retain) CKCallback* resignFirstResponderCallback;
@property (nonatomic, retain) CKCallback* viewDidAppearCallback;
@property (nonatomic, retain) CKCallback* viewDidDisappearCallback;
@property (nonatomic, retain) CKCallback* layoutCallback;


///-----------------------------------
/// @name Responding to ContainerController Events
///-----------------------------------

- (void)viewDidAppear:(UIView *)view;
- (void)viewDidDisappear;

- (UIView *)loadView;
- (void)initView:(UIView*)view;
- (void)setupView:(UIView *)view;
- (void)rotateView:(UIView*)view animated:(BOOL)animated;

- (NSIndexPath *)willSelect;
- (void)didSelect;
- (void)didSelectAccessoryView;

- (void)didBecomeFirstResponder;
- (void)didResignFirstResponder;


///-----------------------------------
/// @name Managing Stylesheets
///-----------------------------------

- (void)applyStyle;

///-----------------------------------
/// @name Initializing a Controller
///-----------------------------------

- (void)postInit;
- (void)invalidateSize;
- (void)setSize:(CGSize)size notifyingContainerForUpdate:(BOOL)notifyingContainerForUpdate;

@end
