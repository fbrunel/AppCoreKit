//
//  CKStyleView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleView.h"
#import "UIColor+Additions.h"
#import "UIImage+Transformations.h"
#import "NSArray+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import <QuartzCore/QuartzCore.h>

@interface CKStyleView () 
//@property(nonatomic,retain)CKStyleViewUpdater* updater;
@property(nonatomic,retain)UIColor* fillColor;
@property(nonatomic,assign)CGRect drawFrame;
@property(nonatomic,assign)CGRect originalFrame;
@end



@implementation CKStyleView{
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
	UIViewContentMode _imageContentMode;
    
	NSInteger _borderLocation;
	UIColor* _borderColor;
	CGFloat _borderWidth;
    
	NSInteger _separatorLocation;
	UIColor* _separatorColor;
	CGFloat _separatorWidth;
	
	//CKStyleViewUpdater* _updater;
	
	UIColor* _fillColor;
	UIColor *_embossTopColor;
	UIColor *_embossBottomColor;
}

@synthesize gradientColors = _gradientColors;
@synthesize gradientColorLocations = _gradientColorLocations;
@synthesize image = _image;
@synthesize borderLocation = _borderLocation;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize separatorLocation = _separatorLocation;
@synthesize separatorColor = _separatorColor;
@synthesize separatorWidth = _separatorWidth;
//@synthesize updater = _updater;
@synthesize fillColor = _fillColor;
@synthesize imageContentMode = _imageContentMode;
@synthesize embossTopColor = _embossTopColor;
@synthesize embossBottomColor = _embossBottomColor;
@synthesize corners = _corners;
@synthesize roundedCornerSize = _roundedCornerSize;

@synthesize borderShadowColor = _borderShadowColor;
@synthesize borderShadowRadius = _borderShadowRadius;
@synthesize borderShadowOffset = _borderShadowOffset;
@synthesize gradientStyle;
@synthesize drawFrame,originalFrame;

- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderLocation = CKStyleViewBorderLocationNone;
    
	self.separatorColor = [UIColor clearColor];
	self.separatorWidth = 1;
	self.separatorLocation = CKStyleViewSeparatorLocationNone;
    
//	self.updater = [[[CKStyleViewUpdater alloc]initWithView:self]autorelease];
	self.fillColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
   // self.contentMode = UIViewContentModeTopLeft;
    self.clipsToBounds = 0;
    self.userInteractionEnabled = NO;
    
    _borderShadowRadius = 2;
    _borderShadowOffset = CGSizeMake(0,0);
    
    self.gradientStyle = CKStyleViewGradientStyleVertical;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.drawFrame = CGRectMake(0,0,0,0);
    self.separatorInsets = UIEdgeInsetsMake(0,0,0,0);
    
    self.separatorDashPhase = 0;
    self.separatorDashLengths = nil;
    self.separatorLineCap = kCGLineCapButt;
    self.separatorLineJoin = kCGLineJoinMiter;
}

- (void)imageContentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIViewContentMode",
                                                    UIViewContentModeScaleToFill,
                                                    UIViewContentModeScaleAspectFit,      
                                                    UIViewContentModeScaleAspectFill,    
                                                    UIViewContentModeRedraw,              
                                                    UIViewContentModeCenter,             
                                                    UIViewContentModeTop,
                                                    UIViewContentModeBottom,
                                                    UIViewContentModeLeft,
                                                    UIViewContentModeRight,
                                                    UIViewContentModeTopLeft,
                                                    UIViewContentModeTopRight,
                                                    UIViewContentModeBottomLeft,
                                                    UIViewContentModeBottomRight);
}


- (void)borderLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewBorderLocation",
                                                    CKStyleViewBorderLocationNone,
                                                    CKStyleViewBorderLocationTop,
                                                    CKStyleViewBorderLocationBottom,
                                                    CKStyleViewBorderLocationRight,
                                                    CKStyleViewBorderLocationLeft,
                                                    CKStyleViewBorderLocationAll);
}

- (void)separatorLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewSeparatorLocation",
                                                    CKStyleViewSeparatorLocationNone,
                                                    CKStyleViewSeparatorLocationTop,
                                                    CKStyleViewSeparatorLocationBottom,
                                                    CKStyleViewSeparatorLocationRight,
                                                    CKStyleViewSeparatorLocationLeft,
                                                    CKStyleViewSeparatorLocationAll);
}

