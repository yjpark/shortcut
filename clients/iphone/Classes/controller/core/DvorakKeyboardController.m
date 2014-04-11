//
//  DvorakKeyboardController.m
//  Shortcut
//
//  Created by YJ Park on 10/4/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "DvorakKeyboardController.h"


@implementation DvorakKeyboardController

- (NSString *) getTitle {
	return @"Dvorak Keyboard";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"core-dvorak-keyboard-icon.jpg"];
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
	 [NSArray arrayWithObjects: @"[", nil ], 
	 [NSArray arrayWithObjects: @"]", nil ], 
	 [NSArray arrayWithObjects: @"backspace", nil ], 
	 //Row 3
	 [NSArray arrayWithObjects: @"\t", nil ], 
	 [NSArray arrayWithObjects: @"'", nil ], 
	 [NSArray arrayWithObjects: @",", nil ], 
	 [NSArray arrayWithObjects: @".", nil ], 
	 [NSArray arrayWithObjects: @"p", nil ], 
	 [NSArray arrayWithObjects: @"y", nil ], 
	 [NSArray arrayWithObjects: @"f", nil ], 
	 [NSArray arrayWithObjects: @"g", nil ], 
	 [NSArray arrayWithObjects: @"c", nil ], 
	 [NSArray arrayWithObjects: @"r", nil ], 
	 [NSArray arrayWithObjects: @"l", nil ], 
	 [NSArray arrayWithObjects: @"/", nil ], 
	 [NSArray arrayWithObjects: @"=", nil ], 
	 [NSArray arrayWithObjects: @"\\", nil ], 
	 //Row 4
	 [NSArray arrayWithObjects: @"capslock", nil ], 
	 [NSArray arrayWithObjects: @"a", nil ], 
	 [NSArray arrayWithObjects: @"o", nil ], 
	 [NSArray arrayWithObjects: @"e", nil ], 
	 [NSArray arrayWithObjects: @"u", nil ], 
	 [NSArray arrayWithObjects: @"i", nil ], 
	 [NSArray arrayWithObjects: @"d", nil ], 
	 [NSArray arrayWithObjects: @"h", nil ], 
	 [NSArray arrayWithObjects: @"t", nil ], 
	 [NSArray arrayWithObjects: @"n", nil ], 
	 [NSArray arrayWithObjects: @"s", nil ], 
	 [NSArray arrayWithObjects: @"-", nil ], 
	 [NSArray arrayWithObjects: @"return", nil ], 
	 [NSArray arrayWithObjects: @"return", nil ], 
	 //Row 5
	 [NSArray arrayWithObjects: @"shift", nil ], 
	 [NSArray arrayWithObjects: @";", nil ], 
	 [NSArray arrayWithObjects: @"q", nil ], 
	 [NSArray arrayWithObjects: @"j", nil ], 
	 [NSArray arrayWithObjects: @"k", nil ], 
	 [NSArray arrayWithObjects: @"x", nil ], 
	 [NSArray arrayWithObjects: @"b", nil ], 
	 [NSArray arrayWithObjects: @"m", nil ], 
	 [NSArray arrayWithObjects: @"w", nil ], 
	 [NSArray arrayWithObjects: @"v", nil ], 
	 [NSArray arrayWithObjects: @"z", nil ], 
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

@end
