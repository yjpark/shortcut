//
//  ShortcutController.m
//  Shortcut
//
//  Created by YJ Park on 9/28/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutController.h"
#import "ShortcutModel.h"

@implementation ShortcutController
@synthesize requiredChannelTypes;
@synthesize icon;
@synthesize delegate;

+ (BOOL) createShortcut: (NSString *) newChannel
			allChannels: (NSArray *) allChannels
				require: (NSArray *) requiredChannelTypes {
	if ([ShortcutController isChannel: newChannel inTypes: requiredChannelTypes]) {
		for (NSString *type in requiredChannelTypes) {
			if (![ShortcutController isType: type inChannels: allChannels]) {
				return NO;
			}
		}
		return YES;
	}
	return NO;
}

+ (BOOL) isChannel: (NSString *) channel inTypes: (NSArray *) types {
	for (NSString *type in types) {
		if ([ShortcutController isChannel:channel hasType: type]) {
			return YES;
		}
	}
	return NO;
}

+ (BOOL) isChannel: (NSString *) channel hasType: (NSString *) type {
	NSString *channelType = [ShortcutMsg getChannelType: channel];
	//NSLog(@"isChannel: %@ hasType: %@ = %@, %d", channel, type, channelType, [channelType isEqualToString:type]);
	return [channelType isEqualToString:type];
}

+ (BOOL) isType: (NSString *) type inChannels: (NSArray *) channels {
	for (NSString *channel in channels) {
		if ([ShortcutController isChannel: channel hasType: type]) {
			return YES;
		}
	}
	return NO;
}
		
- (ShortcutController *) init {
	NSString *nibName = [self getNibName];
	if ((self = [super initWithNibName: nibName bundle: nil])) {
		model = [ShortcutModel getInstance];
		float xOffset = (SC_SHORTCUT_CELL_WIDTH - SC_SHORTCUT_ICON_WIDTH) / 2;
		float yOffset = (SC_SHORTCUT_CELL_HEIGHT - SC_SHORTCUT_ICON_HEIGHT) / 2;
		icon = [[UIImageView alloc] initWithFrame: CGRectMake(xOffset, yOffset, SC_SHORTCUT_ICON_WIDTH, SC_SHORTCUT_ICON_HEIGHT)];
		icon.image = [self getIconImage];
		self.title = [self getTitle];
		channels = [[NSMutableDictionary alloc] init];
        [self onInit];
	}
	return self;
}

- (void) dealloc {
    [progressHUD release]; 
	[client release];
	[channels release];
	[icon release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIDeviceOrientationPortrait){
		return YES;
	} else {
		return NO;
	}
}

- (BOOL) isModal {
	return NO;
}

-(IBAction) onDone {
    [self hideProgressHUD];
    if ([self isModal]) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
		[self.navigationController popViewControllerAnimated:YES];
    }
    if (delegate && [delegate respondsToSelector:@selector(onShortcutDone:)]) {
        [delegate onShortcutDone: self];
    }			    
}

- (void) listenOnClient: (ShortcutClient *) _client {
	[client release];
	client = [_client retain];
    NSArray *allChannels = [client getAllChannelKeys];
	[channels removeAllObjects];
	for (NSString *type in self.requiredChannelTypes) {
		for (NSString *channel in allChannels) {
			NSLog(@"%@, %@", channel, type);
			if ([ShortcutController isChannel: channel hasType: type]) {
				[client listenChannel: channel];
				[channels setValue:channel forKey:type];
			}
		}
	}
    [self onConnect];
}

- (void) control: (NSString *) type withCmd: (NSString *) cmd withArgs: (NSMutableDictionary *) args {
	NSString *channel = [channels valueForKey:type];
	if (!channel) {
		NSLog(@"control failed, channel not found, %@: %@", type, cmd);
	}
	[client controlChannel: channel withCmd: cmd andArgs: args];
}

- (void) tapKey: (NSString *) key withModifiers: (NSString *) modifiers {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 key, @"key",
								 modifiers, @"modifiers",
								 nil];
	[self control:@"keyboard" withCmd: @"tap" withArgs: args];			
}

- (void) pressKey: (NSString *) key withModifiers: (NSString *) modifiers {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 key, @"key",
								 modifiers, @"modifiers",
								 nil];
	[self control:@"keyboard" withCmd: @"press" withArgs: args];			
}

- (void) releaseKey: (NSString *) key withModifiers: (NSString *) modifiers {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 key, @"key",
								 modifiers, @"modifiers",
								 nil];
	[self control:@"keyboard" withCmd: @"release" withArgs: args];			
}

- (void) typeString: (NSString *) str {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 str, @"string",
								 nil];
	[self control:@"keyboard" withCmd: @"type" withArgs: args];			
}

- (NSDictionary *) getProtocolByType: (NSString *) type {
    NSDictionary *protocol = nil;
    NSString *channel = [channels valueForKey:type];
    if (channel) {
        protocol = [client getProtocol:channel];
    }
    return protocol;
}

- (void) hideProgressHUD { 
    if (progressHUD) {
        [progressHUD show:NO]; 
        [progressHUD release]; 
        progressHUD = nil;
    }
} 

- (void) showProgressHUD { 
    if (progressHUD) {
        return;
    }
    if (self.view.window) {
        progressHUD = [[UIProgressHUD alloc] initWithWindow:self.view.window]; 
        [progressHUD setText:@"Loading..."]; 
        [progressHUD show:YES]; 
    }
}
    
- (void) onInit {
}

- (void) onConnect {
}

- (void) onProtocolUpdate: (NSString *) channel {
}

- (void) onData: (NSString *) channel
       withData: (NSDictionary *) data {
}

- (void) onError: (NSString *) channel
        withData: (NSDictionary *) data {
}

- (void) onListening: (NSString *) channel
            withData: (NSDictionary *) data {
}

- (void) onClosed: (NSString *) channel
         withData: (NSDictionary *) data {
}

@end
