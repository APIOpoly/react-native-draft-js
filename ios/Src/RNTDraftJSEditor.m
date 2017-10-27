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
#import "RNDJDraftJsIndex.h"

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
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPressGesture];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGesture];
//    [longPressGesture requireGestureRecognizerToFail:tapGesture];
  }
  return self;
}

- (RNDJDraftJsIndex*) draftJsIndexForPointInView:(CGPoint)point
{
  NSLayoutManager *layoutManager = [_textStorage.layoutManagers firstObject];
  NSTextContainer *textContainer = [layoutManager.textContainers firstObject];
  
  NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];

  NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
  
  __block CGFloat closestSquaredDistance = CGFLOAT_MAX;
  __block RNDJDraftJsIndex* closestDraftJsIndex = nil;
  [layoutManager.textStorage enumerateAttribute:RNDJDraftJsIndexAttributeName inRange:characterRange options:0 usingBlock:^(RNDJDraftJsIndex *draftJsIndex, NSRange range, BOOL *_) {
    if (!draftJsIndex) {
      return;
    }
    
    [layoutManager enumerateEnclosingRectsForGlyphRange:range withinSelectedGlyphRange:range inTextContainer:textContainer usingBlock:^(CGRect enclosingRect, __unused BOOL *__) {
      CGFloat xDiff = 0;
      CGFloat yDiff = 0;
      
      CGPoint topLeft = enclosingRect.origin;
      CGPoint bottomRight = CGPointMake(enclosingRect.origin.x + enclosingRect.size.width, enclosingRect.origin.y + enclosingRect.size.height);
      
      if (point.x < topLeft.x) {
        xDiff = topLeft.x - point.x;
      } else if (point.x > bottomRight.x) {
        xDiff = point.x - bottomRight.x;
      }
      
      if (point.y < topLeft.y) {
        yDiff = topLeft.y - point.y;
      } else if (point.y > bottomRight.y) {
        yDiff = point.y - bottomRight.y;
      }
      
      CGFloat squaredDistance = (xDiff*xDiff) + (yDiff*yDiff);
      if (squaredDistance < closestSquaredDistance) {
        closestSquaredDistance = squaredDistance;
        closestDraftJsIndex = draftJsIndex;
      }
    }];
  }];

  return closestDraftJsIndex;
}

- (void) tap:(UIGestureRecognizer*)gesture
{
  CGPoint tapPostion = [gesture locationInView:self];
  tapPostion.x -= _contentInset.left;
  tapPostion.y -= _contentInset.top;
  
  if (!_hasFocus) {
    switch (gesture.state) {
      case UIGestureRecognizerStateRecognized:
      {
        RNDJDraftJsIndex* selectedIndex = [self draftJsIndexForPointInView:tapPostion];
        if (selectedIndex) {
          [self requestSetSelection:selectedIndex];
        } else {
          [self requestHasFocus:YES];
        }
      }
      default:
        break;
    }
  } else {
    RNDJDraftJsIndex* selectedIndex = [self draftJsIndexForPointInView:tapPostion];
    [self requestSetSelection:selectedIndex];
  }
}

- (void)pan:(UILongPressGestureRecognizer *)gesture
{
  CGPoint tapPostion = [gesture locationInView:self];
  tapPostion.x -= _contentInset.left;
  tapPostion.y -= _contentInset.top;
  
  if (_hasFocus) {
    RNDJDraftJsIndex* selectedIndex = [self draftJsIndexForPointInView:tapPostion];
    [self requestSetSelection:selectedIndex];
  }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
  CGPoint tapPostion = [gesture locationInView:self];
  tapPostion.x -= _contentInset.left;
  tapPostion.y -= _contentInset.top;

  if (_hasFocus) {
    RNDJDraftJsIndex* selectedIndex = [self draftJsIndexForPointInView:tapPostion];
    [self requestSetSelection:selectedIndex];
  }
  
  //  if (self.isFirstResponder) {
  //
  //  } else {
  //#if !TARGET_OS_TV
  //    UIMenuController *menuController = [UIMenuController sharedMenuController];
  //
  //    if (menuController.isMenuVisible) {
  //      return;
  //    }
  //
  //    if (!self.isFirstResponder) {
  //      [self becomeFirstResponder];
  //    }
  //
  //    [menuController setTargetRect:self.bounds inView:self];
  //    [menuController setMenuVisible:YES animated:YES];
  //#endif
  //  }
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
  
  [layoutManager.textStorage enumerateAttribute:RNDJSingleCursorPositionAttributeName inRange:characterRange options:0 usingBlock:^(NSNumber *value, NSRange range, BOOL *_) {
    if (!value.boolValue) {
      return;
    }
    
    [layoutManager enumerateEnclosingRectsForGlyphRange:range withinSelectedGlyphRange:range inTextContainer:textContainer usingBlock:^(CGRect enclosingRect, __unused BOOL *__) {
      CGRect cursorRect = CGRectMake(enclosingRect.origin.x, enclosingRect.origin.y, 2, enclosingRect.size.height);
      UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cursorRect
                                                      cornerRadius:1];
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

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (void) requestHasFocus:(BOOL)hasFocus
{
  RCTDirectEventBlock onSelectionChangeRequest = _onSelectionChangeRequest;
  if (onSelectionChangeRequest) {
    onSelectionChangeRequest(@{@"hasFocus": @(hasFocus)});
  }
}

- (void) requestSetSelection:(RNDJDraftJsIndex*)index
{
  NSString* blockKey = _lastIndex.key;
  NSUInteger offset = _lastIndex.offset;
  
  if (index) {
    blockKey = index.key;
    offset = index.offset + 1;
  }
  
  if (blockKey.length > 0) {
    RCTDirectEventBlock onSelectionChangeRequest = _onSelectionChangeRequest;
    if (onSelectionChangeRequest) {
      onSelectionChangeRequest(@{
                                 @"startKey": blockKey,
                                 @"startOffset": @(offset),
                                 @"endKey": blockKey,
                                 @"endOffset": @(offset),
                                 });
    }
  }
}

- (BOOL)becomeFirstResponder
{
  BOOL result = [super becomeFirstResponder];
  if (_hasFocus) {
    return result;
  }
  [self requestHasFocus:YES];
  return result;
}

- (BOOL)resignFirstResponder
{
  BOOL result = [super resignFirstResponder];
  
  if (!_hasFocus) {
    return result;
  }
  [self requestHasFocus:NO];
  return result;
}

- (void) setHasFocus:(BOOL)hasFocus {
  _hasFocus = hasFocus;
  
  if (hasFocus && !self.isFirstResponder) {
    if (![self becomeFirstResponder]) {
      [self requestHasFocus:NO];
    }
  } else if (!hasFocus && self.isFirstResponder) {
    if (![self resignFirstResponder]) {
      [self requestHasFocus:YES];
    }
  }
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

