//
//  ShortcutMsg.m
//  Shortcut
//
//  Created by YJ Park on 9/27/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "ShortcutMsg.h"


@implementation ShortcutMsg

+ (NSDictionary *) jsonDecode: (NSString *) str {
	return [[[[SBJSON alloc] init] autorelease] objectWithString: str];
}

+ (NSString *) jsonEncode: (NSDictionary *) msg {
	return [[[[SBJSON alloc] init] autorelease] stringWithObject: msg];
}

+ (NSString *) getChannelType: (NSString *) channel {
	return [channel stringByDeletingLastPathComponent];
}

+ (NSDictionary *) getOriginalControlData: (NSDictionary *) data {
	NSDictionary *result = nil;
	NSDictionary *originalMsg = [data valueForKey: @"original_msg"];
	if (originalMsg) {
		NSString *op = [originalMsg valueForKey: SC_OP];
		if ([SC_CONTROL isEqualToString: op]) {
			result = [originalMsg valueForKey: SC_DATA];
		}
	}
	return result;
}

@end
