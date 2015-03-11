//
//  CKImageView.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageView.h"
#import "UIImage+Transformations.h"
#import <QuartzCore/QuartzCore.h>
#import "NSValueTransformer+Additions.h"
#import "CKDebug.h"
#import "NSObject+Bindings.h"

@interface CKImageView ()

@property (nonatomic, retain, readwrite) CKImageLoader *imageLoader;
@property (nonatomic, retain, readwrite) UIImageView *imageView;
@property (nonatomic, retain, readwrite) UIButton *button;
@property (nonatomic, retain, readwrite) UIView *defaultImageView;
@property (nonatomic, retain, readwrite) UIActivityIndicatorView *activityIndicator;

- (void)updateViews:(BOOL)animated;

@end

//

@implementation CKImageView{
	//Image Management
	CKImageLoader *_imageLoader;
	NSURL *_imageURL;
	id<CKImageViewDelegate> _delegate;
	
	//Background View Management
	UIImage *_defaultImage;	
	UIView* _defaultImageView;
	UIActivityIndicatorView* _activityIndicator;
	CKImageViewSpinnerStyle _spinnerStyle;
	
	//View Management
	UIImageView* _imageView;
	BOOL _interactive;
	
	NSTimeInterval _fadeInDuration;
	CKImageViewState _currentState;
}

@synthesize imageLoader = _imageLoader;
@synthesize imageURL = _imageURL;
@synthesize defaultImage = _defaultImage;
@synthesize delegate = _delegate;
@synthesize imageView = _imageView;
@synthesize fadeInDuration = _fadeInDuration;
@synthesize interactive = _interactive;
@synthesize button = _button;
@synthesize defaultImageView = _defaultImageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize spinnerStyle = _spinnerStyle;


- (void)postInit{
	self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds]autorelease];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	
	self.fadeInDuration = 0.4;
	self.interactive = NO;
    self.animateLoadingOfImagesLoadedFromCache = NO;
	_currentState = CKImageViewStateNone;
	_spinnerStyle = CKImageViewSpinnerStyleNone;
}

- (id)initWithCoder:(NSCoder *)decoder{
	if (self = [super initWithCoder:decoder]) {
  
	[self postInit];
    }
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self postInit];
    return self;
}

- (void)dealloc {
	[self cancel];
	[_imageURL release];
	_imageURL = nil;
	[_activityIndicator release];
	_activityIndicator = nil;
	[_defaultImageView release];
	_defaultImageView = nil;
    [_postProcess release];
    _postProcess = nil;
	self.defaultImage = nil;
	self.delegate = nil;
	self.imageView = nil;
	self.button = nil;
	[super dealloc];
}


#pragma mark Public API

- (void)setImage:(UIImage*)image updateViews:(BOOL)updateViews animated:(BOOL)animated{
	if(self.imageView.image == image)
		return;
	
	self.imageView.image = image;
    if(image != nil){
        [_defaultImage release];
        _defaultImage = [image retain];
    }
    if(self.button){
        [self.button setBackgroundImage:image forState:UIControlStateNormal];
    }
    
	if(updateViews){
		[self updateViews:animated];
	}
}

- (void)setInteractive:(BOOL)bo{
	_interactive = bo;
    if(_interactive){
        if(!self.button){
            self.button = [UIButton buttonWithType:UIButtonTypeCustom];
            self.button.frame = self.bounds;
            self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.button.contentMode = self.imageView.contentMode;
            self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
            self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
            [self.button setBackgroundImage:self.imageView.image forState:UIControlStateNormal];
        }
    }
	[self updateViews:NO];
}

- (void)setImageURL:(NSURL *)url {
	[self loadImageWithContentOfURL:url];
}

- (void)loadImageWithContentOfURL:(NSURL *)url {
	if ([self.imageURL isEqual:url])
		return;
	
	[_imageURL release];
	_imageURL = [url retain];
	[self reload];
}

