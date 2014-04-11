//
//  QwertyKeyboardController.h
//  Shortcut
//
//  Created by YJ Park on 10/3/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "KeyShortcutController.h"


@interface QwertyKeyboardController : KeyShortcutController {
	UIButton *preview;
	UINavigationItem *toolBar;
}
@property (nonatomic, retain) IBOutlet UINavigationItem *toolBar;

@end
