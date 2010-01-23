//
//  IFGenericTableViewController.h
//  Thunderbird
//
//	Created by Craig Hockenberry on 1/29/09.
//	Copyright 2009 The Iconfactory. All rights reserved.
//
//  Based on work created by Matt Gallagher on 27/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//	For more information: http://cocoawithlove.com/2008/12/heterogeneous-cells-in.html
//

#import <UIKit/UIKit.h>

#import "IFCellModel.h"

@interface IFGenericTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *_tableView;
	
	NSMutableArray *tableGroups;
	NSMutableArray *tableHeaders;
	NSMutableArray *tableFooters;

	NSObject<IFCellModel> *model;
}

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) NSObject<IFCellModel> *model;

- (void)constructTableGroups;
- (void)clearTableGroups;
- (void)updateAndReload;
- (void)addSection:(NSArray *)rows withHeaderText:(NSString *)headerText andFooterText:(NSString *)footerText;

@end
