//
//  RootViewController.h
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShortcutModel.h"
#import "ServerViewController.h"

@interface ServersViewController : UITableViewController<ShortcutServerSelectorDelegate> {
	ShortcutModel *model;
	NSArray *servers;
}

@end