- (void)gradientStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewGradientStyle",
                                                    CKStyleViewGradientStyleVertical,
                                                    CKStyleViewGradientStyleHorizontal);
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self postInit];
	}
	return self;
}
- (void)dealloc {
    //	[_updater release]; _updater = nil;
	[_image release]; _image = nil;
	[_gradientColors release]; _gradientColors = nil;
	[_gradientColorLocations release]; _gradientColorLocations = nil;
	[_borderColor release]; _borderColor = nil;
	[_separatorColor release]; _separatorColor = nil;
	[_fillColor release]; _fillColor = nil;
	[_embossTopColor release]; _embossTopColor = nil;
	[_embossBottomColor release]; _embossBottomColor = nil;
    [_borderShadowColor release]; _borderShadowColor = nil;
	[super dealloc];
}

- (void)updateDisplay{
    self.frame = self.originalFrame;
    [self setNeedsDisplay];
}

//HACK to control how to paint using the background color !
- (void)setBackgroundColor:(UIColor *)color{
    //self.gradientColors = nil;
    
	self.fillColor = color;
    CGFloat alpha = CGColorGetAlpha([color CGColor]);
    if(self.corners == CKStyleViewCornerTypeNone && alpha >= 1){
        [super setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [super setBackgroundColor:[UIColor clearColor]];
    }
    [self updateDisplay];
}

- (UIColor*)backgroundColor{
    return (self.gradientColors == nil) ? self.fillColor : [UIColor clearColor];
}

- (void)setImage:(UIImage *)anImage {
    if (anImage != _image) {
        [_image release];
        _image = [anImage retain];
        
        self.opaque = YES;
        //self.backgroundColor = [UIColor blackColor];
        [self updateDisplay];
    }
}

- (void)setCorners:(CKStyleViewCornerType)newCorners{
    if(_corners != newCorners){
        _corners = newCorners;
        
        CGFloat alpha = CGColorGetAlpha([_fillColor CGColor]);
        if(newCorners == CKStyleViewCornerTypeNone && alpha >= 1){
            //TODO : if no shadow set opaque color
            //[super setBackgroundColor:[UIColor blackColor]];
            self.opaque = YES;
        }
        else{
            [super setBackgroundColor:[UIColor clearColor]];
            self.opaque = NO;
        }
        [self updateDisplay];
    }
}

- (void)setBorderLocation:(NSInteger)theborderLocation{
    if(_borderLocation != theborderLocation){
        _borderLocation = theborderLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorLocation:(NSInteger)theseparatorLocation{
    if(_separatorLocation != theseparatorLocation){
        _separatorLocation = theseparatorLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorInsets:(UIEdgeInsets)theSeparatorInsets{
    if(!UIEdgeInsetsEqualToEdgeInsets(_separatorInsets, theSeparatorInsets)){
        _separatorInsets = theSeparatorInsets;
        [self updateDisplay];
    }
}

- (void)setBorderWidth:(CGFloat)width {
    if(width != _borderWidth){
        _borderWidth = width;
        [self updateDisplay];
    }
}


#pragma mark - Emboss Paths

- (void)generateTopEmbossPath:(CGMutablePathRef)path  inRect:(CGRect)rect{
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKStyleViewCornerTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKStyleViewCornerTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKStyleViewCornerTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
    
    CGFloat offset = 0;
    
	if (self.borderLocation & CKStyleViewBorderLocationTop && self.borderColor && (self.borderColor != [UIColor clearColor])) {
        offset = self.borderWidth;
    }
    if (self.separatorLocation & CKStyleViewSeparatorLocationTop && self.separatorColor && (self.separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,self.separatorWidth);
    }
    
    offset /= 2;
	
	CGFloat x = rect.origin.x +  offset;
	CGFloat y = rect.origin.y + (2 * offset) ;
	CGFloat width = rect.size.width - (2 * (offset));
	CGFloat radius = self.roundedCornerSize + (0 * offset)/* - offset + 3*/;
	
    
    CGPoint startLinePoint = CGPointMake(x, y + ((roundedCorners & UIRectCornerTopLeft) ? radius : 0));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : x + width, y);
    
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
	if(roundedCorners & UIRectCornerTopLeft){
        CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
	}
	CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
	if(roundedCorners & UIRectCornerTopRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y + radius,radius, 3 * (M_PI / 2.0), 0,NO);
	}
}

- (void)generateBottomEmbossPath:(CGMutablePathRef)path  inRect:(CGRect)rect{
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKStyleViewCornerTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKStyleViewCornerTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKStyleViewCornerTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
    
    CGFloat offset = 0;
    
	if (self.borderLocation & CKStyleViewBorderLocationBottom && self.borderColor && (self.borderColor != [UIColor clearColor])) {
        offset = self.borderWidth;
    }
    if (self.separatorLocation & CKStyleViewSeparatorLocationBottom && self.separatorColor && (self.separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,self.separatorWidth);
    }
    
    offset /= 2;
	
	CGFloat x = rect.origin.x +  offset;
	CGFloat y = rect.origin.y + rect.size.height - (2 * offset);
	CGFloat width = rect.size.width - (2 * (offset));
	CGFloat radius = self.roundedCornerSize + (0 * offset) /* - offset + 3*/;
    
    
    CGPoint startLinePoint = CGPointMake(x, ((roundedCorners & UIRectCornerBottomLeft) ? y - radius : y));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y);
	
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
	if(roundedCorners & UIRectCornerBottomLeft){
        CGPathAddArc(path, nil,startLinePoint.x + radius,startLinePoint.y,radius, -M_PI,  M_PI / 2,YES);
	}
	CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
	if(roundedCorners & UIRectCornerBottomRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y - radius,radius, M_PI / 2.0, 0,YES);
	}
}

#pragma mark - Border Path

- (void)generateBorderPath:(CGMutablePathRef)path withStyle:(CKStyleViewBorderLocation)borderStyle width:(CGFloat)borderWidth inRect:(CGRect)rect{
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKStyleViewCornerTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKStyleViewCornerTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKStyleViewCornerTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
	
    CGFloat halfBorder = (borderWidth / 2.0);
    
    CGFloat x = rect.origin.x + halfBorder; 
    CGFloat y = rect.origin.y + halfBorder; 
    
	CGFloat width = rect.size.width - (2*halfBorder);
	CGFloat height = rect.size.height - (2*halfBorder);
    
    if(!(borderStyle & CKStyleViewBorderLocationTop)){
        y -= halfBorder;
        height += halfBorder;
    }
    
    if(!(borderStyle & CKStyleViewBorderLocationBottom)){
        height += halfBorder;
    }
    
    if(!(borderStyle & CKStyleViewBorderLocationLeft)){
        x -= halfBorder;
        width += halfBorder;
    }
    
    if(!(borderStyle & CKStyleViewBorderLocationRight)){
        width += halfBorder;
    }
    
	CGFloat radius = (roundedCorners != 0 && self.roundedCornerSize > 0) ? (self.roundedCornerSize - halfBorder) : 0;
	
    BOOL shouldMove = YES;
	if(borderStyle & CKStyleViewBorderLocationLeft){
		//draw arc from bottom to left or move to bottom left
		if((roundedCorners & UIRectCornerBottomLeft) && (borderStyle & CKStyleViewBorderLocationBottom)){
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + radius, y + height);
                shouldMove = NO;
            }
            CGPathAddArc(path, nil,x + radius,y + height-radius,radius, M_PI / 2,  M_PI ,NO);
		}
		else{
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x, (roundedCorners & UIRectCornerBottomLeft) ? (y + height - radius) : (y + height));
                shouldMove = NO;
            }
		}
		
		//draw left line
		CGPathAddLineToPoint (path, nil, x, (roundedCorners & UIRectCornerTopLeft) ? y + radius : y);
		
		//draw arc from left to top
		if((roundedCorners & UIRectCornerTopLeft) && (borderStyle & CKStyleViewBorderLocationTop)){
            CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
			//CGPathAddArcToPoint (path, nil, 0, 0, radius, 0, radius);
		}
	}
	
	//draw top
	if(borderStyle & CKStyleViewBorderLocationTop){
        if(shouldMove){
            CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerTopLeft) ? x + radius : x, y);
            shouldMove = NO;
        }
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : (x + width), y);
	} else shouldMove = YES;
	
	//draw right
	if(borderStyle & CKStyleViewBorderLocationRight){
		//draw arc from top to right or move to top right
		if((roundedCorners & UIRectCornerTopRight) && (borderStyle & CKStyleViewBorderLocationTop)){
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + width - radius, y);
                shouldMove = NO;
            }
            CGPathAddArc(path, nil,x + width- radius,y + radius,radius, 3 * (M_PI / 2.0),0  ,NO);
			//CGPathAddArcToPoint (path, nil, width, 0, width, radius, radius);
		}
		else{
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + width, (roundedCorners & UIRectCornerTopRight) ? y + radius : y);
                shouldMove = NO;
            }
		}
		
		//draw right line
		CGPathAddLineToPoint (path, nil, x + width, (roundedCorners & UIRectCornerBottomRight) ? (y + height - radius) : (y + height));
		
		//draw arc from right to bottom
		if((roundedCorners & UIRectCornerBottomRight) && (borderStyle & CKStyleViewBorderLocationBottom)){
            CGPathAddArc(path, nil,x + width - radius,y + height - radius,radius, 0,  M_PI / 2.0,NO);
			//CGPathAddArcToPoint (path, nil, width, height, width - radius, height, radius);
		}
	} else shouldMove = YES;
	
	//draw bottom
	if(borderStyle & CKStyleViewBorderLocationBottom){
        if(shouldMove){
            CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y + height);
            shouldMove = NO;
        }
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerBottomLeft) ? x + radius : x, y + height);
	}
}



