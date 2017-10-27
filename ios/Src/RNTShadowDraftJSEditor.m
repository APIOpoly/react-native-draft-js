//
//  RNTShadowDraftJSEditor.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/23/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNTShadowDraftJSEditor.h"

#import <React/RCTAccessibilityManager.h>
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTFont.h>
#import <React/RCTLog.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>

#import "RNTDraftJSEditor.h"
#import "RCTShadowView+DraftJSDirty.h"
#import "RNDJStyle.h"

extern NSString *const RCTShadowViewAttributeName;

extern CGFloat const RCTTextAutoSizeDefaultMinimumFontScale;
extern CGFloat const RCTTextAutoSizeWidthErrorMargin;
extern CGFloat const RCTTextAutoSizeHeightErrorMargin;
extern CGFloat const RCTTextAutoSizeGranularity;

NSString *const RNDJSingleCursorPositionAttributeName = @"SingleCursorPositionAttributeName";
NSString *const RNDJDraftJsIndexAttributeName = @"DraftJsIndexAttributeName";


@interface NSString(DraftJsBlockTypesMap)

- (NSString*) toJsStyleName;

@end

@implementation RNTShadowDraftJSEditor
{
  NSTextStorage *_cachedTextStorage;
  CGFloat _cachedTextStorageWidth;
  CGFloat _cachedTextStorageWidthMode;
  NSAttributedString *_cachedAttributedString;
  CGFloat _effectiveLetterSpacing;
}

static YGSize RCTMeasure(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode)
{
  RNTShadowDraftJSEditor *shadowText = (__bridge RNTShadowDraftJSEditor *)YGNodeGetContext(node);
  NSTextStorage *textStorage = [shadowText buildTextStorageForWidth:width widthMode:widthMode];
  [shadowText calculateTextFrame:textStorage];
  NSLayoutManager *layoutManager = textStorage.layoutManagers.firstObject;
  NSTextContainer *textContainer = layoutManager.textContainers.firstObject;
  CGSize computedSize = [layoutManager usedRectForTextContainer:textContainer].size;
  
  YGSize result;
  result.width = RCTCeilPixelValue(computedSize.width);
  if (shadowText->_effectiveLetterSpacing < 0) {
    result.width -= shadowText->_effectiveLetterSpacing;
  }
  result.height = RCTCeilPixelValue(computedSize.height);
  return result;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _fontSize = NAN;
    _letterSpacing = NAN;
    _textDecorationStyle = NSUnderlineStyleSingle;
    _opacity = 1.0;
    _cachedTextStorageWidth = -1;
    _cachedTextStorageWidthMode = -1;
    _fontSizeMultiplier = 1.0;
    YGNodeSetMeasureFunc(self.cssNode, RCTMeasure);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeMultiplierDidChange:)
                                                 name:RCTUIManagerWillUpdateViewsDueToContentSizeMultiplierChangeNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description
{
  NSString *superDescription = super.description;
  return [[superDescription substringToIndex:superDescription.length - 1] stringByAppendingFormat:@"; text: %@>", [self attributedString].string];
}

- (BOOL)isCSSLeafNode
{
  return YES;
}

- (void)contentSizeMultiplierDidChange:(NSNotification *)note
{
  YGNodeMarkDirty(self.cssNode);
  [self dirtyDraftJsText];
}

- (NSDictionary<NSString *, id> *)processUpdatedProperties:(NSMutableSet<RCTApplierBlock> *)applierBlocks
                                          parentProperties:(NSDictionary<NSString *, id> *)parentProperties
{
  if ([[self reactSuperview] isKindOfClass:[RNTShadowDraftJSEditor class]]) {
    return parentProperties;
  }
  
  parentProperties = [super processUpdatedProperties:applierBlocks
                                    parentProperties:parentProperties];
  
  UIEdgeInsets padding = self.paddingAsInsets;
  CGFloat width = self.frame.size.width - (padding.left + padding.right);
  
  NSTextStorage *textStorage = [self buildTextStorageForWidth:width widthMode:YGMeasureModeExactly];
  CGRect textFrame = [self calculateTextFrame:textStorage];
  
  NSString* lastBlockKey = ((RNDJBlockModel*) contentModel.blocks.lastObject).key;
  NSUInteger lastBlockIndex = ((RNDJBlockModel*) contentModel.blocks.lastObject).text.length;
  RNDJDraftJsIndex* lastIndex = lastBlockKey.length > 0 ? [[RNDJDraftJsIndex alloc] initWithKey:lastBlockKey offset:lastBlockIndex] : nil;
  
  BOOL selectable = _selectable;
  [applierBlocks addObject:^(NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNTDraftJSEditor *view = (RNTDraftJSEditor *)viewRegistry[self.reactTag];
    view.textFrame = textFrame;
    view.textStorage = textStorage;
    view.selectable = selectable;
    view.hasFocus = selectionModel ? selectionModel.hasFocus : NO;
    view.lastIndex = lastIndex;
  }];
  
  return parentProperties;
}