- (void)reload {
	[self reset];
	
	if(self.imageURL){
		self.imageLoader = [[[CKImageLoader alloc] initWithDelegate:self] autorelease];
        self.imageLoader.postProcess = self.postProcess;
		[self updateViews:YES];
		[self.imageLoader loadImageWithContentOfURL:self.imageURL];
	}
}

- (void)reset {
	[self setImage:nil updateViews:NO animated:NO];//will get updated in cancel
	[self cancel];
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
	[self updateViews:NO];
}

- (UIImage *)image {
	return self.imageView.image;
}

- (void)setDefaultImage:(UIImage *)image {
	[_defaultImage release];
	_defaultImage = [image retain];
	[self updateViews:YES];
}

- (void)setImageViewContentMode:(UIViewContentMode)theContentMode {
	self.imageView.contentMode = theContentMode;
    if(self.button){
        self.imageView.contentMode = theContentMode;
    }
    
    if([self.defaultImageView isKindOfClass:[UIImageView class]]){
        self.defaultImageView.contentMode = theContentMode;
    }
    else if([self.defaultImageView isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)self.defaultImageView ;
        bu.imageView.contentMode = theContentMode;
    }
}

- (UIViewContentMode)imageViewContentMode {
	return self.imageView.contentMode;
}

- (void)imageViewContentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"contentMode",
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

#pragma mark CKWebRequestDelegate Protocol

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached {
	[self setImage:image updateViews:YES animated:(self.animateLoadingOfImagesLoadedFromCache || !cached)];
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
	[self updateViews:YES];
    CKDebugLog(@"CKImageView ERROR : Could not fetch image with URL : %@",self.imageURL);
}

#pragma mark Views management

- (void)setSpinnerStyle:(CKImageViewSpinnerStyle)style{
	_spinnerStyle = style;
	if(self.activityIndicator){
		[self.activityIndicator removeFromSuperview];
	}
	self.activityIndicator = (style != CKImageViewSpinnerStyleNone) ? 
				[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)_spinnerStyle] autorelease]
    : nil;
	[self updateViews:NO];
}

- (void)createsDefaultImageView{
    if(self.interactive && self.defaultImageView && ![self.defaultImageView isKindOfClass:[UIButton class]]){
        [self.defaultImageView removeFromSuperview];
        self.defaultImageView = nil;
    }
    else if(!self.interactive && self.defaultImageView && [self.defaultImageView isKindOfClass:[UIButton class]]){
        [self.defaultImageView removeFromSuperview];
        self.defaultImageView = nil;
    }
    
    if(!self.defaultImageView){
        if(self.interactive){
            self.defaultImageView = [UIButton buttonWithType:UIButtonTypeCustom];
            self.defaultImageView.frame = self.bounds;
        }
        else{
            self.defaultImageView = [[[UIImageView alloc] initWithFrame:self.bounds]autorelease];
        }
        self.defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if([self.defaultImageView isKindOfClass:[UIImageView class]]){
            self.defaultImageView.contentMode = self.imageView.contentMode;
        }
        else if([self.defaultImageView isKindOfClass:[UIButton class]]){
            UIButton* bu = (UIButton*)self.defaultImageView;
            bu.imageView.contentMode = self.imageView.contentMode;
        }
    }
    
    if([self.defaultImageView isKindOfClass:[UIImageView class]]){
        UIImageView* imageView = (UIImageView*)self.defaultImageView;
        imageView.image = self.defaultImage;
    }
    else if([self.defaultImageView isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)self.defaultImageView;
        [bu setBackgroundImage:self.defaultImage forState:UIControlStateNormal];
    }
    [self addSubview:self.defaultImageView];

}

