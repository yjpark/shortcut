//
//  SCTextSelection.m
//  Text-Selection
//
//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "SCAutoLookupDictionaryPlugin.h"


@implementation SCAutoLookupDictionaryPlugin

/**
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load {
	SCAutoLookupDictionaryPlugin* plugin = [SCAutoLookupDictionaryPlugin sharedInstance];

	NSLog(@"sc_SCAutoLookupDictionaryPlugin loaded");

	NSError* err = nil;
	/*
	BOOL result = [NSTextView 
		  jr_swizzleMethod:@selector(setSelectedRange:affinity:stillSelecting:) 
				withMethod:@selector(sc_setSelectedRange:affinity:stillSelecting:) 
					 error:&err];
	BOOL result = [NSResponder 
	 jr_swizzleMethod:@selector(validRequestorForSendType:returnType:) 
		   withMethod:@selector(sc_validRequestorForSendType:returnType:) 
				error:&err];
	BOOL result = [NSNotificationCenter 
 		     jr_swizzleMethod:@selector(postNotificationName:object:userInfo:) 
				   withMethod:@selector(sc_postNotificationName:object:userInfo:) 
			  		    error:&err];
	BOOL result = [NSPasteboard 
				   jr_swizzleMethod:@selector(setString:forType:) 
				   withMethod:@selector(sc_setString:forType:) 
				   error:&err];
	BOOL result = [NSApplication 
				   jr_swizzleMethod:@selector(validRequestorForSendType:returnType:) 
				   withMethod:@selector(sc_validRequestorForSendType:returnType:) 
				   error:&err];
	BOOL result = [NSMenu 
				   jr_swizzleMethod:@selector(update) 
				   withMethod:@selector(sc_update) 
				   error:&err];
	if (result) {// we want this to be visible to end users, too :)
		BOOL result = [NSMenuItem 
				   jr_swizzleMethod:@selector(setHidden:) 
				   withMethod:@selector(sc_setHidden:) 
				   error:&err];
	}
	 */	
	BOOL result = [NSNotificationCenter 
				   jr_swizzleMethod:@selector(postNotificationName:object:userInfo:) 
				   withMethod:@selector(sc_postNotificationName:object:userInfo:) 
				   error:&err];
	
	if (!result) {// we want this to be visible to end users, too :)
		NSLog(@"sc_SCAutoLookupDictionaryPlugin install failed (error: %@).", err);
	} else {
		NSLog(@"sc_SCAutoLookupDictionaryPlugin installed");
	}
}

/**
 * @return the single static instance of the plugin object
 */
+ (SCAutoLookupDictionaryPlugin *) sharedInstance {
	static SCAutoLookupDictionaryPlugin* plugin = nil;
	
	if (plugin == nil)
		plugin = [[SCAutoLookupDictionaryPlugin alloc] init];
	
	return plugin;
}

@end

@implementation NSMenu(ShortCut)

- (void)sc_update {
	NSLog(@"sc_update, %@ ", self);
	return [self sc_update];
}

@end

@implementation NSMenuItem(ShortCut)

- (void)sc_setHidden:(BOOL)hidden {
	NSLog(@"sc_setHidden, %d, %@ ", hidden, self.title);
	return [self sc_setHidden:hidden];
}

@end

@implementation NSApplication(ShortCut)

- (id)sc_validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
	id result = [self sc_validRequestorForSendType:sendType returnType:returnType];
	if (result != nil) {
		NSLog(@"sc_validRequestorForSendType: %@", sendType);
		NSPasteboard      *pb;		
		pb = [NSPasteboard pasteboardWithUniqueName];
		NSArray *sendTypes = [NSArray arrayWithObject:sendType];
		if (sendType
			&& [result writeSelectionToPasteboard: pb
										 types: sendTypes] == NO) {
			NSRunAlertPanel(nil,
							@"sc_autoLookupDictionary: object failed to write to pasteboard",
							@"Continue", nil, nil);
		} else {
			NSString *selectedText = [pb stringForType:sendType];
			NSLog(@"sc_validRequestorForSendType: %@", selectedText);
			LookupDictionaryModel *model = [LookupDictionaryModel getInstance];
			[model lookup:selectedText];
		}
	} else {
		NSLog(@"sc_validRequestorForSendType = nil: %@", sendType);
	}
	return result;
}

@end

@implementation NSNotificationCenter(ShortCut) 

- (BOOL) sc_is_substring: (NSString *) sub of: (NSString *) total {
	BOOL result = NO;
	NSRange range = [total rangeOfString: sub];
	if ((range.location != NSNotFound) && (range.length > 0)) {
		result = YES;
	}
	return result;
}

- (BOOL) sc_should_lookup: notificationName{
	return 
	[self sc_is_substring:@"Selection" of:notificationName]
	|| [self sc_is_substring:@"NSApplicationWillUpdateNotification" of:notificationName]
	;
}

- (void)sc_postNotificationName:(NSString *)notificationName 
					  object:(id)notificationSender 
					userInfo:(NSDictionary *)userInfo {
	if ([self sc_should_lookup:notificationName]) {
		NSObject *sender = (NSObject *)notificationSender;
		LookupDictionaryModel *model = [LookupDictionaryModel getInstance];
		if ([model lookupAsService:sender]) {
		} else {
			NSApplication *application = [NSApplication sharedApplication];
			NSResponder   *resp = [[application keyWindow] firstResponder];
			NSObject *obj = [resp validRequestorForSendType:NSStringPboardType returnType:NSStringPboardType];
			//NSLog(@"sc_postNotificationName %@ validRequestorForSendType: %@, %@", notificationName, resp, obj);
			if (obj && [model lookupAsService:obj]) {
			} else {
				NSString *str = [self sc_getSelectedText:resp];
				if (str) {
					[model lookup: str];
				} else {
					//NSLog(@"sc_postNotificationName can not lookup: %@\nsender = %@\nresponder = %@", notificationName, sender, resp);
				}
			}
		}
	} else {
		//NSLog(@"sc_postNotificationName: unknown type: %@", notificationName);
	}
	[self sc_postNotificationName:notificationName 
						   object:notificationSender 
						 userInfo:userInfo];
}

- (NSString *)sc_getSelectedText:(NSResponder *)resp {
	NSString *result = nil;
	if ([resp respondsToSelector:@selector(selectedString)]) {
		//WebHTMLView
		result = [resp selectedString];
		//NSLog(@"sc_getSelectedText: %@ [WebHTMLView]: %@", result, resp);
	}
	return result;
}

/*
- (void) sc_setSelectedRange: (NSRange)charRange
				 affinity: (NSSelectionAffinity)affinity
		   stillSelecting: (BOOL)stillSelectingFlag {
	if ((charRange.length > 0) && !stillSelectingFlag) {
		NSString *selectedText = [self.string substringWithRange:charRange];
		NSLog(@"sc_setSelectedRange: %@", selectedText);
		LookupDictionaryModel *model = [LookupDictionaryModel getInstance];
		[model lookup:selectedText];
	}
	[self sc_setSelectedRange:charRange affinity:affinity stillSelecting:stillSelectingFlag];
}
*/
@end
