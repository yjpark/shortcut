//
//  ShortcutClient.m
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutClient.h"


@implementation ShortcutClient

@synthesize name;
@synthesize url;
@synthesize authenticated;
@synthesize delegate;

- (ShortcutClient *) initWithName: (NSString *) _name andURL: (NSString *) _url {
	if ((self = [super init])) {
		name = [_name retain];
        url = [_url retain];
        authenticated = NO;
		websocket = [[ZTWebSocket alloc] initWithURLString:_url delegate:self];
		channels = [[NSMutableDictionary alloc] init];
        listeningChannels = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void) terminate {
	NSLog(@"terminate: %@", websocket.url);
	if (websocket.connected) {
		[websocket close];
        authenticated = NO;
        [channels removeAllObjects];
        [listeningChannels removeAllObjects];
	}
}

- (void) dealloc {
	[self terminate];
    [name release];
    [url release];
	[websocket release];
	[channels release];
    [listeningChannels release];
	[super dealloc];
}

- (NSArray *) getAllChannelKeys {
    return [channels allKeys];
}

- (void)webSocket:(ZTWebSocket*)webSocket didFailWithError:(NSError*)error {
	NSLog(@"didFailWithError: %@, %@", webSocket.url, error);
	if (delegate && [delegate respondsToSelector:@selector(onError:)]) {
		[delegate onError: error];
	}
}

- (void)webSocketDidOpen:(ZTWebSocket*)webSocket {
	//NSLog(@"didOpen: %@", webSocket.url);
	if (delegate && [delegate respondsToSelector:@selector(onOpen)]) {
		[delegate onOpen];
	}
}

- (void)webSocketDidClose:(ZTWebSocket*)webSocket {
	//NSLog(@"didClose: %@", webSocket.url);
	[self terminate];
	if (delegate && [delegate respondsToSelector:@selector(onClose)]) {
		[delegate onClose];
	}
}

- (void)webSocket:(ZTWebSocket*)webSocket didReceiveMessage:(NSString*)message {
	//NSLog(@"didReceiveMessage: %@, %@", webSocket.url, message);
    if ([SC_ACK isEqualToString:message]) {
        authenticated = YES;
        if (delegate && [delegate respondsToSelector:@selector(onACK)]) {
            [delegate onACK];
        }			
    } else if ([SC_NAK isEqualToString:message]){
        authenticated = NO;
        if (delegate && [delegate respondsToSelector:@selector(onNAK)]) {
            [delegate onNAK];
        }			
    } else {
        NSDictionary *msg = [ShortcutMsg jsonDecode: message];
        NSString *op = [msg valueForKey: SC_OP];
        NSString *channel = [msg valueForKey: SC_CHANNEL];
        NSDictionary *data = [msg valueForKey: SC_DATA];
        if ([SC_NOTIFY isEqualToString: op] == YES) {
            NSString *type = [data valueForKey: SC_TYPE];
            if ([SC_LISTENING isEqualToString:type]) {
                [listeningChannels addObject:channel];
            } else if ([SC_CLOSED isEqualToString:type]){
                [listeningChannels removeObject:channel];
            }	
            if (delegate && [delegate respondsToSelector:@selector(onNotify:withData:)]) {
                [delegate onNotify:channel withData:data];
            }			
        } else if ([SC_PROTOCOL isEqualToString: op] == YES) {
            if ([channels valueForKey:channel]) {
                [channels setValue:data forKey:channel];
                if (delegate && [delegate respondsToSelector:@selector(onProtocolUpdate:)]) {
                    [delegate onProtocolUpdate:channel];
                }	            
            } else {                
                [channels setValue:data forKey:channel];
                if (delegate && [delegate respondsToSelector:@selector(onProtocolNew:)]) {
                    [delegate onProtocolNew:channel];
                }	            
            }		
        } else {
            NSLog(@"BAD OP: %@", op);
        }
    }
}

- (void)webSocketDidSendMessage:(ZTWebSocket*)webSocket {
	//NSLog(@"webSocketDidSendMessage: %@, %@", webSocket.url);
}


- (void) listenChannel: (NSString *) channel {
    if ([listeningChannels containsObject:channel] == NO) {
        [self _sendMessage: SC_LISTEN toChannel: channel withData: nil];
    }
}

- (void) controlChannel: (NSString *) channel
				withCmd: (NSString *) cmd
				andArgs: (NSMutableDictionary *) args {
	if (! args) {
		args = [[[NSMutableDictionary alloc] init] autorelease];
	}
	[args setValue: cmd forKey: SC_CMD];
	[self _sendMessage: SC_CONTROL toChannel: channel withData: args];
}


- (void) openSocket {
	if (websocket.connected) {
		NSLog(@"openSocket on an already opened websocket");
        [self webSocketDidOpen:websocket];
	} else {
        authenticated = NO;
		[websocket open];
	}
}

- (void) _sendMessage: (NSString *) op 
			toChannel: (NSString *) channel
			  withData: (NSDictionary *) data {
	if (websocket.connected) {
		NSMutableDictionary *msg = [[[NSMutableDictionary alloc] init] autorelease];
		[msg setValue: op forKey: SC_OP];
		[msg setValue: channel forKey: SC_CHANNEL];
		if (data != nil) {
			[msg setValue:data forKey: SC_DATA];
		}
		[websocket send:[ShortcutMsg jsonEncode: msg]];
	} else {
		NSLog(@"_sendMessage failed due to unconnected websocket");
	}
}

- (void) authenticate: (NSString *) authCode {
	if (websocket.connected) {
		[websocket send:authCode];
	} else {
		NSLog(@"authenticate failed due to unconnected websocket");
	}
}

- (NSDictionary *) getProtocol: (NSString *) channel {
    return [channels valueForKey:channel];
}

@end
