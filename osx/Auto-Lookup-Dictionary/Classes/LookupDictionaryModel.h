//
//  SCLookupDict.h
//  Auto-Lookup-Dictionary
//
//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"
#import "SBJSON.h"

@interface LookupDictionaryModel : NSObject {
	ASIHTTPRequest *currentRequest;
	NSPasteboard *pb;
	NSString *lastWord;
}
@property (readonly) NSPasteboard *pb;

+ (LookupDictionaryModel *) getInstance;

- (NSString *) getLookupAddress;
- (NSString *) jsonEncode: (NSDictionary *) msg;

- (void)lookup:(NSString *) str;
- (BOOL) lookupAsService: (NSObject *)sender;

@end
