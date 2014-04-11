//
//  MouseController.h
//  Shortcut
//
//  Created by YJ Park on 9/30/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutController.h"

@interface MouseController : ShortcutController {
	UIButton *pad;
	CGPoint touchDownPosition;
}
@property (nonatomic, retain) IBOutlet UIButton *pad;

-(IBAction) onLeft;
-(IBAction) onMiddle;
-(IBAction) onRight;
-(IBAction) onDoubleClick;

-(IBAction) onTouchDown:(id)sender event:(UIEvent*)event;
-(IBAction) onTouchDrag:(id)sender event:(UIEvent*)event;
-(IBAction) onTouchUp:(id)sender event:(UIEvent*)event;

- (void) onPosition: (NSDictionary *) position withData: (NSDictionary *) data;

@end