- (void)applyLayoutNode:(YGNodeRef)node
      viewsWithNewFrame:(NSMutableSet<RCTShadowView *> *)viewsWithNewFrame
       absolutePosition:(CGPoint)absolutePosition
{
  [super applyLayoutNode:node viewsWithNewFrame:viewsWithNewFrame absolutePosition:absolutePosition];
  [self dirtyPropagation];
}

- (void)applyLayoutToChildren:(YGNodeRef)node
            viewsWithNewFrame:(NSMutableSet<RCTShadowView *> *)viewsWithNewFrame
             absolutePosition:(CGPoint)absolutePosition
{
  // Run layout on subviews.
  NSTextStorage *textStorage = [self buildTextStorageForWidth:self.frame.size.width widthMode:YGMeasureModeExactly];
  NSLayoutManager *layoutManager = textStorage.layoutManagers.firstObject;
  NSTextContainer *textContainer = layoutManager.textContainers.firstObject;
  NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
  NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
  [layoutManager.textStorage enumerateAttribute:RCTShadowViewAttributeName inRange:characterRange options:0 usingBlock:^(RCTShadowView *child, NSRange range, BOOL *_) {
    if (child) {
      YGNodeRef childNode = child.cssNode;
      float width = YGNodeStyleGetWidth(childNode).value;
      float height = YGNodeStyleGetHeight(childNode).value;
      if (YGFloatIsUndefined(width) || YGFloatIsUndefined(height)) {
        RCTLogError(@"Views nested within a <Text> must have a width and height");
      }
      UIFont *font = [textStorage attribute:NSFontAttributeName atIndex:range.location effectiveRange:nil];
      CGRect glyphRect = [layoutManager boundingRectForGlyphRange:range inTextContainer:textContainer];
      CGRect childFrame = {{
        RCTRoundPixelValue(glyphRect.origin.x),
        RCTRoundPixelValue(glyphRect.origin.y + glyphRect.size.height - height + font.descender)
      }, {
        RCTRoundPixelValue(width),
        RCTRoundPixelValue(height)
      }};
      
      NSRange truncatedGlyphRange = [layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:range.location];
      BOOL childIsTruncated = NSIntersectionRange(range, truncatedGlyphRange).length != 0;
      
      [child collectUpdatedFrames:viewsWithNewFrame
                        withFrame:childFrame
                           hidden:childIsTruncated
                 absolutePosition:absolutePosition];
    }
  }];
}

- (NSTextStorage *)buildTextStorageForWidth:(CGFloat)width widthMode:(YGMeasureMode)widthMode
{
  if (_cachedTextStorage && width == _cachedTextStorageWidth && widthMode == _cachedTextStorageWidthMode) {
    return _cachedTextStorage;
  }
  
  NSLayoutManager *layoutManager = [NSLayoutManager new];
  
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedString];
  [textStorage addLayoutManager:layoutManager];
  
  NSTextContainer *textContainer = [NSTextContainer new];
  textContainer.lineFragmentPadding = 0.0;
  
  textContainer.maximumNumberOfLines = 0;
  textContainer.size = (CGSize){widthMode == YGMeasureModeUndefined ? CGFLOAT_MAX : width, CGFLOAT_MAX};
  
  [layoutManager addTextContainer:textContainer];
  [layoutManager ensureLayoutForTextContainer:textContainer];
  
  _cachedTextStorageWidth = width;
  _cachedTextStorageWidthMode = widthMode;
  _cachedTextStorage = textStorage;
  
  return textStorage;
}

