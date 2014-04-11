//
//  XBMCShortcut.m
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "GoogleReaderShortcut.h"


@implementation GoogleReaderShortcut

- (NSString *) getTitle {
	return @"Google Reader";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"ext-google-reader-shortcut-icon.png"];
}

-(NSArray *)getKeys {
	NSArray *result = 
	[NSArray arrayWithObjects:
	 //Row 1
	 [NSArray arrayWithObjects: @"f", nil ], 
	 [NSArray arrayWithObjects: @"u", nil ], 
	 [NSArray arrayWithObjects: @"a", nil ], 
	 [NSArray arrayWithObjects: @"a", @"S", nil ], 
	 //Row 2
	 [NSArray arrayWithObjects: @"x", @"S", nil ], 
	 [NSArray arrayWithObjects: @"1", nil ], 
	 [NSArray arrayWithObjects: @"2", nil ], 
	 [NSArray arrayWithObjects: @"r", nil ], 
	 //Row 3
	 [NSArray arrayWithObjects: @"o", @"S", nil ], 
	 [NSArray arrayWithObjects: @"o", nil ], 
	 [NSArray arrayWithObjects: @"s", nil ], 
	 [NSArray arrayWithObjects: @"v", nil ], 
	 //Row 4
	 [NSArray arrayWithObjects: @"p", @"S", nil ], 
	 [NSArray arrayWithObjects: @"k", nil ], 
	 [NSArray arrayWithObjects: @" ", @"S", nil ], 
	 [NSArray arrayWithObjects: @"p", nil ], 
	 //Row 5
	 [NSArray arrayWithObjects: @"n", @"S", nil ], 
	 [NSArray arrayWithObjects: @"j", nil ], 
	 [NSArray arrayWithObjects: @" ", nil ], 
	 [NSArray arrayWithObjects: @"n", nil ], 
	 nil];
	return result;
}

@end
