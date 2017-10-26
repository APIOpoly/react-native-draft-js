//
//  RNTDraftJSEditor.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/22/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNTDraftJSEditor.h"

#import <MobileCoreServices/UTCoreTypes.h>

#import <React/RCTUtils.h>
#import <React/UIView+React.h>

#import "RNTShadowDraftJSEditor.h"

static void collectNonTextDescendants(RNTDraftJSEditor *view, NSMutableArray *nonTextDescendants)
{
  for (UIView *child in view.reactSubviews) {
    if ([child isKindOfClass:[RNTDraftJSEditor class]]) {
      collectNonTextDescendants((RNTDraftJSEditor *)child, nonTextDescendants);
    } else if (!CGRectEqualToRect(child.frame, CGRectZero)) {
      [nonTextDescendants addObject:child];
    }
  }
}

@implementation RNTDraftJSEditor
{
  NSTextStorage *_textStorage;
  CAShapeLayer *_highlightLayer;
  UILongPressGestureRecognizer *_longPressGestureRecognizer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    _textStorage = [NSTextStorage new];
    self.isAccessibilityElement = YES;
    self.accessibilityTraits |= UIAccessibilityTraitStaticText;
    
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.smartQuotesType = UITextSmartQuotesTypeNo;
    self.smartDashesType = UITextSmartDashesTypeNo;
    self.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:gesture];
  }
  return self;
}

- (void) tap:(UIGestureRecognizer*)gesture
{
  if ([self canBecomeFirstResponder])
  {
    [self becomeFirstResponder];
  }
}

- (NSString *)description
{
  NSString *superDescription = super.description;
  NSRange semicolonRange = [superDescription rangeOfString:@";"];
  NSString *replacement = [NSString stringWithFormat:@"; reactTag: %@; text: %@", self.reactTag, self.textStorage.string];
  return [superDescription stringByReplacingCharactersInRange:semicolonRange withString:replacement];
}

- (void)setSelectable:(BOOL)selectable
{
  if (_selectable == selectable) {
    return;
  }
  
  _selectable = selectable;
  
  if (_selectable) {
    [self enableContextMenu];
  }
  else {
    [self disableContextMenu];
  }
}

- (void)reactSetFrame:(CGRect)frame
{
  // Text looks super weird if its frame is animated.
  // This disables the frame animation, without affecting opacity, etc.
  [UIView performWithoutAnimation:^{
    [super reactSetFrame:frame];
  }];
}

- (void)reactSetInheritedBackgroundColor:(UIColor *)inheritedBackgroundColor
{
  self.backgroundColor = inheritedBackgroundColor;
}

- (void)didUpdateReactSubviews
{
  // Do nothing, as subviews are managed by `setTextStorage:` method
}

- (void)setTextStorage:(NSTextStorage *)textStorage
{
  if (_textStorage != textStorage) {
    _textStorage = textStorage;
    
    // Update subviews
    NSMutableArray *nonTextDescendants = [NSMutableArray new];
    collectNonTextDescendants(self, nonTextDescendants);
    NSArray *subviews = self.subviews;
    if (![subviews isEqualToArray:nonTextDescendants]) {
      for (UIView *child in subviews) {
        if (![nonTextDescendants containsObject:child]) {
          [child removeFromSuperview];
        }
      }
      for (UIView *child in nonTextDescendants) {
        [self addSubview:child];
      }
    }
    
    [self setNeedsDisplay];
  }
}

- (void)drawRect:(CGRect)rect
{
  NSLayoutManager *layoutManager = [_textStorage.layoutManagers firstObject];
  NSTextContainer *textContainer = [layoutManager.textContainers firstObject];
  
  NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
  CGRect textFrame = self.textFrame;
  [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textFrame.origin];
  [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textFrame.origin];
  
  __block UIBezierPath *highlightPath = nil;
  NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
  [layoutManager.textStorage enumerateAttribute:RCTIsHighlightedAttributeName inRange:characterRange options:0 usingBlock:^(NSNumber *value, NSRange range, BOOL *_) {
    if (!value.boolValue) {
      return;
    }
    
    [layoutManager enumerateEnclosingRectsForGlyphRange:range withinSelectedGlyphRange:range inTextContainer:textContainer usingBlock:^(CGRect enclosingRect, __unused BOOL *__) {
      UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(enclosingRect, -2, -2) cornerRadius:2];
      if (highlightPath) {
        [highlightPath appendPath:path];
      } else {
        highlightPath = path;
      }
    }];
  }];

  CGFloat selectionOpacity = isnan(_selectionOpacity) ? 0.25 : _selectionOpacity;

  UIColor* selectionColor = [UIColor colorWithWhite:0 alpha:selectionOpacity];
  if (_selectionColor) {
    selectionColor = [_selectionColor colorWithAlphaComponent:CGColorGetAlpha(_selectionColor.CGColor) * selectionOpacity];
  }
  
  if (highlightPath) {
    if (!_highlightLayer) {
      _highlightLayer = [CAShapeLayer layer];
      _highlightLayer.fillColor = selectionColor.CGColor;
      [self.layer addSublayer:_highlightLayer];
    }
    _highlightLayer.position = (CGPoint){_contentInset.left, _contentInset.top};
    _highlightLayer.path = highlightPath.CGPath;
  } else {
    [_highlightLayer removeFromSuperlayer];
    _highlightLayer = nil;
  }
}

