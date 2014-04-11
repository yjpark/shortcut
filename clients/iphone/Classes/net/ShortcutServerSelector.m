//
//  ShortcutServerSelector.m
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutServerSelector.h"
#import "ShortcutModel.h"

@implementation ShortcutServerSelector
@synthesize delegate;

- (id) init {
	if ((self = [super init])) {
		services = [[NSMutableArray alloc] init];
		browser = [[NSNetServiceBrowser alloc] init];
		browser.delegate = self;
	}
	return self;
}

- (void) dealloc {
	self.delegate = nil;
    [browser release];
    [services release];
    [super dealloc];
}

- (void) search{
	@synchronized(services){
		[browser stop];
		[services removeAllObjects];
		[browser searchForServicesOfType:SHORTCUT_SESSION_TYPE inDomain:@""];
		[self _updateDelegate];
	}
}

- (void) _updateDelegate {
	if (delegate != nil) {
		[delegate updateServers:[services copy]];
	}
}

#pragma mark Net Service Browser Delegate Methods
- (void) netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
	NSLog(@"didFindService: %@", aService);
	@synchronized(services){
		[services addObject:aService];
		aService.delegate = self;
		[aService resolveWithTimeout: 5];
		[self _updateDelegate];
	}
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
	@synchronized(services){
		NSLog(@"didRemoveService: %@", aService);
		[services removeObject:aService]; //even if it's not added yet, the remove will not hurt.
		[self _updateDelegate];
	}
}

- (void) netServiceDidResolveAddress:(NSNetService *)service {
	NSLog(@"Service resolved: %@, %@, %d, %@", service,
		  [service hostName], [service port], [service addresses]);
	@synchronized(services){
		[self _updateDelegate];
	}	
}

- (void) netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Could not resolve: %@, %@", service, errorDict);
}


@end
