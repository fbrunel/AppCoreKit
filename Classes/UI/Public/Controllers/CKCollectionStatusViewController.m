//
//  CKCollectionStatusViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionStatusViewController.h"

@implementation CKCollectionStatusViewController

- (instancetype)initWithCollection:(CKCollection*)collection{
    self = [super init];
    self.collection = collection;
    return self;
}

+ (instancetype)controllerWithCollection:(CKCollection*)collection{
    return [[[[self class]alloc]initWithCollection:collection]autorelease];
}

- (void)postInit{
    [super postInit];
    self.noObjectTitleFormat = _(@"No object");
    self.oneObjectTitleFormat = _(@"1 object");
    self.multipleObjectTitleFormat = _(@"%d objects");
    self.estimatedSize = CGSizeMake(320,0);
}

- (void)dealloc{
    [_collection release];
    [_noObjectTitleFormat release];
    [_oneObjectTitleFormat release];
    [_multipleObjectTitleFormat release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UIActivityIndicatorView* ActivityIndicatorView = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]autorelease];
    ActivityIndicatorView.name = @"ActivityIndicatorView";
    ActivityIndicatorView.minimumHeight = 24;
    ActivityIndicatorView.margins =  UIEdgeInsetsMake(10, 10, 10, 10);
    
    UILabel* TitleLabel = [[[UILabel alloc]init]autorelease];
    TitleLabel.name = @"TitleLabel";
    TitleLabel.font = [UIFont boldSystemFontOfSize:17];
    TitleLabel.textColor = [UIColor blackColor];
    TitleLabel.numberOfLines = 1;
    TitleLabel.textAlignment = UITextAlignmentCenter;
    
    UILabel* SubtitleLabel = [[[UILabel alloc]init]autorelease];
    SubtitleLabel.name = @"SubtitleLabel";
    SubtitleLabel.font = [UIFont systemFontOfSize:14];
    SubtitleLabel.textColor = [UIColor blackColor];
    SubtitleLabel.numberOfLines = 1;
    SubtitleLabel.textAlignment = UITextAlignmentCenter;
    
    CKVerticalBoxLayout* vTextbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vTextbox.minimumHeight = 24;
    vTextbox.margins =  UIEdgeInsetsMake(10, 10, 10, 10);
    vTextbox.name = @"vTextbox";
    vTextbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[TitleLabel,SubtitleLabel]];
    
    CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[ActivityIndicatorView,vTextbox]];
    
    CKHorizontalBoxLayout* hBox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[ [[[CKLayoutFlexibleSpace alloc]init]autorelease],vbox,[[[CKLayoutFlexibleSpace alloc]init]autorelease]]];
  
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox]];
}

- (void)setCollection:(CKCollection *)collection{
    [_collection release];
    _collection = [collection retain];
    
    if(![self isViewLoaded])
        return;
    
    [self.view beginBindingsContextWithScope:@"CKCollectionStatusViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(![self isViewLoaded])
        return;
    
    [self.view beginBindingsContextWithScope:@"CKCollectionStatusViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContextWithScope:@"CKCollectionStatusViewController"];
}

- (void)setupBindings{
    __block CKCollectionStatusViewController* bself = self;
    [self.collection bind:@"isFetching" withBlock:^(id value) {
        [bself update];
    }];
    [self.collection bind:@"count" executeBlockImmediatly:YES withBlock:^(id value) {
        [bself update];
    }];
}

- (BOOL)forceHidingView:(UIView*)view{
    NSMutableDictionary* style = [view appliedStyle];
    
    BOOL forceHidden = NO;
    if([style containsObjectForKey:@"hidden"]){
        forceHidden = [[style objectForKey:@"hidden"]boolValue];
    }
    
    return forceHidden;
}

- (void)update{
    UIActivityIndicatorView* ActivityIndicatorView = [self.view viewWithName:@"ActivityIndicatorView"];
    UILabel* TitleLabel = [self.view viewWithName:@"TitleLabel"];
    UILabel* SubtitleLabel = [self.view viewWithName:@"SubtitleLabel"];
    
    ActivityIndicatorView.hidden = [self forceHidingView:ActivityIndicatorView] || !self.collection.isFetching || self.view.frame.size.width <= 0 || self.view.frame.size.height <= 0;
    if(!ActivityIndicatorView.hidden){
        [ActivityIndicatorView startAnimating];
    }
    else{
        [ActivityIndicatorView stopAnimating];
    }
    
    TitleLabel.hidden = [self forceHidingView:TitleLabel] || !ActivityIndicatorView.hidden;
    SubtitleLabel.hidden = [self forceHidingView:SubtitleLabel] || [self.subtitleLabel length] <= 0;
    SubtitleLabel.text = self.subtitleLabel;
    
    if(ActivityIndicatorView.hidden){
        switch(self.collection.count){
            case 0:{
                TitleLabel.text = [NSString stringWithFormat:_(self.noObjectTitleFormat),self.collection.count];
                break;
            }
            case 1:{
                TitleLabel.text = [NSString stringWithFormat:_(self.oneObjectTitleFormat),self.collection.count];
                break;
            }
            default:{
                TitleLabel.text = [NSString stringWithFormat:_(self.multipleObjectTitleFormat),self.collection.count];
                break;
            }
        }
    }else{
        TitleLabel.text = nil;
    }
    
    id<CKLayoutBoxProtocol> vTextbox = [self.view layoutWithName:@"vTextbox"];
    vTextbox.hidden = TitleLabel.hidden && SubtitleLabel.hidden;
}

@end