- (NSNumber *)reactTagAtPoint:(CGPoint)point
{
  NSNumber *reactTag = self.reactTag;
  
  CGFloat fraction;
  NSLayoutManager *layoutManager = _textStorage.layoutManagers.firstObject;
  NSTextContainer *textContainer = layoutManager.textContainers.firstObject;
  NSUInteger characterIndex = [layoutManager characterIndexForPoint:point
                                                    inTextContainer:textContainer
                           fractionOfDistanceBetweenInsertionPoints:&fraction];
  
  // If the point is not before (fraction == 0.0) the first character and not
  // after (fraction == 1.0) the last character, then the attribute is valid.
  if (_textStorage.length > 0 && (fraction > 0 || characterIndex > 0) && (fraction < 1 || characterIndex < _textStorage.length - 1)) {
    reactTag = [_textStorage attribute:RCTReactTagAttributeName atIndex:characterIndex effectiveRange:NULL];
  }
  return reactTag;
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  
  if (!self.window) {
    self.layer.contents = nil;
    if (_highlightLayer) {
      [_highlightLayer removeFromSuperlayer];
      _highlightLayer = nil;
    }
  } else if (_textStorage.length) {
    [self setNeedsDisplay];
  }
}


#pragma mark - Accessibility

- (NSString *)accessibilityLabel
{
  return _textStorage.string;
}

#pragma mark - Context Menu

- (void)enableContextMenu
{
  _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  [self addGestureRecognizer:_longPressGestureRecognizer];
}

- (void)disableContextMenu
{
  [self removeGestureRecognizer:_longPressGestureRecognizer];
  _longPressGestureRecognizer = nil;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
#if !TARGET_OS_TV
  UIMenuController *menuController = [UIMenuController sharedMenuController];
  
  if (menuController.isMenuVisible) {
    return;
  }
  
  if (!self.isFirstResponder) {
    [self becomeFirstResponder];
  }
  
  [menuController setTargetRect:self.bounds inView:self];
  [menuController setMenuVisible:YES animated:YES];
#endif
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  if (action == @selector(copy:)) {
    return YES;
  }
  
  return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
#if !TARGET_OS_TV
  NSAttributedString *attributedString = _textStorage;
  
  NSMutableDictionary *item = [NSMutableDictionary new];
  
  NSData *rtf = [attributedString dataFromRange:NSMakeRange(0, attributedString.length)
                             documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType}
                                          error:nil];
  
  if (rtf) {
    [item setObject:rtf forKey:(id)kUTTypeFlatRTFD];
  }
  
  [item setObject:attributedString.string forKey:(id)kUTTypeUTF8PlainText];
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.items = @[item];
#endif
}

- (BOOL)hasText
{
  return _textStorage.length > 0;
}

//@property (nonatomic, copy) RCTDirectEventBlock onInsertTextRequest;
//@property (nonatomic, copy) RCTDirectEventBlock onBackspaceRequest;
//@property (nonatomic, copy) RCTDirectEventBlock onNewlineRequest;

- (void)insertText:(NSString *)text
{
  RCTDirectEventBlock onInsertTextRequest = self.onInsertTextRequest;
  RCTDirectEventBlock onNewlineRequest = self.onNewlineRequest;

  NSArray* textComponents = [text componentsSeparatedByString:@"\n"];
  NSUInteger numComponents = textComponents.count;
  for (int i=0; i<numComponents; i++) {
    NSString* textComponent = textComponents[i];
    
    if (textComponent.length > 0) {
      if (onInsertTextRequest)
      {
        onInsertTextRequest(@{@"text": textComponent});
      }
    }
    
    if (i < numComponents-1) {
      if (onNewlineRequest) {
        onNewlineRequest(@{});
      }
    }
  }
}

- (void)deleteBackward
{
  RCTDirectEventBlock onBackspaceRequest = self.onBackspaceRequest;
  if (onBackspaceRequest)
  {
    onBackspaceRequest(@{});
	}
}

@end

