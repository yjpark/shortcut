//
//  SCTextSelection.h
//  Text-Selection
//
//  Created by YJ Park on 10/5/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "JRSwizzle.h"
#import "LookupDictionaryModel.h"

@interface NSNotificationCenter(ShortCut)
@end

@interface NSMenu(ShortCut)
@end

@interface NSMenuItem(ShortCut)
@end

@interface NSApplication(ShortCut)
@end

@interface SCAutoLookupDictionaryPlugin : NSObject {

}

+ (void) load;
+ (SCAutoLookupDictionaryPlugin*) sharedInstance;

@end
