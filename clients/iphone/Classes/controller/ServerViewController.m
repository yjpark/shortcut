//
//  ServerViewController.m
//  Shortcut
//
//  Created by YJ Park on 9/27/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ServerViewController.h"

@implementation ServerViewController

#pragma mark -
#pragma mark Initialization

- (ServerViewController *) initWithClient: (ShortcutClient *)_client {
	if ((self = [self initWithNibName: nil bundle: nil])) {
		model = [ShortcutModel getInstance];
		client = [_client retain];
		client.delegate = self;
		shortcuts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
	[client release];
	[shortcuts release];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.title = client.name;
	[client openSocket];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIDeviceOrientationPortrait){
		return YES;
	} else {
		return NO;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


#pragma mark -
#pragma mark ShortcutClient delegate

- (void) onOpen {
	NSLog(@"onOpen[%@]", client.name);
    NSString *authCode = [model getDefault:AUTH_CODE_KEY forClient:client];
    if (authCode) {
        [client authenticate:authCode];
    } else {
        [self _authenticate];
    }
}

- (void) onNAK {
    [self _authenticate];
}

- (void) onClose {
	NSLog(@"onClose[%@]", client.name);
    @synchronized(shortcuts){
        NSArray *deadShortcuts = [shortcuts copy];
        for (ShortcutController *shortcut in deadShortcuts) {
            [self _removeShortcut: shortcut];
        }    
    }
}

- (void) onShortcutDone: (ShortcutController *)shortcutController {
}

- (void) onError: (NSError*)error {
	NSLog(@"onError[%@]: %@", client.name, error);
}

- (void) onNotify: (NSString *) channel
		 withData: (NSDictionary *) data {
	//NSLog(@"onNotify[%@] %@: %@", client.name, channel, data);
    NSMutableArray *deadShortcuts = [NSMutableArray array];
    NSString *type = [data valueForKey: SC_TYPE];
    @synchronized(shortcuts){
        for (ShortcutController *shortcut in shortcuts) {
            if ([ShortcutController isChannel:channel inTypes:shortcut.requiredChannelTypes]) {
                if ([SC_LISTENING isEqualToString:type]) {
                    [shortcut onListening: channel withData: data];
                } else if ([SC_CLOSED isEqualToString:type]){
                    [shortcut onClosed: channel withData: data];
                    [deadShortcuts addObject:shortcut];
                } else if ([SC_ERROR isEqualToString:type]){        
                    [shortcut onError: channel withData: data];
                } else {
                    [shortcut onData: channel withData: data];
                }	
            }
        }
        for (ShortcutController *shortcut in deadShortcuts) {
            [self _removeShortcut: shortcut];
        }
    }
}

- (void) onProtocolNew: (NSString *) channel {
	NSLog(@"onProtocolNew[%@] %@", client.name, channel);
	NSArray *newShortcuts = [model getNewShortcuts: channel allChannels: [client getAllChannelKeys]];
	for (ShortcutController *shortcut in newShortcuts) {
		[self _addShortcut: shortcut];
	}
}

- (void) onProtocolUpdate: (NSString *) channel {
	NSLog(@"onProtocolUpdate[%@] %@", client.name, channel);
    @synchronized(shortcuts){
        for (ShortcutController *shortcut in shortcuts) {
            if ([ShortcutController isChannel:channel inTypes:shortcut.requiredChannelTypes]) {
                [shortcut onProtocolUpdate: channel];
            }
        }
    }    
}

#pragma mark -
#pragma mark view related

- (void) _addShortcut: (ShortcutController *) shortcut {
	NSLog(@"_addShortcut: %@, %@", self.title, shortcut);
	[shortcut listenOnClient: client];
    shortcut.delegate = self;
	[shortcuts addObject:shortcut];
	[self.gridView reloadData];
}

- (void) _removeShortcut: (ShortcutController *) shortcut {
	NSLog(@"_removeShortcut: %@, %@", self.title, shortcut);
    if (self.navigationController.visibleViewController == shortcut) {
        [shortcut onDone];
    }
	[shortcuts removeObject:shortcut];
	[self.gridView reloadData];
}

#pragma mark -
#pragma mark AQGridView Related

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return (CGSizeMake(SC_SHORTCUT_CELL_WIDTH, SC_SHORTCUT_CELL_HEIGHT));
}
 
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [shortcuts count] );
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{    
    static NSString *CellIdentifier = @"ShortcutCell";
    
	AQGridViewCell * cell = [aGridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
		cell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0, 0, SC_SHORTCUT_CELL_WIDTH, SC_SHORTCUT_CELL_HEIGHT)
												  reuseIdentifier: CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	ShortcutController *shortcut = [shortcuts objectAtIndex:index];
	[cell.contentView addSubview: shortcut.icon];
    return cell;
}

- (NSUInteger) gridView: (AQGridView *) gridView willSelectItemAtIndex: (NSUInteger) index{
	ShortcutController *shortcut = [shortcuts objectAtIndex:index];
	if ([shortcut isModal]) {
		[self presentModalViewController:shortcut animated:YES];		
	} else {
		[self.navigationController pushViewController:shortcut animated:YES];
	}
	return NSNotFound;
}

#pragma mark -
#pragma mark Pop up for auth_code input

- (void) _authenticate {
    //http://junecloud.com/journal/code/displaying-a-password-or-text-entry-prompt-on-the-iphone.html
    UIAlertView *passwordAlert = [[UIAlertView alloc]
            initWithTitle:@"Auth Code" message:@"\n\n\n"
            delegate:self 
            cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
            otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    passwordLabel.font = [UIFont systemFontOfSize:16];
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.shadowColor = [UIColor blackColor];
    passwordLabel.shadowOffset = CGSizeMake(0,-1);
    passwordLabel.textAlignment = UITextAlignmentCenter;
    passwordLabel.text = self.title;
    [passwordAlert addSubview:passwordLabel];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    passwordImage.frame = CGRectMake(11,79,262,31);
    [passwordAlert addSubview:passwordImage];
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    passwordField.tag = 100;
    passwordField.font = [UIFont systemFontOfSize:18];
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.secureTextEntry = YES;
    passwordField.keyboardType = UIKeyboardTypeDecimalPad;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    //passwordField.delegate = self;
    [passwordField becomeFirstResponder];
    [passwordAlert addSubview:passwordField];
    
    //[passwordAlert setTransform:CGAffineTransformMakeTranslation(0,109)];
    [passwordAlert show];
    [passwordAlert release];
    [passwordImage release];
    [passwordField release];
    [passwordLabel release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UITextField *passwordField = (UITextField *)[alertView viewWithTag:100];
        NSString *authCode = passwordField.text;
        [model writeDefault:authCode forKey:AUTH_CODE_KEY forClient:client];
        [client authenticate:authCode];
    }
}

@end

