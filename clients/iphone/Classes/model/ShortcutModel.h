//
//  ShorctModel.h
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShortcutServerSelector.h"
#import "ShortcutController.h"
#import "ShortcutClient.h"
#import "ShortcutUtils.h"

#define SHORTCUT_SESSION_TYPE @"_pettyfun-shortcut._tcp."
//#define SHORTCUT_SESSION_TYPE @"_daap._tcp."

#define SHORTCUT_WEBSOCKET_PROTOCOL @"wss"
#define SHORTCUT_WEBSOCKET_PATH @"msg75"

//Hacky way to test controllel, though can make code cleaner.
#define CHECK_CONCTROLLEL(c) \
    if ([ShortcutController createShortcut: newChannel \
        allChannels: allChannels require: [c getRequiredChannalTypes]]) { \
        shortcut = [[[c alloc] init] autorelease]; \
        shortcut.requiredChannelTypes = [c getRequiredChannalTypes]; \
        [result addObject: shortcut]; \
    }

#define DEFAULT_KEY_FOR_CLIENT_PATTERN @"com.pettyfun.shortcut.%@.%@.%@"

@interface ShortcutModel : NSObject {
    ShortcutUtils *utils;
	ShortcutServerSelector *serverSelector;
	NSMutableDictionary *clients;
}
@property (readonly) ShortcutServerSelector *serverSelector;
@property (readonly) ShortcutUtils *utils;

+ (ShortcutModel *) getInstance;

- (void) terminate;
- (ShortcutClient *) getClient: (NSNetService *) service;

- (NSString *) getURL: (NSNetService *) service;
- (NSString *) getAddress: (NSNetService *) service;

- (NSArray *) getNewShortcuts: (NSString *) newChannel
				  allChannels: (NSArray *) allChannels;

- (NSString *) _getIP: (NSNetService *) service withIndex: (int) index;
- (NSString *) _getIP: (struct sockaddr_in *) socketAddress;
- (int) _getSimilarity: (NSString *) ip1 withIP: (NSString *) ip2;

- (id) getDefault: (NSString *)key forClient: (ShortcutClient *)client;
- (void) writeDefault: (id) value forKey: (NSString *)key forClient: (ShortcutClient *)client;
@end
