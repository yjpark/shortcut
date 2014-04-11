//
//  ShortcutClient.h
//  Shortcut
//
//  Created by YJ Park on 9/26/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZTWebSocket.h"
#import "ShortcutMsg.h"

@protocol ShortcutClientDelegate<NSObject>
@optional 
- (void) onOpen;
- (void) onClose;
- (void) onError: (NSError*)error;
- (void) onACK;
- (void) onNAK;
- (void) onNotify: (NSString *) channel
		  withData: (NSDictionary *) data;
- (void) onProtocolNew: (NSString *) channel;
- (void) onProtocolUpdate: (NSString *) channel;
@end

@interface ShortcutClient : NSObject<ZTWebSocketDelegate> {
	NSString *name;
    NSString *url;
	ZTWebSocket *websocket;
    BOOL authenticated;
    NSMutableDictionary *channels;
    NSMutableSet *listeningChannels;
	id<ShortcutClientDelegate> delegate;
}
@property (readonly) NSString *name;
@property (readonly) NSString *url;
@property (readonly) BOOL authenticated;
@property (nonatomic, assign) id<ShortcutClientDelegate> delegate;

- (ShortcutClient *) initWithName: (NSString *) _name andURL: (NSString *) _url;
- (void) terminate;
- (void) openSocket;
- (void) authenticate: (NSString *) authCode;
- (void) listenChannel: (NSString *) channel;
- (void) controlChannel: (NSString *) channel
				withCmd: (NSString *) cmd
				andArgs: (NSMutableDictionary *) args;

- (void) _sendMessage: (NSString *) op 
			toChannel: (NSString *) channel
			  withData: (NSDictionary *) data;
- (NSArray *) getAllChannelKeys;
- (NSDictionary *) getProtocol: (NSString *) channel;
@end