- (void) dirtyDraftJsText
{
  [super dirtyDraftJsText];
  _cachedTextStorage = nil;
}

- (void)recomputeText
{
  [self attributedString];
  [self setDraftJsTextComputed];
  [self dirtyPropagation];
}

- (NSDictionary*) mapStyles:(NSDictionary*)styleDictionariesMap {
  NSMutableDictionary* retStyleMap = [NSMutableDictionary new];
  
  for (NSString* styleKey in [styleDictionariesMap allKeys]) {
    NSDictionary* styleDictionary = [styleDictionariesMap objectForKey:styleKey];
    RNDJStyle* style = [[RNDJStyle alloc] initWithDictionary:styleDictionary];
    
    if (style) {
      retStyleMap[styleKey] = style;
    }
  }

  return retStyleMap;
}

- (NSAttributedString *)attributedString
{
  if (![self isDraftJsTextDirty] && _cachedAttributedString && contentModel) {
    return _cachedAttributedString;
  }
  
  if (!_content) {
    return [[NSAttributedString alloc] initWithString:@""];
  }
  
  if (!contentModel) {
    contentModel = [RNDJContentModel fromDictionary:_content];
  }
  
  if (!selectionModel && _selection) {
    selectionModel = [RNDJSelectionModel fromDictionary:_selection];
  }
  
  RNDJStyle* rootStyle = [[RNDJStyle alloc] initWithShadowView:self];
  NSDictionary* blockTypeStyles = [self mapStyles:_blockFontTypes];
  NSDictionary* inlineStyles = [self mapStyles:_inlineStyleFontTypes];
  
  NSMutableAttributedString* contentAttributedString = [NSMutableAttributedString new];
  
  NSMutableSet* fullyHighlightedBlocks = [NSMutableSet new];
  
  BOOL isInHighlightedState = NO;
  NSInteger singleSelectionIndex = -1;
  
  BOOL isEmpty = YES;
  for (RNDJBlockModel* block in contentModel.blocks) {
    if (!isInHighlightedState && [block.key isEqualToString:selectionModel.startKey]) {
      isInHighlightedState = YES;
    } else if (isInHighlightedState && [block.key isEqualToString:selectionModel.endKey]) {
      isInHighlightedState = NO;
    } else if (isInHighlightedState) {
      [fullyHighlightedBlocks addObject:block.key];
    }
    
    if ([block.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 || [block.type isEqualToString:@"atomic"]) {
      isEmpty = NO;
    }
  }
  
  if (isEmpty) {
    if (selectionModel.hasFocus) {
      singleSelectionIndex = 0;
    } else {
      RNDJStyle* placeholderStyle = rootStyle;
      placeholderStyle = [placeholderStyle applyStyle:[blockTypeStyles objectForKey:@"placeholder"]];
      
      NSString *placeholderText = _placeholderText ? _placeholderText : @"";
      [self _appendText:placeholderText toAttributedString:contentAttributedString withStyle:placeholderStyle shouldAppendLineBreak:NO];
    }
  } else {
    for (RNDJBlockModel* block in contentModel.blocks) {
      RNDJStyle* blockStyle = rootStyle;
      
      NSString* blockType = block.type;
      if ([blockType isEqualToString:@"atomic"]) {
        // Skip for now
        continue;
      }
      
      NSMutableAttributedString* blockAttributedString = [NSMutableAttributedString new];
      
      if (blockType) {
        RNDJStyle* blockTypeStyle = [blockTypeStyles objectForKey:[blockType toJsStyleName]];
        blockStyle = [blockStyle applyStyle:blockTypeStyle];
      }
      
      NSString* text = block.text;
      NSUInteger startPosition = 0;
      NSUInteger endPosition = 0;
      
      NSSet* previousInlineStyles = nil;
      
      CGFloat lastLineHeight = 0;
      
      while (true) {
        NSMutableSet* currentInlineStyles = [NSMutableSet new];
        BOOL shouldUpdate = NO;
        BOOL shouldBreak = NO;
        BOOL shouldAppendLineBreak = NO;
        
        if (endPosition >= text.length) {
          if (startPosition != endPosition) {
            shouldUpdate = YES;
          }
          shouldAppendLineBreak = YES;
          shouldBreak = YES;
        } else {
          for (RNDJInlineStyleRangeModel* inlineStyleRange in block.inlineStyleRanges) {
            if (inlineStyleRange.style && inlineStyleRange.offset <= endPosition && endPosition < (inlineStyleRange.offset + inlineStyleRange.length)) {
              [currentInlineStyles addObject:inlineStyleRange.style];
            }
          }
          
          if (previousInlineStyles && ![currentInlineStyles isEqualToSet:previousInlineStyles]) {
            shouldUpdate = YES;
          }
        }
        
        if (shouldUpdate) {
          RNDJStyle* currentStyle = blockStyle;
          
          NSString* substring = [text substringWithRange:NSMakeRange(startPosition, endPosition - startPosition)];
          
          for (NSString* inlineStyleKey in currentInlineStyles) {
            currentStyle = [currentStyle applyStyle:[inlineStyles objectForKey:inlineStyleKey]];
          }
          
          if (currentStyle.lineHeight) {
            if ([currentStyle.allowFontScaling boolValue]) {
              lastLineHeight = [currentStyle.lineHeight floatValue] * _fontSizeMultiplier;
            } else {
              lastLineHeight = [currentStyle.lineHeight floatValue];
            }
          }
          
          [self _appendText:substring toAttributedString:blockAttributedString withStyle:currentStyle shouldAppendLineBreak:shouldAppendLineBreak];
          startPosition = endPosition;
        }
        
        if (shouldBreak) {
          break;
        }
        
        endPosition += 1;
      }
      
      if (selectionModel.hasFocus) {
        if ([selectionModel.startKey isEqualToString:selectionModel.startKey] && [selectionModel.startKey isEqualToString:selectionModel.endKey] && selectionModel.startOffset == selectionModel.endOffset) {
          singleSelectionIndex = contentAttributedString.length + selectionModel.startOffset;
        } else {
          if (blockAttributedString.length > 0) {
            if ([fullyHighlightedBlocks containsObject:block.key]) {
              [blockAttributedString addAttribute:RCTIsHighlightedAttributeName value:@YES range:NSMakeRange(0, blockAttributedString.length)];
            } else if ([block.key isEqualToString:selectionModel.startKey] && selectionModel.startOffset < blockAttributedString.length - 1) {
              [blockAttributedString addAttribute:RCTIsHighlightedAttributeName value:@YES range:NSMakeRange(selectionModel.startOffset, blockAttributedString.length - selectionModel.startOffset)];
            } else if ([block.key isEqualToString:selectionModel.endKey]) {
              NSUInteger endOffset = selectionModel.endOffset < blockAttributedString.length ? selectionModel.endOffset : blockAttributedString.length;
              [blockAttributedString addAttribute:RCTIsHighlightedAttributeName value:@YES range:NSMakeRange(0, endOffset)];
            }
          }
        }
      }
      
      [contentAttributedString appendAttributedString:blockAttributedString];
      
      for (NSUInteger i = 0; i<contentAttributedString.length; i++) {
        [contentAttributedString addAttribute:RNDJDraftJsIndexAttributeName
                                        value:[[RNDJDraftJsIndex alloc] initWithKey:block.key offset:MIN(i, block.text.length)]
                                        range:NSMakeRange(i, 1)];
      }
    }
  }
  
  if (singleSelectionIndex > -1) {
    if (singleSelectionIndex == contentAttributedString.length) {
      [contentAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    [contentAttributedString addAttribute:RNDJSingleCursorPositionAttributeName value:@YES range:NSMakeRange(singleSelectionIndex, 1)];
  }

  // create a non-mutable attributedString for use by the Text system which avoids copies down the line
  _cachedAttributedString = [[NSAttributedString alloc] initWithAttributedString:contentAttributedString];
  YGNodeMarkDirty(self.cssNode);
  
  return _cachedAttributedString;
}

- (void) _appendText:(NSString*)text toAttributedString:(NSMutableAttributedString*)outAttributedString withStyle:(RNDJStyle*)style shouldAppendLineBreak:(BOOL)shouldAppendLineBreak
{
  _effectiveLetterSpacing = [style.letterSpacing floatValue];
  
  UIFont *font = [RCTFont updateFont:nil
                          withFamily:style.fontFamily
                                size:style.fontSize
                              weight:style.fontWeight
                               style:style.fontStyle
                             variant:_fontVariant
                     scaleMultiplier:_allowFontScaling ? _fontSizeMultiplier : 1.0];
  
  CGFloat heightOfTallestSubview = 0.0;
  
  NSMutableDictionary* attributes = [NSMutableDictionary new];
  
  if (style.color) {
    attributes[NSForegroundColorAttributeName] = [style.color colorWithAlphaComponent:CGColorGetAlpha(style.color.CGColor) * [style.opacity floatValue]];
  }
  
  if (style.backgroundColor) {
    attributes[NSBackgroundColorAttributeName] = [style.backgroundColor colorWithAlphaComponent:CGColorGetAlpha(style.backgroundColor.CGColor) * [style.opacity floatValue]];
  }
  
  if (font) {
    attributes[NSFontAttributeName] = font;
  }
  
  if (style.letterSpacing) {
    attributes[NSKernAttributeName] = style.letterSpacing;
  }
  
  if (self.reactTag) {
    attributes[RCTReactTagAttributeName] = self.reactTag;
  }

  // Text decoration
  if (style.textDecorationLine == RCTTextDecorationLineTypeUnderline ||
      style.textDecorationLine == RCTTextDecorationLineTypeUnderlineStrikethrough) {
    attributes[NSUnderlineStyleAttributeName] = @(style.textDecorationStyle);
  }
  if (style.textDecorationLine == RCTTextDecorationLineTypeStrikethrough ||
      style.textDecorationLine == RCTTextDecorationLineTypeUnderlineStrikethrough){
    attributes[NSStrikethroughStyleAttributeName] = @(style.textDecorationStyle);
  }

  if (style.textDecorationColor) {
    attributes[NSStrikethroughColorAttributeName] = style.textDecorationColor;
    attributes[NSUnderlineColorAttributeName] = style.textDecorationColor;
  }
  
  // Text shadow
  CGSize textShadowOffset = (style.textShadowOffsetWidth && style.textShadowOffsetHeight) ? CGSizeMake([style.textShadowOffsetWidth floatValue], [style.textShadowOffsetHeight floatValue]) : CGSizeZero;
  if (!CGSizeEqualToSize(textShadowOffset, CGSizeZero)) {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = textShadowOffset;
    shadow.shadowBlurRadius = [style.textShadowRadius floatValue];
    shadow.shadowColor = style.textShadowColor;
    attributes[NSShadowAttributeName] = shadow;
  }
  
  text = text.length == 0 ? @" " : text;
  text = shouldAppendLineBreak ? [NSString stringWithFormat:@"%@ \n", text] : text;

  NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

  [self _setParagraphStyleOnAttributedString:attributedString
                              fontLineHeight:font.lineHeight
                      heightOfTallestSubview:heightOfTallestSubview
                                   withStyle:style];
  
  if (shouldAppendLineBreak) {
    NSLog(@"Break");
  }

//  - (void) _appendText:(NSString*)text toAttributedString:(NSMutableAttributedString*)attributedString withStyle:(RNDJStyle*)style shouldAppendLineBreak:(BOOL)shouldAppendLineBreak

  
  //  for (RCTShadowView *child in [self reactSubviews]) {
  //    if ([child isKindOfClass:[RCTShadowText class]]) {
  //      RCTShadowText *shadowText = (RCTShadowText *)child;
  //      [attributedString appendAttributedString:
  //       [shadowText _attributedStringWithFontFamily:fontFamily
  //                                          fontSize:fontSize
  //                                        fontWeight:fontWeight
  //                                         fontStyle:fontStyle
  //                                     letterSpacing:letterSpacing
  //                                useBackgroundColor:YES
  //                                   foregroundColor:shadowText.color ?: foregroundColor
  //                                   backgroundColor:shadowText.backgroundColor ?: backgroundColor
  //                                           opacity:opacity * shadowText.opacity]];
  //      [child setTextComputed];
  //    } else if ([child isKindOfClass:[RCTShadowRawText class]]) {
  //      RCTShadowRawText *shadowRawText = (RCTShadowRawText *)child;
  //      [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:shadowRawText.text ?: @""]];
  //      [child setTextComputed];
  //    } else {
  //      float width = YGNodeStyleGetWidth(child.cssNode).value;
  //      float height = YGNodeStyleGetHeight(child.cssNode).value;
  //      if (YGFloatIsUndefined(width) || YGFloatIsUndefined(height)) {
  //        RCTLogError(@"Views nested within a <Text> must have a width and height");
  //      }
  //      NSTextAttachment *attachment = [NSTextAttachment new];
  //      attachment.bounds = (CGRect){CGPointZero, {width, height}};
  //      NSMutableAttributedString *attachmentString = [NSMutableAttributedString new];
  //      [attachmentString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
  //      [attachmentString addAttribute:RCTShadowViewAttributeName value:child range:(NSRange){0, attachmentString.length}];
  //      [attributedString appendAttributedString:attachmentString];
  //      if (height > heightOfTallestSubview) {
  //        heightOfTallestSubview = height;
  //      }
  //      // Don't call setTextComputed on this child. RCTTextManager takes care of
  //      // processing inline UIViews.
  //    }
  //  }
  
  [outAttributedString appendAttributedString:attributedString];
}

// TODO: Move this to run after the block so there can be no conflicting paragraph styles set from inline styles
/*
 * LineHeight works the same way line-height works in the web: if children and self have
 * varying lineHeights, we simply take the max.
 */
- (void)_setParagraphStyleOnAttributedString:(NSMutableAttributedString *)attributedString
                              fontLineHeight:(CGFloat)fontLineHeight
                      heightOfTallestSubview:(CGFloat)heightOfTallestSubview
                                   withStyle:(RNDJStyle*)style
{
  NSRange fullRange = NSMakeRange(0, attributedString.length);
  
  // check if we have lineHeight set on self
  __block BOOL hasParagraphStyle = NO;
  if ([style.lineHeight floatValue] || style.textAlign) {
    hasParagraphStyle = YES;
  }
  
  __block float newLineHeight = [style.lineHeight floatValue] ?: 0.0;
  
  CGFloat fontSizeMultiplier = [style.allowFontScaling boolValue] ? _fontSizeMultiplier : 1.0;
  
  // check for lineHeight on each of our children, update the max as we go (in self.lineHeight)
  [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:(NSRange){0, attributedString.length} options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
    if (value) {
      NSParagraphStyle *paragraphStyle = (NSParagraphStyle *)value;
      CGFloat maximumLineHeight = round(paragraphStyle.maximumLineHeight / fontSizeMultiplier);
      if (maximumLineHeight > newLineHeight) {
        newLineHeight = maximumLineHeight;
      }
      hasParagraphStyle = YES;
    }
  }];
  
  NSTextAlignment newTextAlign = style.textAlign ?: NSTextAlignmentNatural;
  
  // The part below is to address textAlign for RTL language before setting paragraph style
  // Since we can't get layout directly because this logic is currently run just before layout is calculatede
  // We will climb up to the first node which style has been setted as non-inherit
  if (newTextAlign == NSTextAlignmentRight || newTextAlign == NSTextAlignmentLeft) {
    RCTShadowView *view = self;
    while (view != nil && YGNodeStyleGetDirection(view.cssNode) == YGDirectionInherit) {
      view = [view reactSuperview];
    }
    if (view != nil && YGNodeStyleGetDirection(view.cssNode) == YGDirectionRTL) {
      if (newTextAlign == NSTextAlignmentRight) {
        newTextAlign = NSTextAlignmentLeft;
      } else if (newTextAlign == NSTextAlignmentLeft) {
        newTextAlign = NSTextAlignmentRight;
      }
    }
  }

  // if we found anything, set it :D
  if (hasParagraphStyle) {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = style.textAlign;
    paragraphStyle.baseWritingDirection = NSWritingDirectionNatural;
    CGFloat lineHeight = round(newLineHeight * fontSizeMultiplier);
    if (heightOfTallestSubview > lineHeight) {
      lineHeight = ceilf(heightOfTallestSubview);
    }
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:fullRange];
    
    if (lineHeight > fontLineHeight) {
      [attributedString addAttribute:NSBaselineOffsetAttributeName
                               value:@(lineHeight / 2 - fontLineHeight / 2)
                               range:fullRange];
    }
  }
}

#pragma mark Autosizing

- (CGRect)calculateTextFrame:(NSTextStorage *)textStorage
{
  CGRect textFrame = UIEdgeInsetsInsetRect((CGRect){CGPointZero, self.frame.size},
                                           self.paddingAsInsets);
  
  return textFrame;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  super.backgroundColor = backgroundColor;
  [self dirtyDraftJsText];
}

#define RCT_TEXT_PROPERTY(setProp, ivar, type) \
- (void)set##setProp:(type)value;              \
{                                              \
ivar = value;                                \
[self dirtyDraftJsText];                            \
}

- (void) setContent:(NSDictionary *)content
{
  contentModel = nil;
  _content = content;
  [self dirtyDraftJsText];
}

- (void) setSelection:(NSDictionary *)selection
{
  selectionModel = nil;
  _selection = selection;
  [self dirtyDraftJsText];
}

- (NSDictionary*) content
{
  return _content;
}

RCT_TEXT_PROPERTY(Color, _color, UIColor *)
RCT_TEXT_PROPERTY(FontFamily, _fontFamily, NSString *)
RCT_TEXT_PROPERTY(FontSize, _fontSize, CGFloat)
RCT_TEXT_PROPERTY(FontWeight, _fontWeight, NSString *)
RCT_TEXT_PROPERTY(FontStyle, _fontStyle, NSString *)
RCT_TEXT_PROPERTY(FontVariant, _fontVariant, NSArray *)
RCT_TEXT_PROPERTY(LetterSpacing, _letterSpacing, CGFloat)
RCT_TEXT_PROPERTY(LineHeight, _lineHeight, CGFloat)
RCT_TEXT_PROPERTY(TextAlign, _textAlign, NSTextAlignment)
RCT_TEXT_PROPERTY(TextDecorationColor, _textDecorationColor, UIColor *);
RCT_TEXT_PROPERTY(TextDecorationLine, _textDecorationLine, RCTTextDecorationLineType);
RCT_TEXT_PROPERTY(TextDecorationStyle, _textDecorationStyle, NSUnderlineStyle);
RCT_TEXT_PROPERTY(Opacity, _opacity, CGFloat)
RCT_TEXT_PROPERTY(TextShadowOffset, _textShadowOffset, CGSize);
RCT_TEXT_PROPERTY(TextShadowRadius, _textShadowRadius, CGFloat);
RCT_TEXT_PROPERTY(TextShadowColor, _textShadowColor, UIColor *);

- (void)setAllowFontScaling:(BOOL)allowFontScaling
{
  _allowFontScaling = allowFontScaling;
  for (RCTShadowView *child in [self reactSubviews]) {
    if ([child isKindOfClass:[RNTShadowDraftJSEditor class]]) {
      ((RNTShadowDraftJSEditor *)child).allowFontScaling = allowFontScaling;
    }
  }
  [self dirtyDraftJsText];
}

- (void)setFontSizeMultiplier:(CGFloat)fontSizeMultiplier
{
  _fontSizeMultiplier = fontSizeMultiplier;
  if (_fontSizeMultiplier == 0) {
    RCTLogError(@"fontSizeMultiplier value must be > zero.");
    _fontSizeMultiplier = 1.0;
  }
  for (RCTShadowView *child in [self reactSubviews]) {
    if ([child isKindOfClass:[RNTShadowDraftJSEditor class]]) {
      ((RNTShadowDraftJSEditor *)child).fontSizeMultiplier = fontSizeMultiplier;
    }
  }
  [self dirtyDraftJsText];
}

@end

NSDictionary* blockTypesMap = nil;

@implementation NSString(DraftJsBlockTypesMap)

- (NSString*) toJsStyleName {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    blockTypesMap = @{
                      @"headerOne": @"header-one",
                      @"headerTwo": @"header-two",
                      @"headerThree": @"header-three",
                      @"headerFour": @"header-four",
                      @"headerFive": @"header-five",
                      @"headerSix": @"header-six",
                      @"codeBlock": @"code-block",
                      };
  });
  
  NSString* styleName = [blockTypesMap objectForKey:self];
  return styleName ? styleName : self;
}

@end
