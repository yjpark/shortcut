//
//  ShortcutServerSelector.h
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShortcutServerSelectorDelegate<NSObject>
- (void) updateServers: (NSArray *) _servers;
@end

@interface ShortcutServerSelector : NSObject {
	NSNetServiceBrowser *browser;
	NSMutableArray *services;
	
	id<ShortcutServerSelectorDelegate> delegate;
}
@property (nonatomic, assign) id<ShortcutServerSelectorDelegate> delegate;

- (void) search;
- (void) _updateDelegate;

@end
