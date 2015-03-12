//
//  CKPropertiesSampleViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-12.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertiesSampleViewController.h"
#import "CKPropertyStringViewController.h"
#import "CKTableViewContentCellController.h"

@interface CKPropertiesSampleViewController ()
@property(nonatomic,retain) NSString* singleLineString;
@property(nonatomic,retain) NSString* multiLineString;
@end

@implementation CKPropertiesSampleViewController

#pragma mark ViewController Life Cycle

- (void)postInit{
    [super postInit];
    [self setupForm];
}

#pragma mark Initializing Form

- (void)setupForm{
    self.title = @"AppCoreKit - Properties Sample";
    
    CKPropertyStringViewController* singleLineController = [[[CKPropertyStringViewController alloc]initWithProperty:[CKProperty propertyWithObject:self keyPath:@"singleLineString"]]autorelease];
    
    CKPropertyStringViewController* multilineLineController = [[[CKPropertyStringViewController alloc]initWithProperty:[CKProperty propertyWithObject:self keyPath:@"multiLineString"]]autorelease];
    multilineLineController.multiline = YES;
    
    CKFormSection* propertiesSection = [CKFormSection sectionWithCellControllers:@[
        [singleLineController newTableViewCellController],
        [multilineLineController newTableViewCellController]
    ]];
    
    NSArray* sections = @[
        propertiesSection
    ];
    
    [self addSections:sections];
  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor blackColor];
}

@end