//
//  CKTableViewCellController+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"
#import "CKTableViewControllerOld.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"


/**
 */
extern NSString* CKStyleCellStyle;

/**
 */
extern NSString* CKStyleAccessoryImage;




/**
 */
@interface NSMutableDictionary (CKTableViewCellControllerStyle)

- (CKTableViewCellStyle)cellStyle;
- (UIImage*)accessoryImage;

@end


/**
 */
@interface CKTableViewCellController (CKStyle)

- (CKStyleViewCornerType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style;

@end

/**
 */
@interface CKTableViewControllerOld (CKStyle)
@end


/**
 */
@interface CKCollectionCellController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forView:(UIView*)view;
- (NSMutableDictionary*)controllerStyle;
- (UIView*)parentControllerView;

@end


/**
 */
@interface UITableView (CKStyle)
@end