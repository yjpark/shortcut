//
//  ShortcutAppDelegate.h
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortcutModel.h"

@interface ShortcutAppDelegate : NSObject <UIApplicationDelegate> {
    ShortcutModel *model;
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

