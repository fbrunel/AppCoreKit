//
//  CKNSStringMultilinePropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKTextView.h"


/**
 */
@interface CKMultilineNSStringPropertyCellController : CKPropertyGridCellController<UITextViewDelegate>

///-----------------------------------
/// @name Getting the Controls
///-----------------------------------

/** textView is a weak reference to the view currently associated to this controller.
 As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
 Do not keep any other reference between the textView and the controller to avoid problem with the reuse system.
 */
@property(nonatomic,retain,readonly)CKTextView* textView;

@end