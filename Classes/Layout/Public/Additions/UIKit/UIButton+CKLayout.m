//
//  UIButton+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIButton+CKLayout.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "CKPropertyExtendedAttributes.h"
#import "CKStyleManager.h"
#import "CKRuntime.h"
#import "UIView+Name.h"
#import "CKStyleView.h"

#import "UIView+CKLayout.h"
#import "CKRuntime.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


@implementation UIButton (CKLayout)

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    
   /* if(   self.lastPreferedSize.width > 0
       && self.lastPreferedSize.height > 0
       && size.width >= self.lastComputedSize.width
       && size.height >= self.lastComputedSize.height
       && self.lastPreferedSize.width <= self.lastComputedSize.width
       && self.lastPreferedSize.height <= self.lastComputedSize.height
       && !self.flexibleWidth && !self.flexibleHeight){
        return self.lastPreferedSize;
    }
    */
    
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize ret = [self sizeThatFits:size];
    ret.width += self.titleEdgeInsets.left + self.titleEdgeInsets.right;
    
    if(self.flexibleWidth){
        ret.width = size.width;
    }
    if(self.flexibleHeight){
        ret.height = size.height;
    }
    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
    CGFloat width = MIN(size.width,ret.width) + self.padding.left + self.padding.right;
    CGFloat height = MIN(size.height,ret.height) + self.padding.top + self.padding.bottom;
    self.lastPreferedSize = CGSizeMake(ceilf(width),ceilf(height));
    return self.lastPreferedSize;
}

@end


