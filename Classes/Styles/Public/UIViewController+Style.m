//
//  UIViewController+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIViewController+Style.h"
#import "UIView+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"
#import "CKVersion.h"
#import <objc/runtime.h>
#import "CKResourceManager.h"
#import "CKContainerViewController.h"


static char UIViewControllerStyleManagerKey;
static char UIViewControllerStylesheetFileNameKey;

@implementation UIViewController (CKStyle)
@dynamic stylesheetFileName, styleManager;

- (void)setStylesheetFileName:(NSString *)stylesheetFileName{
    objc_setAssociatedObject(self,
                             &UIViewControllerStylesheetFileNameKey,
                             stylesheetFileName,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)stylesheetFileName{
    return objc_getAssociatedObject(self, &UIViewControllerStylesheetFileNameKey);
}

- (void)setStyleManager:(CKStyleManager *)styleManager{
    objc_setAssociatedObject(self,
                             &UIViewControllerStyleManagerKey,
                             styleManager,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKStyleManager*)styleManager{
    CKStyleManager* manager = objc_getAssociatedObject(self, &UIViewControllerStyleManagerKey);
    if(manager)
        return manager;
    
    //BACKWARD COMPATIBILITY :
    //check if default bundle has a style for this controller.
    //if so, uses the default manager.
    NSMutableDictionary* styleInDefaultManager = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
    if(styleInDefaultManager && ![styleInDefaultManager isEmpty]){
        [self setStyleManager:[CKStyleManager defaultManager]];
        return [CKStyleManager defaultManager];
    }
    
    //TODO : register on updates for this file as it can be created from dropbox ...
    //If this file or one of its dependencies refreshes, only update this view controller.
    
    if(self.stylesheetFileName){
        manager = [CKStyleManager styleManagerWithContentOfFileNamed:self.stylesheetFileName];
    }else{
        NSString* filePath = [CKResourceManager pathForResource:[[self class]description] ofType:@".style"];
        if(!filePath){
            UIViewController* containerViewController = nil;
            if([self respondsToSelector:@selector(containerViewController)]){
                containerViewController = [self performSelector:@selector(containerViewController)];
            }
            
            if(containerViewController){
                self.stylesheetFileName = containerViewController.stylesheetFileName;
                manager = [containerViewController styleManager];
            }else{
                
                NSMutableArray* controllerStack = [NSMutableArray array];
                
                NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
                if(index != NSNotFound && index >= 1){
                    UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
                    [controllerStack addObject:previousViewController];
                }
                
                UIViewController* c = self;
                while(c){
                    if([c respondsToSelector:@selector(containerViewController)]){
                        c = [c performSelector:@selector(containerViewController)];
                        if(c){
                            [controllerStack insertObject:c atIndex:0];
                        }
                    }
                    else{
                        c = nil;
                    }
                }
                
                if([controllerStack count] > 0){
                    manager = [[controllerStack objectAtIndex:0]styleManager];
                }else{
                    manager = [CKStyleManager defaultManager];
                }
            }
        }else{
            self.stylesheetFileName = [[self class]description];
            manager = [CKStyleManager styleManagerWithContentOfFileNamed:[[self class]description]];
        }
    }
    
    [self setStyleManager:manager ];
    return manager;
}

- (NSMutableDictionary*)controllerStyle{
    //First try to get a style in its own stylemanager
    NSMutableDictionary* s = [[self styleManager] styleForObject:self  propertyName:nil];
    if(s && ![s isEmpty]){
        return s;
    }
    
    //Returns the more specific style taking care of navigation and container hierarchy
    NSMutableArray* controllerStack = [NSMutableArray array];
    
    NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
    if(index != NSNotFound && index >= 1){
        UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
        [controllerStack addObject:previousViewController];
    }
    
    UIViewController* c = self;
    while(c){
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
            if(c){
                [controllerStack insertObject:c atIndex:0];
            }
        }
        else{
            c = nil;
        }
    }
    
    for(UIViewController* controller in controllerStack){
        NSMutableDictionary* styleInContainer = [controller.stylesheet styleForObject:self propertyName:nil];
        if(styleInContainer && ![styleInContainer isEmpty]){
            return styleInContainer;
        }
    }
    
    return nil;
}

- (NSMutableDictionary* )applyStyle{
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    
    NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];

    return controllerStyle;
}

- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style{
    NSMutableDictionary* controllerStyle = style ? [style styleForObject:self  propertyName:nil] : [[self styleManager] styleForObject:self  propertyName:nil];
	
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            CKDebugLog(@"did not find style for controller %@",self);
        }
        else{
            CKDebugLog(@"found style for controller %@",self);
        }
    }
    
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];
    
    return controllerStyle;
}

@end
