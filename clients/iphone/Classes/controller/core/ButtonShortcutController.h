//
//  ShortcutController.h
//  Shortcut
//
//  Created by YJ Park on 10/1/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutController.h"

@interface ButtonShortcutController : ShortcutController {
	UIView *buttonsView;
	UIButton *touchView;
	NSMutableArray *buttons;
	int lastDragIndex;
}

-(IBAction) onTouchDown:(id)sender event:(UIEvent*)event;
-(IBAction) onTouchDrag:(id)sender event:(UIEvent*)event;
-(IBAction) onTouchUpInside:(id)sender event:(UIEvent*)event;
-(IBAction) onTouchUpOutside:(id)sender event:(UIEvent*)event;

- (void) setButtonsView: (UIView *) _buttonsView;
- (UIButton *) addButtonWithFrame: (CGRect) frame
					 normalImage: (NSString *) normalImage 
				  highlightImage: (NSString *) highlightImage; 
//Provided by subclasses
-(void) initButtons;
-(void) onButtonDown: (NSUInteger) index;
-(void) onButtonUp: (NSUInteger) index;
-(void) onButtonDragEnter: (NSUInteger) index;
-(void) onButtonDragExit: (NSUInteger) index;

@end
