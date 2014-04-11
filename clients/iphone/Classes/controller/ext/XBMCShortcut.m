//
//  XBMCShortcut.m
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "XBMCShortcut.h"


@implementation XBMCShortcut

- (NSString *) getTitle {
	return @"XBMC";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"ext-xbmc-shortcut-icon.jpg"];
}

-(NSArray *)getKeys {
	NSArray *result = 
	[NSArray arrayWithObjects:
	 //Row 1
	 [NSArray arrayWithObjects: @"escape", nil ],
	 [NSArray arrayWithObjects: @"o", nil ], 
	 [NSArray arrayWithObjects: @"s", nil ], 
	 //Row 2
	 [NSArray arrayWithObjects: @"backspace", nil ], 
	 [NSArray arrayWithObjects: @"up", @"", @"true", nil ], 
	 [NSArray arrayWithObjects: @"c", nil ], 
	 //Row 3
	 [NSArray arrayWithObjects: @"left", @"", @"true", nil ], 
	 [NSArray arrayWithObjects: @"return", nil ], 
	 [NSArray arrayWithObjects: @"right", @"", @"true", nil ], 
	 //Row 4
	 [NSArray arrayWithObjects: @"m", nil ], 
	 [NSArray arrayWithObjects: @"down", @"", @"true", nil ], 
	 [NSArray arrayWithObjects: @"i", nil ], 
	 nil];
	return result;
}

@end