- (void)updateViews:(BOOL)animated{
	UIImage* image = [self image];
	if(!image && self.imageLoader){//spinner
        if(_defaultImage){
            [self createsDefaultImageView];
            self.defaultImageView.alpha = 1;
            self.defaultImageView.frame = self.bounds;
        }
        
		if(_currentState != CKImageViewStateSpinner){
			[self.layer removeAnimationForKey:[NSString stringWithFormat:@"CKImageView<%p>",self]];
            
			[self.imageView removeFromSuperview];
            
            if(!self.interactive){
                [self.button removeFromSuperview];
            }
			
			if(self.imageLoader){
				if(self.activityIndicator){
					self.activityIndicator.center = self.center;
					self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
					self.activityIndicator.frame = CGRectMake(self.bounds.size.width / 2 - self.activityIndicator.bounds.size.width / 2,
															  self.bounds.size.height / 2 - self.activityIndicator.bounds.size.height / 2,
															  self.activityIndicator.bounds.size.width,
															  self.activityIndicator.bounds.size.height);
					[self.activityIndicator startAnimating];
					_currentState = CKImageViewStateSpinner;
                    [self addSubview:self.activityIndicator];
				}
			}
		}
	}
	else if(_defaultImage && !image){//_defaultImageView       
        [self createsDefaultImageView];
        
        [self.imageView removeFromSuperview];
        
        if(!self.interactive){
            [self.button removeFromSuperview];
        }
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        
        self.defaultImageView.alpha = 1;
        self.defaultImageView.frame = self.bounds;
        _currentState = CKImageViewStateDefaultImage;
	}
	else {//image or button
        if (animated) {
            if(_interactive){
                self.button.frame = self.bounds;
                [self addSubview:self.button];
                self.button.alpha = 0;
            }
            else{
                self.imageView.frame = self.bounds;
                [self addSubview:self.imageView];
                self.imageView.alpha = 0;
            }
            
            if (self.superview != nil) {
                [self createsDefaultImageView];
                self.defaultImageView.alpha = 1;
                self.imageView.alpha = 0;
                self.button.alpha = 0;
                [UIView animateWithDuration:self.fadeInDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    self.imageView.alpha = 1;
                    self.button.alpha = 1;
                    self.defaultImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.defaultImageView removeFromSuperview];
                    [self.activityIndicator stopAnimating];
                    [self.activityIndicator removeFromSuperview];
                    
                    if(_interactive){
                        [self.imageView removeFromSuperview];
                    }
                    else{
                        
                        if(!self.interactive){
                            if(self.button)
                                [self.button removeFromSuperview];
                        }
                    }
                }];
            }
        }
        else {
            [self.defaultImageView removeFromSuperview];
            [self.activityIndicator stopAnimating];
            [self.activityIndicator removeFromSuperview];
            
            if(_interactive){
                [self.imageView removeFromSuperview];
                self.button.frame = self.bounds;
                [self addSubview:self.button];
            }
            else{
                
                if(!self.interactive){
                    if(self.button)
                        [self.button removeFromSuperview];
                }
                self.imageView.frame = self.bounds;
                [self addSubview:self.imageView];
            }
        }
        
        _currentState = CKImageViewStateImage;
	}
}

- (void)spinnerStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKImageViewSpinnerStyle", 
                                               CKImageViewSpinnerStyleWhiteLarge,
                                               CKImageViewSpinnerStyleWhite,
                                               CKImageViewSpinnerStyleGray,
                                               CKImageViewSpinnerStyleNone,
                                               UIActivityIndicatorViewStyleWhiteLarge,
                                               UIActivityIndicatorViewStyleWhite,
                                               UIActivityIndicatorViewStyleGray);
}

@end


@implementation CKImageView (CKBindings)

- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block{
    if(self.button){
        [self.button bindEvent:UIControlEventTouchUpInside withBlock:block];
    }
    if(self.defaultImageView && [self.defaultImageView isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)self.defaultImageView;
        [bu bindEvent:UIControlEventTouchUpInside withBlock:block];
    }
}

- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector{
    if(self.button){
        [self.button bindEvent:UIControlEventTouchUpInside target:target action:selector];
    }
    if(self.defaultImageView && [self.defaultImageView isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)self.defaultImageView;
        [bu bindEvent:UIControlEventTouchUpInside target:target action:selector];
    }
}

@end
