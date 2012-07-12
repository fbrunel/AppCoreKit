//
//  CKTableViewCellCache.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKTableViewCellCache : NSObject

- (UIView*)reusableViewWithIdentifier:(NSString*)identifier;
- (void)setReusableView:(UIView*)view forIdentifier:(NSString*)identifier;

@end
