    //
//  KeyboardController.m
//  Shortcut
//
//  Created by YJ Park on 9/30/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "KeyShortcutController.h"


@implementation KeyShortcutController
@synthesize keysView;

- (NSString *) getNibName {
	return nil;
}

- (void) initConsts {
	ALL_KEY_IMAGES = [[NSDictionary dictionaryWithObjectsAndKeys:
					  @"F1.png", @"f1",
					  @"F2.png", @"f2",
					  @"F3.png", @"f3",
					  @"F4.png", @"f4",
					  @"F5.png", @"f5",
					  @"F6.png", @"f6",
					  @"F7.png", @"f7",
					  @"F8.png", @"f8",
					  @"F9.png", @"f9",
					  @"F10.png", @"f10",
					  @"F11.png", @"f11",
					  @"F11.png", @"f12",
					  @"LAK.png", @"left",
					  @"RAK.png", @"right",
					  @"UAK.png", @"up",
					  @"DAK.png", @"down",
					  @"UAK.png", @"pageup",
					  @"DAK.png", @"pagedown",
					  @"LAK.png", @"home",
					  @"RAK.png", @"end",
					  @"DELETE.png", @"delete",
					  @"ENTER.png", @"return",
					  @"ESC.png", @"escape",
					  @"DELETE.png", @"backspace",
					  @"CAPSLOK.png", @"capslock",
					  @"CTRL.png", @"control",
					  @"SHFTL.png", @"shift",
					  @"ALT.png", @"meta",
					  @"CMD.png", @"alt",
					  //display only
					  @"SPACE.png", @" ",
					  @"TILD.png", @"`",
					  @"MINUS.png", @"-",
					  @"PLUS.png", @"=",
					  @"BRKT.png", @"[",
					  @"BRKT2.png", @"]",
					  @"CMMA.png", @",",
					  @"AP.png", @".",
					  @"QUOTE.png", @"'",
					  @"SYMBL.png", @";",
					  @"BSlash.png", @"\\",
					  @"Tab.png", @"\t",
					  @"QUEM.png", @"/",
				  nil] retain];
				  
	ALL_MODIFIER_IMAGES = [[NSDictionary dictionaryWithObjectsAndKeys: nil] retain];
}				  

-(void) initButtons {
	[self initConsts];
	NSLog(@"keysView = %@, view = %@", self.keysView, self.view);
	if (self.keysView == nil) {
		self.keysView = self.view;
	}
	[self setButtonsView: self.keysView];
	keys = [[self getKeys] retain];
	for (int i = 0; i < [keys count]; i++) {
		CGRect frame = [self getKeyFrame: i];
		NSArray *buttonImages = [self getKeyImage: i];
		[super addButtonWithFrame: frame
					  normalImage: [buttonImages objectAtIndex:0]
				   highlightImage: [buttonImages objectAtIndex:1]];
	}
}

- (NSArray *) getKeyImage: (NSUInteger) index {
	NSArray *key = [keys objectAtIndex: index];
	NSString *keyStr = [key objectAtIndex: 0];
	NSUInteger len = [key count];
	NSString *normalImage = (len > 4) ? [key objectAtIndex: 4] : nil;
	NSString *highlightImage = (len > 5) ? [key objectAtIndex: 5] : nil;
	if (normalImage == nil) {
		normalImage = [self getKeyImage:keyStr highlight: NO];
	}
	if (highlightImage == nil) {
		highlightImage = [self getKeyImage:keyStr highlight: YES];
	}	
	NSArray *result = [NSArray arrayWithObjects: normalImage, highlightImage, nil];
	return result;
}

- (NSString *) getKeyImage: (NSString *) keyStr highlight: (BOOL) highlight {
	NSString *result = [ALL_KEY_IMAGES valueForKey: keyStr];
	if (result == nil) {
		result = [NSString stringWithFormat:@"%@.png", [[keyStr substringToIndex: 1] uppercaseString]];
	}
	if (result == nil) {
		result = @"K14.png";
	}
	//NSLog(@"image = %@, %@", keyStr, result);
	return result;
}

-(void) dealloc {
	[ALL_KEY_IMAGES release];
	[ALL_MODIFIER_IMAGES release];
	[keys release];
	[super dealloc];
}

-(void) onButtonDown: (NSUInteger) index {
	NSArray *key = [keys objectAtIndex:index];
	NSString *keyStr = [key objectAtIndex: 0];
	NSUInteger len = [key count];
	NSString *keyModifier = (len > 1) ? [key objectAtIndex: 1] : nil;
	NSString *keyHold = (len > 2) ? [key objectAtIndex: 2] : nil;
	NSString *keyType = (len > 3) ? [key objectAtIndex: 3] : nil;
	NSLog(@"onButtonDown: %@, %@, %@, %@", keyStr, keyModifier, keyHold, keyType);
	if ([@"true" isEqualToString: keyType]) {
	} else {
		if ([@"true" isEqualToString: keyHold]) {
			[self pressKey:keyStr withModifiers:keyModifier];		
		}
	}
}

-(void) onButtonUp: (NSUInteger) index {
	NSArray *key = [keys objectAtIndex:index];
	NSString *keyStr = [key objectAtIndex: 0];
	NSUInteger len = [key count];
	NSString *keyModifier = (len > 1) ? [key objectAtIndex: 1] : nil;
	NSString *keyHold = (len > 2) ? [key objectAtIndex: 2] : nil;
	NSString *keyType = (len > 3) ? [key objectAtIndex: 3] : nil;
	NSLog(@"onButtonUp: %@, %@, %@, %@", keyStr, keyModifier, keyHold, keyType);
	if ([@"true" isEqualToString: keyType]) {
		[self typeString:keyStr];
	} else {
		if ([@"true" isEqualToString: keyHold]) {
			[self releaseKey:keyStr withModifiers:keyModifier];		
		} else {
			[self tapKey:keyStr withModifiers:keyModifier];		
		}
	}
}

-(void) onButtonDragEnter:(NSUInteger) index {
	UIButton *button = [buttons objectAtIndex:index];
	button.highlighted = YES;
}

-(void) onButtonDragExit:(NSUInteger) index {
	UIButton *button = [buttons objectAtIndex:index];
	button.highlighted = NO;
}

@end
