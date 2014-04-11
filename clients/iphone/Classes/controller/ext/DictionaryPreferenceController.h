//
//  DictionaryPreferenceController.h
//  Shortcut
//
//  Created by YJ Park on 11/2/10.
//  Copyright 2010 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortcutController.h"

@interface DictionaryPreferenceController : ShortcutController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSDictionary *protocol;
    UIPickerView *lookupSourcePicker;
    UIPickerView *defaultSourcePicker;
}
@property (nonatomic, retain) IBOutlet UIPickerView *lookupSourcePicker;
@property (nonatomic, retain) IBOutlet UIPickerView *defaultSourcePicker;

-(IBAction) onSave;

@end
