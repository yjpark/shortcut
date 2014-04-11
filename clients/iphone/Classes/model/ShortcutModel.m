//
//  ShorctModel.m
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutModel.h"
#import <netinet/in.h>

#import "DictionaryController.h"
#import "QwertyKeyboardController.h"
#import "DvorakKeyboardController.h"
#import "MouseController.h"
#import "XBMCShortcut.h"
#import	"GoogleReaderShortcut.h"

static ShortcutModel *_shortcutModelInstance = nil;

@implementation ShortcutModel

@synthesize utils;
@synthesize serverSelector;

+ (ShortcutModel *) getInstance {
	@synchronized(self) {
		if (_shortcutModelInstance == nil) {
			_shortcutModelInstance = [[ShortcutModel alloc] init];
		}
	}
	return _shortcutModelInstance;
}

- (id) init {
	if ((self = [super init])) {
        utils = [[ShortcutUtils alloc] init];
		clients = [[NSMutableDictionary alloc] init];
		serverSelector = [[ShortcutServerSelector alloc] init];
		[serverSelector search];
	}
	return self;
}

- (void) dealloc {
    [utils release];
	[clients release];
	[serverSelector release];
	[super dealloc];
}

- (void) terminate {
	// This is not a really correct cleanup, the application will be terminated
	// soon, so no need to deal with all the memory, just close up connections
	// cleanly
	NSLog(@"model terminate");
	for (ShortcutClient *client in [clients allValues]) {
		[client terminate];
	}
}

- (NSString *) getURL: (NSNetService *)service {
	NSString *url = nil;
	NSString *address = [self getAddress: service];
	if (address != nil) {
		url = [NSString stringWithFormat: @"%@://%@/%@",
				SHORTCUT_WEBSOCKET_PROTOCOL, address, SHORTCUT_WEBSOCKET_PATH];
	}
	NSLog(@"getURL(%@) = %@", [service name], url);
	return url;
}

- (NSString *) getAddress: (NSNetService *) service {
	NSString *address = nil;
	NSArray *addresses = service.addresses;
	if( addresses.count > 0 ) {
		NSString *localIP = [[NSHost currentHost] address];
		NSLog(@"local IP = %@", localIP);
		int port = service.port;
		NSString *bestIP = nil;
		int bestSimilarity = -1;
		for (int i = 0; i < [addresses count]; i++) {
			NSString *ip = [self _getIP: service withIndex: i];
			int similarity = [self _getSimilarity: localIP withIP: ip];
			NSLog(@"ip = %@, similarity = %d", ip, similarity);
			if (similarity > bestSimilarity) {
				bestIP = ip;
				bestSimilarity = similarity;
			}
		}
		address = [NSString stringWithFormat: @"%@:%d", bestIP, port];
	}
	NSLog(@"getAddress(%@) = %@", [service name], address);
	return address;
}

- (int) _getSimilarity: (NSString *) ip1 withIP: (NSString *) ip2 {
	int result = 0;
	int len = [ip1 length];
	if (len > [ip2 length]) {
		len = [ip2 length];
	}
	for (int i = 0; i < len; i ++) {
		if ([ip1 characterAtIndex:i] != [ip2 characterAtIndex:i]) {
			return result;
		} else {
			result ++;
		}
	}
	return result;
}

- (NSString *) _getIP: (NSNetService *) service withIndex: (int) index {
    NSData *address = [[service addresses] objectAtIndex: index];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
	return [self _getIP: socketAddress];
}

- (NSString *) _getIP: (struct sockaddr_in *) socketAddress {
    return [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
}

- (ShortcutClient *) getClient: (NSNetService *) service {
	ShortcutClient *client = nil;
	NSString *url = [self getURL:service];
	if (url != nil) {
		client = [clients valueForKey:url];
		if (client == nil) {
			client = [[[ShortcutClient alloc] initWithName: service.name andURL: url] autorelease];
			[clients setValue:client forKey:url];
		}
	}
	return client;
}

- (NSArray *) getNewShortcuts: (NSString *) newChannel
				  allChannels: (NSArray *) allChannels {
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	ShortcutController *shortcut = nil;
	CHECK_CONCTROLLEL(QwertyKeyboardController)
	CHECK_CONCTROLLEL(DvorakKeyboardController)
	CHECK_CONCTROLLEL(MouseController)
	CHECK_CONCTROLLEL(DictionaryController)
	CHECK_CONCTROLLEL(XBMCShortcut)
	CHECK_CONCTROLLEL(GoogleReaderShortcut)
	/*
	if ([ShortcutController 
			createShortcut: newChannel 
  		       allChannels: allChannels
				   require: [DictionaryController getRequiredChannalTypes]]) {
		shortcut = [[[DictionaryController alloc] init] autorelease];
		[result addObject: shortcut];
	}
	*/
	return result;
}

- (id) getDefault: (NSString *)key forClient: (ShortcutClient *)client {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id result = [defaults valueForKey:
        [NSString stringWithFormat:DEFAULT_KEY_FOR_CLIENT_PATTERN,
         client.name, client.url, key]];
    return result;
}

- (void) writeDefault: (id) value forKey: (NSString *)key
          forClient: (ShortcutClient *)client {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:
     [NSString stringWithFormat:DEFAULT_KEY_FOR_CLIENT_PATTERN,
      client.name, client.url, key]];
    [defaults synchronize];
}


@end
