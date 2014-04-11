//
//  KeyboardController.h
//  Shortcut
//
//  Created by YJ Park on 9/30/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ButtonShortcutController.h"

@interface KeyShortcutController : ButtonShortcutController {
	NSDictionary *ALL_KEY_IMAGES;
	NSDictionary *ALL_MODIFIER_IMAGES;
	UIView *keysView;
	NSArray *keys;
}
@property (nonatomic, retain) IBOutlet UIView *keysView;

- (CGRect) getKeyFrame: (NSUInteger) index;
- (NSArray *) getKeyImage: (NSUInteger) index;
- (NSString *) getKeyImage: (NSString *) keyStr highlight: (BOOL) highlight;
// By subclasses
- (CGRect) getKeyFrame: (NSUInteger) index;
- (NSArray *) getKeys;

@end
