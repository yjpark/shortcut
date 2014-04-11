//
//  DictController.m
//  Shortcut
//
//  Created by YJ Park on 9/28/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "DictionaryController.h"

@implementation DictionaryController

@synthesize lookupField;
@synthesize textResult;
@synthesize htmlResult;

@synthesize playButton;
@synthesize lookupButton;

+ (NSArray *) getRequiredChannalTypes {
	return [NSArray arrayWithObjects: @"dictionary", nil];
}

- (void) dealloc {
    [preferenceController release];
    [lookupSource release];
    [audioURL release];
    [lastDefinitionData release];
    [self resetStreamer];
	[super dealloc];
}

- (BOOL) isModal {
    return YES;
}

- (void) onConnect {
    lookupSource = [model getDefault:DICTIONARY_SOURCE_KEY forClient:client];
}

- (void) resetStreamer {
    if (streamer) {
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];

		[streamer stop];
		[streamer release];
		streamer = nil;
    }
}

- (NSString *) getNibName {
	return @"ext-dictionary";
}

- (NSString *) getTitle {
	return @"Dictionary";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"ext-dictionary-icon.jpg"];
}

- (void) onData: (NSString *) channel
		 withData: (NSDictionary *) data {
	if ([ShortcutController isChannel:channel hasType:@"dictionary"]) {
		NSString *definition = [data valueForKey: @"definition"];
		NSString *format = [data valueForKey: @"format"];
		if (definition) {
			[self onDefinition: definition withFormat: format withData: data];
		}
	}
}

- (void) onDefinition: (NSString *) definition withFormat: (NSString *) format
             withData: (NSDictionary *) data {
    if ([@"html" isEqualToString:format]) {
        NSString *_url = [data valueForKey: @"url"];
        _url = [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_url];
        self.textResult.hidden = YES;
        self.htmlResult.hidden = NO;
        [self.htmlResult loadHTMLString:definition baseURL:url];
    } else if ([@"url" isEqualToString:format]) {
        definition = [definition stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:definition];
        NSLog(@"url = %@, %@", definition, url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        self.textResult.hidden = YES;
        self.htmlResult.hidden = NO;
        [self.htmlResult loadRequest:request];
    } else {
        self.textResult.text = definition;
        self.textResult.hidden = NO;
        self.textResult.frame = self.htmlResult.frame; //hacky way to keep the toolbar visible
        self.htmlResult.hidden = YES;
    }
    NSString *source = [data valueForKey: @"source"];
	if ([@"google.dictionary" isEqualToString: source]) {
        self.htmlResult.hidden = YES;
        [self showProgressHUD];
    } else {
        [self hideProgressHUD];
    }

    if (lookupSource && ![lookupSource isEqualToString:source]) {
        lookupButton.enabled = YES;
    } else {
        lookupButton.enabled = NO;
    }

	NSString *word = [data valueForKey: @"word"];
	if (word) {
		self.lookupField.text = word;
	}

	NSString *audio = [data valueForKey: @"audio"];
	if (audio) {
		self.lookupField.text = word;
        [audioURL release];
        audioURL = [audio retain];
        self.playButton.enabled = YES;
	} else {
        if (lastDefinitionData) {
            NSString *lastWord = [lastDefinitionData valueForKey: @"word"];
            if (lastWord && [lastWord isEqualToString:word]) {
                //no new audio for same word, so leave the audio part untouched
            } else {
                audioURL = nil;
                self.playButton.enabled = NO;
            }
        } else {
            audioURL = nil;
            self.playButton.enabled = NO;
        }
    }
    if (lastDefinitionData) {
        [lastDefinitionData release];
        lastDefinitionData = nil;
    }
    lastDefinitionData = [data retain];
    NSLog(@"onDefinition: %@, %@", word, format);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *path = nil;
    NSString *source = [lastDefinitionData valueForKey: @"source"];
	if ([@"google.dictionary" isEqualToString: source]) {
        path = [[NSBundle mainBundle] pathForResource:@"ext-dictionary-google" ofType:@"js"];
	}    
    NSLog(@"webViewDidFinishLoad, source=%@, path=%@", source, path);
    if (path) {
        NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString:jsCode];    
    }
    
	if ([@"google.dictionary" isEqualToString: source]) {
        self.htmlResult.hidden = NO;
        [self hideProgressHUD];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *source = [lastDefinitionData valueForKey: @"source"];
        if ([@"google.dictionary" isEqualToString: source]) {
            NSString *url = [[request URL] absoluteString];
            NSRange range = [url rangeOfString: @"http://www.google.com/dictionary"];
            NSLog(@"google dictionary link: %@, %@, %d, %d", url, [request URL].query, range.location, range.length);
            if (range.location != NSNotFound) {
                self.htmlResult.hidden = YES;
                [self showProgressHUD];     
                NSDictionary *args = [[model utils] parseQueryString:[request URL].query];
                NSString *word = [args valueForKey:@"q"];
                if (word) {
                    self.lookupField.text = word;
                }
            }
        }
    }
    return YES;
}

-(IBAction) onSetup {
    if (preferenceController) {
        [preferenceController release];
        preferenceController = nil;
    }
    preferenceController = [[DictionaryPreferenceController alloc] init];
    [preferenceController listenOnClient:client];
    preferenceController.delegate = self;
    [self presentModalViewController:preferenceController animated:YES];
}

- (void) onProtocolUpdate: (NSString *) channel {
    if (preferenceController) {
        [preferenceController onProtocolUpdate:channel];
    }
}

- (void) onShortcutDone: (ShortcutController *)shortcutController {
    lookupSource = [model getDefault:DICTIONARY_SOURCE_KEY forClient:client];
    if (lastDefinitionData) {
        NSString *source = [lastDefinitionData valueForKey: @"source"];
        NSString *word = [lastDefinitionData valueForKey: @"word"];
        if (word && lookupSource && ![lookupSource isEqualToString:source]) {
            lookupButton.enabled = YES;
        } else {
            lookupButton.enabled = NO;
        }
    }
    if (preferenceController) {
        [preferenceController release];
        preferenceController = nil;
    }
}

-(IBAction) onLookup {
    NSString *source = [lastDefinitionData valueForKey: @"source"];
	NSString *word = [lastDefinitionData valueForKey: @"word"];
	if (word && lookupSource && ![lookupSource isEqualToString:source]) {
        lookupButton.enabled = NO;
        [self lookup: word];
    }
}

-(IBAction) onPlay {
    NSLog(@"Play Audio: %@", audioURL);
    [self resetStreamer];
    self.playButton.enabled = NO;
    NSURL *url = [NSURL URLWithString:audioURL];
	streamer = [[AudioStreamer alloc] initWithURL:url];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];    
    [streamer start];
}

- (void)playbackStateChanged:(NSNotification *)aNotification {
	if ([streamer isIdle])	{
		[self resetStreamer];
        if (audioURL) {
            self.playButton.enabled = YES;            
        }
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {	
	NSString *word = searchBar.text;
    [self lookup: word];
	[searchBar resignFirstResponder];
}    

- (void) lookup: (NSString *)word {
	NSLog(@"Search: %@", word);
	NSMutableDictionary *args = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys: 
            word, @"word", nil];
    if (lookupSource) {
        [args setValue:lookupSource forKey:@"source"];
    }
	NSLog(@"Search: %@, source = %@", word, lookupSource);
	[self control:@"dictionary" withCmd: @"lookup" withArgs: args];
    [self showProgressHUD];
}

@end
