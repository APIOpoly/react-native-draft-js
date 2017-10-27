//
//  RNTDraftJSEditor.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/22/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import "RNDJDraftJsIndex.h"

@interface RNTDraftJSEditor : UIView<UIKeyInput>

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, assign) CGRect textFrame;
@property (nonatomic, assign) BOOL selectable;

@property (nonatomic, copy) RCTDirectEventBlock onInsertTextRequest;
@property (nonatomic, copy) RCTDirectEventBlock onBackspaceRequest;
@property (nonatomic, copy) RCTDirectEventBlock onNewlineRequest;
@property (nonatomic, copy) RCTDirectEventBlock onSelectionChangeRequest;

@property (nonatomic, copy) UIColor* selectionColor;
@property (nonatomic, assign) CGFloat selectionOpacity;

@property (nonatomic, assign) BOOL hasFocus;
@property (nonatomic, strong) RNDJDraftJsIndex* lastIndex;

@property(nonatomic) UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
@property(nonatomic) UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
@property(nonatomic) UITextSpellCheckingType spellCheckingType NS_AVAILABLE_IOS(5_0); // default is UITextSpellCheckingTypeDefault;
@property(nonatomic) UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;             // default is UIKeyboardAppearanceDefault
@property(nonatomic) UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
@property(nonatomic) BOOL enablesReturnKeyAutomatically;                  // default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents)
@property(nonatomic,getter=isSecureTextEntry) BOOL secureTextEntry;       // default is NO

// The textContentType property is to provide the keyboard with extra information about the semantic intent of the text document.
@property(nonatomic,copy) UITextContentType textContentType NS_AVAILABLE_IOS(10_0); // default is nil

@end

