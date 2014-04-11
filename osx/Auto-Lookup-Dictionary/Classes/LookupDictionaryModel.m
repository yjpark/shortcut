//
//  SCLookupDict.m
//  Auto-Lookup-Dictionary
//
//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "LookupDictionaryModel.h"

static LookupDictionaryModel *_lookupDictionaryModel = nil;

@implementation LookupDictionaryModel
@synthesize pb;

+ (LookupDictionaryModel *) getInstance {
	@synchronized(self) {
		if (_lookupDictionaryModel == nil) {
			_lookupDictionaryModel = [[LookupDictionaryModel alloc] init];
		}
	}
	return _lookupDictionaryModel;
}

- (id) init {
	if ((self = [super init])) {
		currentRequest = nil;
		pb = [[NSPasteboard pasteboardWithUniqueName] retain];
		NSLog(@"sc_LookupDictionaryModel init: pb = %@", pb);
	}
	return self;
}

- (void) dealloc {
	[lastWord release];
	[pb release];
	[currentRequest release];
	[super dealloc];
}

- (NSString *) getLookupAddress {
	return [NSString stringWithFormat:
			@"https://%@/services/dictionary/lookup", 
			@"127.0.0.1:8888"];
}

- (NSString *) jsonEncode: (NSDictionary *) msg {
	return [[[[SBJSON alloc] init] autorelease] stringWithObject: msg];
}

- (void)lookup:(NSString *) str;
{
	//NSLog(@"lookup: currentRequest = %@", currentRequest);
	if ([str isEqualToString:lastWord]) {
		return;
	}
	if ((!str)||([str length] <= 0)||([str length] >= 50)) {
		return;
	}
	if (currentRequest == nil) {
		[lastWord release];
		lastWord = [str retain];
		NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									str, @"word", nil];
		NSString *jsonData = [self jsonEncode: msg];
		NSURL *url = [NSURL URLWithString: [self getLookupAddress]];
		NSLog(@"sc_lookup: %@ at %@", jsonData, url);
		currentRequest = [[ASIHTTPRequest requestWithURL:url] retain];
		currentRequest.validatesSecureCertificate = NO;
		[currentRequest addRequestHeader:@"Content-Type" value:@"application/json"];
		[currentRequest appendPostData: [jsonData dataUsingEncoding:NSUTF8StringEncoding]];
		[currentRequest setDelegate:self];
		[currentRequest startAsynchronous];
	}
}

- (BOOL) lookupAsService: (NSObject *)sender {
	NSArray *sendTypes = [NSArray arrayWithObject:NSStringPboardType];
	if ([sender respondsToSelector:@selector(writeSelectionToPasteboard:types:)]) {
		[pb clearContents];
		//NSLog(@"sc_lookupAsService, %@, %@, %@", sendTypes, pb, sender);
		if ([sender writeSelectionToPasteboard: pb
										 types: sendTypes] == NO) {
			//NSLog(@"sc_lookupAsService: writeSelectionToPasteboard failed, model.pb=%@", pb);
		} else {
			NSString *selectedText = [pb stringForType:NSStringPboardType];
			if ([selectedText length] > 0) {
				[self lookup:selectedText];
			}
		}
		return YES;
	} else {
		return NO;
	}

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	[currentRequest release];
	currentRequest = nil;
	//NSLog(@"requestFinished: %@", [request responseString]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	[currentRequest release];
	currentRequest = nil;
	//NSLog(@"requestFailed: %@", [request error]);
}
@end
