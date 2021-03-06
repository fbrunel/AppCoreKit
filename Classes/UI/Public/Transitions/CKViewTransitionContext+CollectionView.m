//
//  CKViewTransitionContext+CollectionView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+CollectionView.h"
#import "UIView+Name.h"

@implementation CKViewTransitionContext (CollectionView)

+ (UICollectionViewLayoutAttributes*)attributesForIndexPath:(NSIndexPath*)indexPath
                                                     layout:(UICollectionViewLayout*)layout
                                             collectionView:(UICollectionView*)collectionView
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    UICollectionViewLayoutAttributes* att = [layout layoutAttributesForItemAtIndexPath:indexPath];
    att.center = [collectionView convertPoint:att.center toView:[transitionContext containerView]];
    att.alpha = 1.0f;
    return att;
}


+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                      targetIndexPath:(NSIndexPath*)targetIndexPath
                                         targetLayout:(UICollectionViewLayout*)targetLayout
                                 targetCollectionView:(UICollectionView*)targetCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    cell.name = [NSString stringWithFormat:@"%ld %ld",(long)targetIndexPath.section,(long)targetIndexPath.item];
    context.name = cell.name;
    
    context.snapshot = [CKViewTransitionContext snapshotView:cell withHierarchy:YES context:context];
    if(context.snapshot == nil){
        return nil;
    }
    context.snapshot.layer.zPosition = zPosition;
    
    context.startAttributes = [self attributesForIndexPath:sourceIndexPath layout:sourceLayout collectionView:sourceCollectionView transitionContext:transitionContext];
    context.endAttributes = [self attributesForIndexPath:targetIndexPath layout:targetLayout collectionView:targetCollectionView transitionContext:transitionContext];
    
    return context;
}


+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                            animation:(CKViewTransitionContextAnimation)animation
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    cell.name = [NSString stringWithFormat:@"%ld %ld",(long)sourceIndexPath.section,(long)sourceIndexPath.item];
    context.name = cell.name;
    
    context.snapshot = [CKViewTransitionContext snapshotView:cell withHierarchy:YES context:context];
    if(context.snapshot == nil){
        return nil;
    }
    context.snapshot.layer.zPosition = zPosition;
    
    context.startAttributes = [self attributesForIndexPath:sourceIndexPath layout:sourceLayout collectionView:sourceCollectionView transitionContext:transitionContext];
    context.endAttributes = [self attributesFromAttributes:context.startAttributes animation:animation transitionContext:transitionContext];
    
    return context;
}


+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    return [self contextForSourceIndexPath:sourceIndexPath sourceLayout:sourceLayout sourceCollectionView:sourceCollectionView cell:cell zPosition:zPosition animation:CKViewTransitionContextAnimationNone transitionContext:transitionContext];
}


@end
