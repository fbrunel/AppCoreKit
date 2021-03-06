//
//  UIButton+FlatDesign.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-30.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BackgroundColor)
@property(nonatomic,retain) UIColor* defaultBackgroundColor;
@property(nonatomic,retain) UIColor* highlightedBackgroundColor;
@property(nonatomic,retain) UIColor* disabledBackgroundColor;
@property(nonatomic,retain) UIColor* selectedBackgroundColor;

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

@end



@interface UIButton (Fonts)
@property(nonatomic,retain) UIFont* defaultFont;
@property(nonatomic,retain) UIFont* highlightedFont;
@property(nonatomic,retain) UIFont* disabledFont;
@property(nonatomic,retain) UIFont* selectedFont;

- (void)setFont:(UIFont *)font forState:(UIControlState)state;
- (UIFont *)fontForState:(UIControlState)state;

@end



@interface UIButton (BorderColor)
@property(nonatomic,retain) UIColor* defaultBorderColor;
@property(nonatomic,retain) UIColor* highlightedBorderColor;
@property(nonatomic,retain) UIColor* disabledBorderColor;
@property(nonatomic,retain) UIColor* selectedBorderColor;

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)borderColorForState:(UIControlState)state;

@end