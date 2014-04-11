//
//  ShortcutController.h
//  Shortcut
//
//  Created by YJ Park on 9/28/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShortcutMsg.h";
#import "ShortcutClient.h"

#define SC_SHORTCUT_CELL_WIDTH 80
#define SC_SHORTCUT_CELL_HEIGHT 80
#define SC_SHORTCUT_ICON_WIDTH 64
#define SC_SHORTCUT_ICON_HEIGHT 64

@class ShortcutModel;
@class ShortcutUtils;
@class ShortcutController;

@protocol ShortcutDelegate<NSObject>
@optional 
- (void) onShortcutDone: (ShortcutController *)shortcutController;
@end

//http://stackoverflow.com/questions/823080/creating-a-loading-view-using-iphone-sdk
@interface UIProgressHUD : NSObject 
- (UIProgressHUD *) initWithWindow: (UIView*)aWindow; 
- (void) show: (BOOL)aShow; 
- (void) setText: (NSString*)aText; 
@end

@interface ShortcutController : UIViewController {
	ShortcutModel *model;
	ShortcutClient *client;
	NSMutableDictionary *channels;
	NSArray *requiredChannelTypes;
	UIImageView *icon;
    id<ShortcutDelegate> delegate;
    
    UIProgressHUD *progressHUD;
}
@property (nonatomic, retain) NSArray *requiredChannelTypes;
@property (nonatomic, retain) id<ShortcutDelegate> delegate;
@property (readonly) UIImageView *icon;

+ (BOOL) createShortcut: (NSString *) newChannel
			allChannels: (NSArray *) allChannels
				require: (NSArray *) requiredChannelTypes;
+ (BOOL) isChannel: (NSString *) channel inTypes: (NSArray *) types;
+ (BOOL) isChannel: (NSString *) channel hasType: (NSString *) type;
+ (BOOL) isType: (NSString *) type inChannels: (NSArray *) channels;

- (void) listenOnClient: (ShortcutClient *) _client;
- (void) control: (NSString *) type withCmd: (NSString *) cmd withArgs: (NSMutableDictionary *) args;
- (void) tapKey: (NSString *) key withModifiers: (NSString *) modifiers;
- (void) pressKey: (NSString *) key withModifiers: (NSString *) modifiers;
- (void) releaseKey: (NSString *) key withModifiers: (NSString *) modifiers;
- (void) typeString: (NSString *) str;

- (BOOL) isModal;
- (IBAction) onDone;

- (void) hideProgressHUD;
- (void) showProgressHUD;
    
// By subclasses
+ (NSArray *) getRequiredChannalTypes;

- (NSString *) getNibName;
- (NSString *) getTitle;
- (UIImage *) getIconImage;
- (void) onInit;
- (void) onConnect;
- (void) onProtocolUpdate: (NSString *) channel;
- (void) onData: (NSString *) channel
		 withData: (NSDictionary *) data;
- (void) onError: (NSString *) channel
         withData: (NSDictionary *) data;
- (void) onListening: (NSString *) channel
         withData: (NSDictionary *) data;
- (void) onClosed: (NSString *) channel
         withData: (NSDictionary *) data;

- (NSDictionary *) getProtocolByType: (NSString *) type;
@end
