    //
//  MouseController.m
//  Shortcut
//
//  Created by YJ Park on 9/30/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "MouseController.h"


@implementation MouseController

@synthesize pad;

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

-(IBAction) onLeft {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 @"1", @"button", nil];
	[self control:@"mouse" withCmd: @"click" withArgs: args];
}

-(IBAction) onRight {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 @"2", @"button", nil];
	[self control:@"mouse" withCmd: @"click" withArgs: args];
}

-(IBAction) onMiddle {
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								 @"3", @"button", nil];
	[self control:@"mouse" withCmd: @"click" withArgs: args];
}

-(IBAction) onDoubleClick {
	[self control:@"mouse" withCmd: @"double_click" withArgs: nil];
}


-(IBAction) onTouchDown:(id)sender event:(UIEvent*)event {
	NSSet *touches = [event touchesForView: pad];
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		touchDownPosition = [touch locationInView: pad];
	} else {
		NSLog(@"Not dealing with multi touch now.");
	}
}

-(IBAction) onTouchDrag:(id)sender event:(UIEvent*)event {
	NSSet *touches = [event touchesForView: pad];
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint previous = [touch previousLocationInView: pad];
		CGPoint current = [touch locationInView: pad];
		//NSLog(@"previous = %.0f, %.0f, current = %.0f, %.0f", previous.x, previous.y, current.x, current.y);
		CGFloat x = current.x - previous.x;
		CGFloat y = current.y - previous.y;
		//NSLog(@"relative_move: %.0f, %.0f", x, y);
		NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
									 [NSString stringWithFormat:@"%.0f", x], @"x",
									 [NSString stringWithFormat:@"%.0f", y], @"y",
									 nil];
		[self control:@"mouse" withCmd: @"relative_move" withArgs: args];			
	} else {
		NSLog(@"Not dealing with multi touch now.");
	}
}

-(IBAction) onTouchUp:(id)sender event:(UIEvent*)event {
	NSSet *touches = [event touchesForView: pad];
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint current = [touch locationInView: pad];
		//NSLog(@"previous = %.0f, %.0f, current = %.0f, %.0f", touchDownPosition.x, touchDownPosition.y, current.x, current.y);
		CGFloat x = current.x - touchDownPosition.x;
		CGFloat y = current.y - touchDownPosition.y;
		if ((x < 1.5f) && (y < 1.5f)) {
			[self onLeft];
		}
	} else {
		NSLog(@"Not dealing with multi touch now.");
	}
}

+ (NSArray *) getRequiredChannalTypes {
	return [NSArray arrayWithObjects: @"mouse", nil];
}

- (NSString *) getNibName {
	return @"core-mouse";
}

- (NSString *) getTitle {
	return @"Mouse";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"core-mouse-icon.jpg"];
}

- (void) onNotify: (NSString *) channel
		 withData: (NSDictionary *) data {
	if ([ShortcutController isChannel:channel hasType:@"mouse"]) {
		NSDictionary *position = [data valueForKey: @"position"];
		if (position) {
			[self onPosition: position withData: data];
		}
	}
}

- (void) onPosition: (NSDictionary *) position withData: (NSDictionary *) data {
}

@end
