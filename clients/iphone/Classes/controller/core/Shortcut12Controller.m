//
//  Shortcut12Controller.m
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "Shortcut12Controller.h"


@implementation Shortcut12Controller

- (CGRect) getKeyFrame: (NSUInteger) index {
	int row = index / 3;
	int col = index % 3;
	int x = col * 100 + 20;
	int y = row * 100 + 20;
	CGRect frame = CGRectMake(x, y, 80, 80);
	return frame;
}

@end
