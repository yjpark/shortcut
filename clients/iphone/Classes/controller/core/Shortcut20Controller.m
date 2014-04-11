//
//  Shortcut20Controller.m
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "Shortcut20Controller.h"


@implementation Shortcut20Controller

- (CGRect) getKeyFrame: (NSUInteger) index {
	int row = index / 4;
	int col = index % 4;
	int x = col * 80 + 8;
	int y = row * 80 + 8;
	CGRect frame = CGRectMake(x, y, 64, 64);
	return frame;
}

@end
