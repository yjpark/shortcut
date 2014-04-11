//
//  DictController.h
//  Shortcut
//
//  Created by YJ Park on 9/28/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioStreamer.h"

#import "ShortcutController.h"
#import "DictionaryPreferenceController.h"

#define DICTIONARY_SOURCE_KEY @"lookupSource"


@interface DictionaryController : ShortcutController 
            <UISearchBarDelegate, UIAlertViewDelegate, ShortcutDelegate> {
	UIWebView *htmlResult;
    UITextView *textResult;
	UISearchBar *lookupField;
    
    NSString *lookupSource;
    NSDictionary *lastDefinitionData;
    AudioStreamer *streamer;
    NSString *audioURL;
    UIBarButtonItem *playButton;
    UIBarButtonItem *lookupButton;
                
    DictionaryPreferenceController *preferenceController;
}
@property (nonatomic, retain) IBOutlet UIWebView *htmlResult;
@property (nonatomic, retain) IBOutlet UITextView *textResult;
@property (nonatomic, retain) IBOutlet UISearchBar *lookupField;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *lookupButton;

-(IBAction) onPlay;
-(IBAction) onLookup;
-(IBAction) onSetup;

- (void) onDefinition: (NSString *) definition withFormat: (NSString *) format
             withData: (NSDictionary *) data;
-(void) setupFinished;

- (void) lookup: (NSString *)word;
- (void) resetStreamer;
@end
