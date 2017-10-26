//
//  RNTDraftJSEditor.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/22/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

@interface RNTDraftJSEditor : UIView<UIKeyInput>

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, assign) CGRect textFrame;
@property (nonatomic, assign) BOOL selectable;

@property (nonatomic, copy) RCTDirectEventBlock onKeysPressed;
@property (nonatomic, copy) RCTDirectEventBlock onBackspacePressed;
@property (nonatomic, copy) RCTDirectEventBlock onNewlinePressed;

@property(nonatomic) UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
@property(nonatomic) UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
@property(nonatomic) UITextSpellCheckingType spellCheckingType NS_AVAILABLE_IOS(5_0); // default is UITextSpellCheckingTypeDefault;
@property(nonatomic) UITextSmartQuotesType smartQuotesType NS_AVAILABLE_IOS(11_0); // default is UITextSmartQuotesTypeDefault;
@property(nonatomic) UITextSmartDashesType smartDashesType NS_AVAILABLE_IOS(11_0); // default is UITextSmartDashesTypeDefault;
@property(nonatomic) UITextSmartInsertDeleteType smartInsertDeleteType NS_AVAILABLE_IOS(11_0); // default is UITextSmartInsertDeleteTypeDefault;
@property(nonatomic) UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;             // default is UIKeyboardAppearanceDefault
@property(nonatomic) UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
@property(nonatomic) BOOL enablesReturnKeyAutomatically;                  // default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents)
@property(nonatomic,getter=isSecureTextEntry) BOOL secureTextEntry;       // default is NO

// The textContentType property is to provide the keyboard with extra information about the semantic intent of the text document.
@property(nonatomic,copy) UITextContentType textContentType NS_AVAILABLE_IOS(10_0); // default is nil

@end

