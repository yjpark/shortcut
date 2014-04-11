//
//  QwertyKeyboardController.m
//  Shortcut
//
//  Created by YJ Park on 10/3/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "QwertyKeyboardController.h"

@implementation QwertyKeyboardController
@synthesize toolBar;

- (void) initButtons {
	toolBar.title = [self getTitle];
	[super initButtons];
	preview = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.view addSubview: preview];
	[self.view bringSubviewToFront:preview];
}

- (CGRect) getKeyFrame: (NSUInteger) index {
	int row = index / 14;
	int col = index % 14;
	int x = col * 34 + 3;
	int y = row * 40 + 10;
	CGRect frame = CGRectMake(x, y, 32, 36);
	return frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIDeviceOrientationLandscapeRight){
		return YES;
	} else {
		return NO;
	}
}

- (BOOL) isModal {
	return YES;
}

- (NSString *) getTitle {
	return @"Keyboard";
}

- (NSString *) getNibName {
	return @"core-keyboard";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"core-keyboard-icon.jpg"];
}

-(NSArray *)getKeys {
	NSArray *result = 
	[NSArray arrayWithObjects:
	 //Row 1
	 [NSArray arrayWithObjects: @"escape", nil ], 
	 [NSArray arrayWithObjects: @"f1", nil ], 
	 [NSArray arrayWithObjects: @"f2", nil ], 
	 [NSArray arrayWithObjects: @"f3", nil ], 
	 [NSArray arrayWithObjects: @"f4", nil ], 
	 [NSArray arrayWithObjects: @"f5", nil ], 
	 [NSArray arrayWithObjects: @"f6", nil ], 
	 [NSArray arrayWithObjects: @"f7", nil ], 
	 [NSArray arrayWithObjects: @"f8", nil ], 
	 [NSArray arrayWithObjects: @"f9", nil ], 
	 [NSArray arrayWithObjects: @"f10", nil ], 
	 [NSArray arrayWithObjects: @"f11", nil ], 
	 [NSArray arrayWithObjects: @"f12", nil ], 
	 [NSArray arrayWithObjects: @"delete", nil ], 
	 //Row 2
	 [NSArray arrayWithObjects: @"`", nil ], 
	 [NSArray arrayWithObjects: @"1", nil ], 
	 [NSArray arrayWithObjects: @"2", nil ], 
	 [NSArray arrayWithObjects: @"3", nil ], 
	 [NSArray arrayWithObjects: @"4", nil ], 
	 [NSArray arrayWithObjects: @"5", nil ], 
	 [NSArray arrayWithObjects: @"6", nil ], 
	 [NSArray arrayWithObjects: @"7", nil ], 
	 [NSArray arrayWithObjects: @"8", nil ], 
	 [NSArray arrayWithObjects: @"9", nil ], 
	 [NSArray arrayWithObjects: @"0", nil ], 
	 [NSArray arrayWithObjects: @"-", nil ], 
	 [NSArray arrayWithObjects: @"=", nil ], 
	 [NSArray arrayWithObjects: @"backspace", nil ], 
	 //Row 3
	 [NSArray arrayWithObjects: @"\t", nil ], 
	 [NSArray arrayWithObjects: @"q", nil ], 
	 [NSArray arrayWithObjects: @"w", nil ], 
	 [NSArray arrayWithObjects: @"e", nil ], 
	 [NSArray arrayWithObjects: @"r", nil ], 
	 [NSArray arrayWithObjects: @"t", nil ], 
	 [NSArray arrayWithObjects: @"y", nil ], 
	 [NSArray arrayWithObjects: @"u", nil ], 
	 [NSArray arrayWithObjects: @"i", nil ], 
	 [NSArray arrayWithObjects: @"o", nil ], 
	 [NSArray arrayWithObjects: @"p", nil ], 
	 [NSArray arrayWithObjects: @"[", nil ], 
	 [NSArray arrayWithObjects: @"]", nil ], 
	 [NSArray arrayWithObjects: @"\\", nil ], 
	 //Row 4
	 [NSArray arrayWithObjects: @"capslock", nil ], 
	 [NSArray arrayWithObjects: @"a", nil ], 
	 [NSArray arrayWithObjects: @"s", nil ], 
	 [NSArray arrayWithObjects: @"d", nil ], 
	 [NSArray arrayWithObjects: @"f", nil ], 
	 [NSArray arrayWithObjects: @"g", nil ], 
	 [NSArray arrayWithObjects: @"h", nil ], 
	 [NSArray arrayWithObjects: @"j", nil ], 
	 [NSArray arrayWithObjects: @"k", nil ], 
	 [NSArray arrayWithObjects: @"l", nil ], 
	 [NSArray arrayWithObjects: @";", nil ], 
	 [NSArray arrayWithObjects: @"'", nil ], 
	 [NSArray arrayWithObjects: @"return", nil ], 
	 [NSArray arrayWithObjects: @"return", nil ], 
	 //Row 5
	 [NSArray arrayWithObjects: @"shift", nil ], 
	 [NSArray arrayWithObjects: @"z", nil ], 
	 [NSArray arrayWithObjects: @"x", nil ], 
	 [NSArray arrayWithObjects: @"c", nil ], 
	 [NSArray arrayWithObjects: @"v", nil ], 
	 [NSArray arrayWithObjects: @"b", nil ], 
	 [NSArray arrayWithObjects: @"n", nil ], 
	 [NSArray arrayWithObjects: @"m", nil ], 
	 [NSArray arrayWithObjects: @",", nil ], 
	 [NSArray arrayWithObjects: @".", nil ], 
	 [NSArray arrayWithObjects: @"/", nil ], 
	 [NSArray arrayWithObjects: @"home", nil ], 
	 [NSArray arrayWithObjects: @"up", nil ], 
	 [NSArray arrayWithObjects: @"end", nil ], 
	 //Row 6
	 [NSArray arrayWithObjects: @"control", nil ], 
	 [NSArray arrayWithObjects: @"meta", nil ], 
	 [NSArray arrayWithObjects: @"alt", nil ], 
	 [NSArray arrayWithObjects: @"reset", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @"pageup", nil ], 
	 [NSArray arrayWithObjects: @"pagedown", nil ], 
	 [NSArray arrayWithObjects: @"left", nil ], 
	 [NSArray arrayWithObjects: @"down", nil ], 
	 [NSArray arrayWithObjects: @"right", nil ], 
	 nil];
	return result;
}

