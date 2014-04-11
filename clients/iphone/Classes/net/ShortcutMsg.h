//
//  ShortcutMsg.h
//  Shortcut
//
//  Created by YJ Park on 9/27/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"

//AUTH
static NSString *SC_ACK = @"ACK";
static NSString *SC_NAK = @"NAK";

//OPERATIONS
static NSString *SC_OP = @"op";
static NSString *SC_REGISTER = @"register";
static NSString *SC_LISTEN = @"listen";
static NSString *SC_CONTROL = @"control";
static NSString *SC_NOTIFY = @"notify";
static NSString *SC_PROTOCOL = @"protocol";

//CHANNEL
static NSString *SC_CHANNEL = @"channel";
static NSString *SC_DATA = @"data";

//CONTROL
static NSString *SC_CMD = @"cmd";

//NOTIFY
static NSString *SC_TYPE = @"type";
static NSString *SC_CLOSED = @"closed";
static NSString *SC_LISTENING = @"listening";
static NSString *SC_ERROR = @"error";
static NSString *SC_ORIGINAL_MSG = @"original_msg";

//PROTOCOL
static NSString *SC_TITLE = @"title";
static NSString *SC_DESCRIPTION = @"description";
static NSString *SC_CMDS = @"cmds";
static NSString *SC_PROPERTIES = @"properties";

@interface ShortcutMsg : NSObject {
}

+ (NSDictionary *) jsonDecode: (NSString *) str;
+ (NSString *) jsonEncode: (NSDictionary *) msg;
+ (NSString *) getChannelType: (NSString *) channel; 

+ (NSDictionary *) getOriginalControlData: (NSDictionary *) data;
@end
