//
//  CKClassExplorer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CKArrayCollection.h"
#import "CKCallback.h"
#import "CKTableViewController.h"

/**
 */
typedef NS_ENUM(NSInteger, CKClassExplorerType){
	CKClassExplorerTypeClasses,
	CKClassExplorerTypeInstances
};


/**
 */
@interface CKClassExplorer : CKTableViewController {
	CKArrayCollection* _classesCollection;
	id _userInfo;
	NSString* _className;
}
@property(nonatomic,retain)id userInfo;

- (id)initWithBaseClass:(Class)type;
- (id)initWithProtocol:(Protocol*)protocol;

@end
