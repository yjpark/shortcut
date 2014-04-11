//
//  ShortcutController.m
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ButtonShortcutController.h"


@implementation ButtonShortcutController

- (ButtonShortcutController *) init {
	if ((self = [super init])) {
		buttons = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) viewDidLoad {
	[self initButtons];
}

- (void) dealloc {
	[touchView release];
	[buttonsView release];
	[buttons release];
	[super dealloc];
}

+ (NSArray *) getRequiredChannalTypes {
	return [NSArray arrayWithObjects: @"keyboard", nil];
}

-(UIButton *) addButtonWithFrame: (CGRect) frame
						 normalImage: (NSString *) normalImage 
					  highlightImage: (NSString *) highlightImage {
	UIButton *result = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[result setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
	[result setImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
	result.frame = frame;
	[buttons addObject:result];
	[buttonsView addSubview:result];
	[buttonsView bringSubviewToFront:touchView];
	return result;
}

- (void) setButtonsView: (UIView *) _buttonsView {
	buttonsView = [_buttonsView retain];
	touchView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	touchView.frame = CGRectMake(0, 
								 0, 
								 buttonsView.frame.size.width, 
								 buttonsView.frame.size.height);
	[buttonsView addSubview:touchView];
	[touchView addTarget:self action:@selector(onTouchDown:event:)
	 forControlEvents:(UIControlEvents)UIControlEventTouchDown];
	[touchView addTarget:self action:@selector(onTouchUpInside:event:)
		forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
	[touchView addTarget:self action:@selector(onTouchUpOutside:event:)
		forControlEvents:(UIControlEvents)UIControlEventTouchUpOutside];
	[touchView addTarget:self action:@selector(onTouchDrag:event:)
	 forControlEvents:(UIControlEvents)UIControlEventTouchDragInside];
}

-(CGPoint) getTouchPoint: (UIEvent *)event {
	NSSet *touches = [event touchesForView: touchView];
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint result = [touch locationInView: touchView];
		return result;
	} else {
		NSLog(@"Not dealing with multi touch now.");
		return CGPointMake(-1, -1);
	}
}

- (int) getButtonIndex: (UIEvent *)event {
	CGPoint pos = [self getTouchPoint: event];
	for (int i = 0; i < [buttons count]; i++) {
		UIButton *button = [buttons objectAtIndex:i];
		if (CGRectContainsPoint(button.frame, pos)) {
			return i;
		}
	}
	return -1;
}

-(IBAction) onTouchDown:(id)sender event:(UIEvent*)event {
	//NSLog(@"onTouchDown %@", sender);
	int index = [self getButtonIndex:event];
	if (index >= 0) {
		lastDragIndex = index;
		[self onButtonDragEnter:index];
		[self onButtonDown:index];
	}
}

-(IBAction) onTouchDrag:(id)sender event:(UIEvent*)event {
	//NSLog(@"onTouchDrag %@", sender);
	int index = [self getButtonIndex:event];
	if ((index >= 0) && (lastDragIndex != index)) {
		if (lastDragIndex >= 0) {
			[self onButtonDragExit:lastDragIndex];
		}
		lastDragIndex = index;
		[self onButtonDragEnter:index];
	}
}

-(IBAction) onTouchUpInside:(id)sender event:(UIEvent*)event {
	//NSLog(@"onTouchUpInside %@", sender);
	int index = [self getButtonIndex:event];
	if (lastDragIndex >= 0) {
		[self onButtonDragExit:lastDragIndex];
	}
	if (index >= 0) {
		[self onButtonUp:index];
	}
}

-(IBAction) onTouchUpOutside:(id)sender event:(UIEvent*)event {
	//NSLog(@"onTouchUpOutside %@", sender);
	if (lastDragIndex >= 0) {
		[self onButtonDragExit:lastDragIndex];
	}
}

@end
