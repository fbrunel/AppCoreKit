//
//  CKCollectionCellContentViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionCellContentViewController.h"
#import "NSObject+Bindings.h"
#import "UIView+Positioning.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "CKLayoutBox.h"
#import "UIView+CKLayout.h"
#import "CKContainerViewController.h"
#import "CKStyleManager.h"
#import "CKResourceManager.h"
#import "CKResourceDependencyContext.h"

@interface CKCollectionViewController () 
- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index;
@end

@interface CKCollectionCellContentViewController ()
@property(nonatomic,retain) CKWeakRef* collectionCellControllerWeakRef;
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@property(nonatomic,retain) UIView* reusableView;
@property(nonatomic,retain) UIView* contentViewCell;
@property(nonatomic,assign) BOOL isComputingSize;
@end

@interface CKCollectionCellController()
- (UIView*)parentControllerView;
@end

@implementation CKCollectionCellContentViewController

- (void)dealloc{
    [self clearBindingsContext];
    
    [_didSelectBlock release];
    [_collectionCellControllerWeakRef release];
    [_reusableView release];
    [_contentViewCell release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKStyleManagerDidReloadNotification object:nil];
    
    [super dealloc];
}

- (NSString*)reuseIdentifier{
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

- (id)init{
    self = [super init];
    self.flags = CKViewControllerFlagsSelectable;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleManagerDidUpdate:) name:CKStyleManagerDidReloadNotification object:nil];
    return self;
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    [super setContainerViewController:containerViewController];
    [self postInit];
}

- (void)styleManagerDidUpdate:(NSNotification*)notification{
    
    if(!self.view){
        return;
    }
    
    if(notification.object == [self styleManager]){
        [self resourceManagerReloadUI];
    }
}


- (void)resourceManagerReloadUI{
    [super resourceManagerReloadUI];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionCellController invalidateSize];
    });
}

- (void)setCollectionCellController:(CKCollectionCellController *)c{
    self.collectionCellControllerWeakRef = [CKWeakRef weakRefWithObject:c];
    [self setContainerViewController:c.containerController];
}

- (CKCollectionCellController*)collectionCellController{
    return [self.collectionCellControllerWeakRef object];
}

- (id)value{
    return [self.collectionCellController value];
}

- (NSIndexPath*)indexPath{
    if(self.collectionCellController )
        return [self.collectionCellController indexPath];
    
    if([self.containerViewController respondsToSelector:@selector(indexPathForController:)]){
        return [self.containerViewController performSelector:@selector(indexPathForController:) withObject:self];
    }
    
    return nil;
}

- (CKViewController*)collectionViewController{
    if(self.collectionCellController)
        return [self.collectionCellController containerController];
    
    return (CKViewController*)self.containerViewController;
}

- (UIView*) contentViewCell{
    if(self.collectionCellController)
        return  self.collectionCellController.view;
    return _contentViewCell;
}

- (UIView*) contentView{
    if([self.collectionViewController respondsToSelector:@selector(contentView)])
        return [self.collectionViewController performSelector:@selector(contentView) withObject:nil];
    return nil;
}

- (UIView*)view{
    if(self.reusableView)
        return self.reusableView;
    
    return [super view];
}

- (BOOL)isViewLoaded{
    if(self.reusableView)
        return YES;
    return [super isViewLoaded];
}

- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell{
    self.reusableView = contentView;
    self.contentViewCell = contentViewCell;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    self.isComputingSize = YES;
    if(self.isViewLoaded || self.reusableView){
        UIView* view = [self view];
        
        //Support for CKLayout
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            return [view preferredSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
        }
        
        self.isComputingSize = NO;
        
        //Support for nibs
        return CGSizeMake(MIN(size.width,self.view.width),MIN(size.height,self.view.height));
    }else{
        UIView* view = [[UIView alloc]init];
        view.frame = CGRectMake(0, 0, size.width, 100);
        [self prepareForReuseUsingContentView:view contentViewCell:view];
        
        [self viewDidLoad];
        [self viewWillAppear:NO];
        [self viewDidAppear:NO];
        
        [view layoutSubviews];
        
        //Support for CKLayout
        CGSize returnSize = CGSizeMake(0,0);
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            returnSize = [view preferredSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
        }
        
        [self viewWillDisappear:NO];
        [self viewDidDisappear:NO];
        
        [view clearBindingsContext];
        
        [self prepareForReuseUsingContentView:nil contentViewCell:nil];
        
        [view release];
        
        self.isComputingSize = NO;
        
        return returnSize;
    }
    
    self.isComputingSize = NO;
    
    return CGSizeMake(0,0);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //HERE we do not apply style on sub views as we have reuse
    if(self.appliedStyle == nil || [self.appliedStyle isEmpty]){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableSet* appliedStack = [NSMutableSet set];
        [self applySubViewsStyle:controllerStyle appliedStack:appliedStack  delegate:nil];
        /// [[self class] applyStyleByIntrospection:controllerStyle toObject:self appliedStack:appliedStack delegate:nil];
        [self setAppliedStyle:controllerStyle];
    }
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self applyStyleToSubViews];
    }
    
    __unsafe_unretained CKCollectionCellContentViewController* bself = self;
    
    self.view.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
        if(bself.view.window == nil || bself.isComputingSize)
            return;
        
        [bself.collectionCellController invalidateSize];
    };
}

- (void)applyStyleToSubViews{
    //Allows the CKCollectionCellContentViewController to specify style for the contentViewCell
    if(self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]){
        [self.contentViewCell setAppliedStyle:nil];
        [self.contentViewCell findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"contentViewCell"];
    }
    
    [self.view findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"view"];
}

- (void)postInit{
    
}

- (void)didSelect{
    if(self.didSelectBlock){
        self.didSelectBlock();
    }
}

- (void)didBecomeFirstResponder{
    
}

- (void)didResignFirstResponder{
    
}

- (BOOL)didRemove{
    return NO;
}

- (UINavigationController*)navigationController{
    return self.collectionViewController.navigationController;
}

- (void)scrollToCell{
    if([self.collectionViewController respondsToSelector:@selector(scrollToControllerAtIndexPath:animated:)]){
        [self.collectionViewController performSelector:@selector(scrollToControllerAtIndexPath:animated:) withObject:self.indexPath withObject:@(YES)];
    }
}

@end
