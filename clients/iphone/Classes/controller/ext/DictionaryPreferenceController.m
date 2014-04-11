    //
//  DictionaryPreferenceController.m
//  Shortcut
//
//  Created by YJ Park on 11/2/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import "DictionaryPreferenceController.h"
#import "DictionaryController.h"

@implementation DictionaryPreferenceController

@synthesize lookupSourcePicker;
@synthesize defaultSourcePicker;

- (void) dealloc {
    [protocol release];
    [super dealloc];
}

- (BOOL) isModal {
	return YES;
}

+ (NSArray *) getRequiredChannalTypes {
	return [NSArray arrayWithObjects: @"dictionary", nil];
}

- (void) onInit {
    self.requiredChannelTypes = [DictionaryPreferenceController getRequiredChannalTypes]; \
}

- (NSString *) getNibName {
    return @"ext-dictionary-preference";
}

- (NSString *) getTitle {
    return @"Dictionary Preference";
}

- (UIImage *) getIconImage {
	return [UIImage imageNamed:@"ext-dictionary-icon.jpg"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *_protocol = [self getProtocolByType:@"dictionary"];
    if (_protocol) {
        if (protocol) {
            [protocol release];
        }
        protocol = [_protocol retain];
        NSArray *sources = [protocol valueForKey:@"sources"];

        [self.lookupSourcePicker reloadAllComponents];
        NSString *lookupSource = [model getDefault:DICTIONARY_SOURCE_KEY forClient:client];
        if (lookupSource && sources) {
            NSInteger index = [sources indexOfObject:lookupSource];
            if (index >= 0) {
                [self.lookupSourcePicker selectRow:index inComponent:0 animated:YES];
            }
        }
        
        [self.defaultSourcePicker reloadAllComponents];
        NSString *defaultSource = [protocol valueForKey:@"default_source"];\
        if (defaultSource && sources) {
            NSInteger index = [sources indexOfObject:defaultSource];
            if (index >= 0) {
                [self.defaultSourcePicker selectRow:index inComponent:0 animated:YES];
            }
        }
    }    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (protocol) {
        NSArray *sources = [protocol valueForKey:@"sources"];
        return [sources count];
    } else {
        return 0;
    }
}

- (NSString *)getSourceTitle: (NSString *) source {
    NSDictionary *sources_dict = [protocol valueForKey:@"sources_dict"];
    NSDictionary *source_def = [sources_dict valueForKey:source];
    return [source_def valueForKey:@"title"];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row 
            forComponent:(NSInteger)component {
    if (protocol) {
        NSArray *sources = [protocol valueForKey:@"sources"];
        return [self getSourceTitle:[sources objectAtIndex:row]];
    }
    return nil;
}

-(IBAction) onSave {
    NSArray *sources = [protocol valueForKey:@"sources"];
    
    NSString *lookupSource = [sources objectAtIndex:[self.lookupSourcePicker selectedRowInComponent:0]];
    [model writeDefault:lookupSource forKey:DICTIONARY_SOURCE_KEY forClient:client];
    
    NSString *newDefaultSource = [sources objectAtIndex:[self.defaultSourcePicker selectedRowInComponent:0]];
    NSString *defaultSource = [protocol valueForKey:@"default_source"];
    if (newDefaultSource && ![newDefaultSource isEqualToString:defaultSource]) {
        NSMutableDictionary *args = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys: 
         newDefaultSource, @"source", nil];
        NSLog(@"set_default_source: %@", newDefaultSource);
        [self control:@"dictionary" withCmd: @"set_default_source" withArgs: args];
        [self showProgressHUD];        
    } else {        
        [self onDone];
    }
}

- (void) onProtocolUpdate: (NSString *) channel {
	if ([ShortcutController isChannel:channel hasType:@"dictionary"]) {
        //not checking the value here to keep it simple
        [self onDone];
	}
}

@end
