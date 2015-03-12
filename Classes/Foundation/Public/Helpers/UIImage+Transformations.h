//
//  UIImage+Transformations.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



/**
 */
@interface UIImage (CKUIImageTransformationsAdditions)

///-----------------------------------
/// @name Transforming an Image
///-----------------------------------

/** 
 */
- (UIImage *)imageThatFits:(CGSize)size crop:(BOOL)crop;

/** 
 */
- (UIImage *)imageByAddingBorderWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

/*
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 */
- (UIImage*)imageInRect:(CGRect)rect;

/** Due to compression, the letterboxes can have slightly changing colors. Tolerance helps going through this noise.
 A tolerance of 0.2 is generally correct for white letter boxing in jpg images.
 
 Precision is the number of pixels per row that will be analysed to decide if we should remove a line. 10 for example.
 
 potentialLetterBoxingColors is a list of colors we know should be the letter box. generally white or black.
 */
- (UIImage*)imageByRemovingLetterBoxingWithColors:(NSArray*)potentialLetterBoxingColors precision:(NSInteger)precision tolerance:(CGFloat)tolerance;

/** Calling imageByRemovingLetterBoxingWithColors:precision:tolerance with default usual parameters from social media images:
 potentialLetterBoxingColors is black or white
 precision is 20
 tolerance is 0.2
 */
- (UIImage*)imageByRemovingLetterBoxing;

/**
 */
+ (UIColor *)colorAtPoint:(CGPoint)pixelPoint data:(const UInt8*) data imageSize:(CGSize)imageSize;

@end