- (void)setFrame:(CGRect)frame{
    self.originalFrame = frame;
    
    CGSize oldSize = self.frame.size;
    if(_borderShadowColor!= nil && _borderShadowColor != [UIColor clearColor] && _borderShadowRadius > 0){
        //Shadow
        
        UIRectCorner roundedCorners = UIRectCornerAllCorners;
        switch (self.corners) {
            case CKStyleViewCornerTypeTop:
                roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
                break;
            case CKStyleViewCornerTypeBottom:
                roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
                break;
                
            default:
                break;
        }
        
        CGFloat multiplier = 2;
        CGRect shadowFrame = frame;
        CGPoint offset = CGPointMake(0,0);
        
        if(_borderLocation & CKStyleViewBorderLocationLeft){
            offset.x += multiplier * self.borderShadowRadius;
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
            
        }
        if(_borderLocation & CKStyleViewBorderLocationRight){
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
        }
        if(_borderLocation & CKStyleViewBorderLocationTop){
            offset.y += multiplier * self.borderShadowRadius;
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        if(_borderLocation & CKStyleViewBorderLocationBottom){
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationBottom && self.borderShadowOffset.height > 0){
            shadowFrame.size.height += self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationTop && self.borderShadowOffset.height < 0){
            offset.y -= self.borderShadowOffset.height;
            shadowFrame.size.height += -self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationRight && self.borderShadowOffset.width > 0){
            shadowFrame.size.width += self.borderShadowOffset.width;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft && self.borderShadowOffset.width < 0){
            offset.x -= self.borderShadowOffset.width;
            shadowFrame.size.width += -self.borderShadowOffset.width;
        }
        
        shadowFrame.origin.x -= offset.x;
        shadowFrame.origin.y -= offset.y;
        [super setFrame:shadowFrame];
        
        if( !CGSizeEqualToSize(shadowFrame.size, oldSize) ){
            self.drawFrame = CGRectMake(offset.x,offset.y,frame.size.width,frame.size.height);
            [self setNeedsDisplay];
        }
    }else{
        //Draw normally
        [super setFrame:frame];
        if( !CGSizeEqualToSize(frame.size, oldSize) ){
            self.drawFrame = CGRectMake(0,0,frame.size.width,frame.size.height);
            [self setNeedsDisplay];
        }
    }
}

- (void)drawRect:(CGRect)rect{
    //UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    [self drawInRect:self.drawFrame inContext:gc];
    
    //UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    
    //self.layer.contents = (id)[resultingImage CGImage];
    //self.contentMode = UIViewContentModeScaleToFill;
}


- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)gc {
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKStyleViewCornerTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKStyleViewCornerTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
			
		default:
			break;
	}
    
    
    // Shadow
	if(_borderColor!= nil && _borderColor != [UIColor clearColor] && _borderWidth > 0 && _borderLocation != CKStyleViewBorderLocationNone){
		CGContextSaveGState(gc);
        
        if(_borderShadowColor!= nil && _borderShadowColor != [UIColor clearColor] && _borderShadowRadius > 0){
            CGContextSetShadowWithColor(gc, self.borderShadowOffset, self.borderShadowRadius, self.borderShadowColor.CGColor);
            
            CGRect shadowRect = rect;
            if(!(self.borderLocation & CKStyleViewBorderLocationTop)){
                shadowRect.origin.y -= self.borderShadowRadius;
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom)){
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft)){
                shadowRect.origin.x -= self.borderShadowRadius;
                shadowRect.size.width += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationRight)){
                shadowRect.size.width += self.borderShadowRadius;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom) && self.borderShadowOffset.height < 0){
                shadowRect.size.height -= self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationTop) && self.borderShadowOffset.height > 0){
                shadowRect.origin.y -= self.borderShadowOffset.height;
                shadowRect.size.height += self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationRight) && self.borderShadowOffset.width < 0){
                shadowRect.size.width -= self.borderShadowOffset.width;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft) && self.borderShadowOffset.width > 0){
                shadowRect.origin.x -= self.borderShadowOffset.width;
                shadowRect.size.width += self.borderShadowOffset.width;
            }
                    
            if (self.corners != CKStyleViewCornerTypeNone){
                //TODO inset the rect to have shadow till the limits of the image !
                CGMutablePathRef shadowPath = CGPathCreateMutable();
                if (self.corners != CKStyleViewCornerTypeNone) {
                    [self generateBorderPath:shadowPath withStyle:CKStyleViewBorderLocationAll width:0 inRect:shadowRect];
                }
                
                [_borderColor setFill];
                CGContextAddPath(gc, shadowPath);
                CGContextFillPath(gc);
                CFRelease(shadowPath);
            }else{
                
                //TODO inset the rect to have shadow till the limits of the image !
                [_borderColor setFill];
                CGContextFillRect(gc, shadowRect);
            }
            
        }
        
		CGContextRestoreGState(gc);
	}
    
    CGMutablePathRef clippingPath = CGPathCreateMutable();;
    //if (self.corners != CKStyleViewCornerTypeNone) {
		[self generateBorderPath:clippingPath withStyle:CKStyleViewBorderLocationAll width:0 inRect:rect];
	//}
	
	if(self.gradientColors == nil && self.image == nil){
		if(self.fillColor != nil)
			[self.fillColor setFill];
		else
			[[UIColor clearColor] setFill];
        
        if (self.corners != CKStyleViewCornerTypeNone){
            CGContextAddPath(gc, clippingPath);
            CGContextFillPath(gc);
        }
        else{
            CGContextFillRect(gc, rect);
        }
	}
	
	
	if(_image){
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
            CGContextClip(gc);
		}
		
		//self.imageContentMode
		//[_image drawInRect:rect];
		
		BOOL clip = NO;
		CGRect originalRect = rect;
		if (_image.size.width != rect.size.width || _image.size.height != rect.size.height) {
			if (_imageContentMode == UIViewContentModeLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeTop) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeBottom) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeCenter) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
                clip = NO;
			} else if (_imageContentMode == UIViewContentModeBottomLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeBottomRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + (rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeTopLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeTopRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = NO;
			} else if (_imageContentMode == UIViewContentModeScaleAspectFill) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				} else {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
                clip = YES;
			} else if (_imageContentMode == UIViewContentModeScaleAspectFit) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				} else {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
                clip = YES;
			}
		}
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		if (clip) {
			CGContextSaveGState(context);
			CGContextAddRect(context, originalRect);
			CGContextClip(context);
		}
		
		[_image drawInRect:rect];
		
		if (clip) {
			CGContextRestoreGState(context);
		}
	}	
	
	// Gradient
	if(self.gradientColors){
		CGContextSaveGState(gc);
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
            CGContextClip(gc);
		}
		
		CGFloat colorLocations[self.gradientColorLocations.count];
		int i = 0;
		for (NSNumber *n in self.gradientColorLocations) {
			colorLocations[i++] = [n floatValue];
		}
		
		NSMutableArray *colors = [NSMutableArray array];
		for (UIColor *color in self.gradientColors) {
			[colors addObject:(id)([[color RGBColor]CGColor])];
		}
        
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, colorLocations);
		CFRelease(colorSpace);
        switch(self.gradientStyle){
            case CKStyleViewGradientStyleVertical:
                CGContextDrawLinearGradient(gc, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
                break;
            case CKStyleViewGradientStyleHorizontal:
                CGContextDrawLinearGradient(gc, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y), 0);
                break;
        }
        //CGContextDrawRadialGradient
        
		CGGradientRelease(gradient);
		CGContextRestoreGState(gc);
	}
	
	// Top Emboss
	if (_embossTopColor && (_embossTopColor != [UIColor clearColor])) {
		CGContextSaveGState(gc);
        
		CGContextSetShadowWithColor(gc, CGSizeMake(0, 1), 0, _embossTopColor.CGColor);
		CGMutablePathRef topEmbossPath = CGPathCreateMutable();
		[self generateTopEmbossPath:topEmbossPath inRect:rect];
		CGContextAddPath(gc, topEmbossPath);
        
        [[UIColor clearColor]setStroke];
		CGContextSetLineWidth(gc, 1);
        //UIColor* thecolor = [self.gradientColors count] > 0 ? [self.gradientColors objectAtIndex:0] : self.fillColor;
        //UIColor*thecolor = self.borderColor;
        //thecolor = [thecolor colorWithAlphaComponent:1];
        
        UIColor*thecolor = _embossTopColor;
		[thecolor setStroke];
        
		CGContextStrokePath(gc);
		CFRelease(topEmbossPath);
		CGContextRestoreGState(gc);
	}
	
	// Bottom Emboss
	if (_embossBottomColor && (_embossBottomColor != [UIColor clearColor])) {
		CGContextSaveGState(gc);
        
		CGContextSetShadowWithColor(gc, CGSizeMake(0, -1), 0, _embossBottomColor.CGColor);
		CGMutablePathRef bottomEmbossPath = CGPathCreateMutable();
		[self generateBottomEmbossPath:bottomEmbossPath inRect:rect];
		CGContextAddPath(gc, bottomEmbossPath);
        
		CGContextSetLineWidth(gc, 1);
        [[UIColor clearColor]setStroke];
        
        //perhaps use the border color here
        //UIColor*thecolor = [self.gradientColors count] > 0 ? [self.gradientColors last] : self.fillColor;
        //UIColor*thecolor = self.borderColor;
        //thecolor = [thecolor colorWithAlphaComponent:1];
        
        UIColor*thecolor = _embossBottomColor;
		[thecolor setStroke];
        
		CGContextStrokePath(gc);
		CFRelease(bottomEmbossPath);
		CGContextRestoreGState(gc);
	}
    
    
    // Separator
	if(_separatorColor!= nil && _separatorColor != [UIColor clearColor] && _separatorWidth > 0 && _separatorLocation != CKStyleViewSeparatorLocationNone){
        CGContextSaveGState(gc);
		[_separatorColor setStroke];
		CGContextSetLineWidth(gc, self.separatorWidth);
		CGMutablePathRef borderPath = CGPathCreateMutable();
        
        CGRect separatorRect = CGRectMake(rect.origin.x + self.separatorInsets.left,
                                          rect.origin.y + self.separatorInsets.top,
                                          rect.size.width - (self.separatorInsets.left + self.separatorInsets.right),
                                          rect.size.height - (self.separatorInsets.top + self.separatorInsets.bottom));
        
		[self generateBorderPath:borderPath withStyle:(CKStyleViewBorderLocation)_separatorLocation  width:_separatorWidth inRect:separatorRect];
        
		CGContextAddPath(gc, borderPath);
        
        if(self.separatorDashLengths){
            CGFloat lengths[self.separatorDashLengths.count];
            int i =0;
            for(NSNumber* n in self.separatorDashLengths){
                lengths[i] = [[self.separatorDashLengths objectAtIndex:i]floatValue];
                ++i;
            }
            CGContextSetLineDash(gc, self.separatorDashPhase,lengths , [self.separatorDashLengths count]);
        }
        
        CGContextSetLineCap(gc,self.separatorLineCap);
        CGContextSetLineJoin(gc, self.separatorLineJoin);
        
		CFRelease(borderPath);
		CGContextStrokePath(gc);
		CGContextRestoreGState(gc);
	}
	
	// Border
	if(_borderColor!= nil && _borderColor != [UIColor clearColor] && _borderWidth > 0 && _borderLocation != CKStyleViewBorderLocationNone){
		CGContextSaveGState(gc);
        
		CGContextSetLineWidth(gc, self.borderWidth);
		CGMutablePathRef borderPath = CGPathCreateMutable();
		[self generateBorderPath:borderPath withStyle:_borderLocation width:_borderWidth inRect:rect];
        
		[_borderColor setStroke];
		CGContextAddPath(gc, borderPath);
		CGContextStrokePath(gc);
        
		CFRelease(borderPath);
		CGContextRestoreGState(gc);
	}
    
    CFRelease(clippingPath);
}

- (void)separatorDashLengthsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [NSNumber class];
}

- (void)separatorLineCapExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineCap",
                                                 kCGLineCapButt,
                                                 kCGLineCapRound,
                                                 kCGLineCapSquare);
}

- (void)separatorLineJoinExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineJoin",
                                                 kCGLineJoinMiter,
                                                 kCGLineJoinRound,
                                                 kCGLineJoinBevel);
}



@end