-(void) onButtonDragEnter:(NSUInteger) index {
	NSArray *buttonImages = [self getKeyImage: index];
	[preview setImage:[UIImage imageNamed:[buttonImages objectAtIndex:0]] forState:UIControlStateNormal];
	CGRect frame = [self getKeyFrame: index];
	frame.origin.y = frame.origin.y - 64 + self.keysView.frame.origin.y;
	if ((index % 14) == 13) {
		frame.origin.x -= 32;
	}
	frame.size.width = 64;
	frame.size.height = 64;
	preview.frame = frame;
	preview.hidden = NO;
}

-(void) onButtonDragExit:(NSUInteger) index {
	preview.hidden = YES;
}

-(void) updateToggleKey: (NSUInteger) index {
	UIButton *button = [buttons objectAtIndex: index];
	button.highlighted = !button.highlighted;
}	

-(BOOL) isToggleKey: (NSUInteger) index {
	if ((index == 42)||
		(index == 56)||
		(index == 70)||
		(index == 71)||
		(index == 72)||
		(index == 73)){
		return YES;
	}
	return NO;
}

-(NSString *) getKeyModifier{
	NSMutableString *result = [NSMutableString stringWithCapacity: 4];
	UIButton *button = [buttons objectAtIndex:42];
	if (button.highlighted) {
		[result appendString: @"S"];
	} else {
		button = [buttons objectAtIndex:56];
		if (button.highlighted) {
			[result appendString: @"S"];			
		}
	}
	button = [buttons objectAtIndex:70];
	if (button.highlighted) {
		[result appendString: @"C"];			
	}
	button = [buttons objectAtIndex:71];
	if (button.highlighted) {
		[result appendString: @"A"];			
	}
	button = [buttons objectAtIndex:72];
	if (button.highlighted) {
		[result appendString: @"M"];			
	}
	return result;
}

-(void) resetToggleKeys {
	UIButton *button = [buttons objectAtIndex:73];
	if (!button.highlighted) {
		button = [buttons objectAtIndex:56];
		button.highlighted = NO;
		button = [buttons objectAtIndex:70];
		button.highlighted = NO;
		button = [buttons objectAtIndex:71];
		button.highlighted = NO;
		button = [buttons objectAtIndex:72];
		button.highlighted = NO;
	}
}

-(void) onButtonDown: (NSUInteger) index {
}

-(void) onButtonUp: (NSUInteger) index {
	if ([self isToggleKey: index]) {
		[self updateToggleKey: index];
	} else {
		NSArray *key = [keys objectAtIndex:index];
		NSString *keyStr = [key objectAtIndex: 0];
		NSString *keyModifier = [self getKeyModifier];
		[self tapKey:keyStr withModifiers:keyModifier];
		[self resetToggleKeys];
	}
}

@end
