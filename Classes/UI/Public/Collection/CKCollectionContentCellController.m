//
//  CKCollectionContentCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionContentCellController.h"
#import "CKLayoutBox.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "UIView+CKLayout.h"
#import "CKCollectionViewLayoutController.h"
#import "CKCollectionViewCell.h"
#import "UIView+Positioning.h"
#import "CKViewCellCache.h"

@interface CKCollectionCellContentViewController ()
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@end


@interface CKCollectionContentCellController()
@property(nonatomic,retain) CKCollectionCellContentViewController* contentViewController;
@end

@implementation CKCollectionContentCellController
@synthesize deselectionCallback = _deselectionCallback;

- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController{
    self = [super init];
    [self setContentViewController:contentViewController];
    [contentViewController setCollectionCellController:self];
    return self;
}

- (void)dealloc{
    [_contentViewController release];
    [_deselectionCallback release];
    [super dealloc];
}

- (void)didDeselect{
	if(self.deselectionCallback != nil){
		[self.deselectionCallback execute:self];
	}
}

- (void)applyStyle{
    [super applyStyle];
    
    if(!self.view || ![self contentViewController])
        return;
    
    UIView* contentView = [self.view valueForKey:@"contentView"];
    if(contentView == nil){ contentView = self.view; }
    
    contentView.sizeToFitLayoutBoxes = NO;
    [contentView setAppliedStyle:nil];
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self.view.appliedStyle setAppliedStyle:nil];
    }
}

- (void)initView:(UIView *)view{
    [super initView:view];
    
    if([self contentViewController]){
        UIView* contentView = [view valueForKey:@"contentView"];
        if(contentView == nil){ contentView = view; }
        
        [[self contentViewController]prepareForReuseUsingContentView:contentView contentViewCell:view];
        [[self contentViewController]viewDidLoad];
    }
}

- (void)setupView:(UIView*)view{
    if([self contentViewController]){
        UIView* contentView = [view valueForKey:@"contentView"];
        if(contentView == nil){ contentView = view; }
    
        [[self contentViewController]prepareForReuseUsingContentView:contentView contentViewCell:view];
        [[self contentViewController]viewWillAppear:NO];
    }
    
    [super setupView:view];
    
    if([self contentViewController]){
        [[self contentViewController]viewDidAppear:NO];
    }
}

- (void)viewDidDisappear{
    if(![self contentViewController])
        return;
    
    [[self contentViewController]viewWillDisappear:NO];
    [[self contentViewController]viewDidDisappear:NO];
}


- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(self.view){
        return [[self contentViewController] preferredSizeConstraintToSize:size];
    }else{
        CKCollectionViewCell* view = (CKCollectionViewCell*)[[CKViewCellCache sharedInstance]reusableViewWithIdentifier:[self identifier]];
        
        if(!view){
            view = [[[CKCollectionViewCell alloc]init]autorelease];
            view.height = size.height;
            view.width  = size.width;
            
            UIView* original = self.view; //For styles to apply correctly on view.
            self.view = view;
            
            [self initView:view];
            self.view = original;
            [[CKViewCellCache sharedInstance]setReusableView:view forIdentifier:[self identifier]];
        }
        
        UIView* original = self.view; //For styles to apply correctly on view.
        self.view = view;
        [self setupView:view];
        self.view = original;
        
        return [[self contentViewController] preferredSizeConstraintToSize:size];
    }

}

@end
