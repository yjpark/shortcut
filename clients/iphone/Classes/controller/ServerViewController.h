//
//  ServerViewController.h
//  Shortcut
//
//  Created by YJ Park on 9/27/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AQGridViewController.h"

#import "ShortcutModel.h"
#import "ShortcutMsg.h"
#import "ShortcutClient.h"
#import "ShortcutController.h"

#define AUTH_CODE_KEY @"authcode"
@interface ServerViewController : AQGridViewController<ShortcutClientDelegate> {
	ShortcutModel *model;
	ShortcutClient *client;
	NSMutableArray *shortcuts;
}

- (ServerViewController *) initWithClient: (ShortcutClient *)_client;

- (void) _addShortcut: (ShortcutController *) shortcut;
- (void) _removeShortcut: (ShortcutController *) shortcut;
- (void) _authenticate;

@end
