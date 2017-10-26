//
//  RNDJStyle.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/26/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJStyle.h"
#import "RNDJUtil.h"

#define GET(val, Type) [[dictionary objectForKey:NSStringize(val)] isKindOfClass:[Type class]] ? [dictionary objectForKey:NSStringize(val)] : nil

#define GET_SV(val) _ ## val = shadowView.val;
#define GET_SV_FLOAT(val) _ ## val = isnan(shadowView.val) ? nil : @(shadowView.val);

#define COPY(val) _ ## val = style.val;
#define COPY_IF_NOT_SET(val) if (style.val) {retStyle.val = style.val;}
#define COPY_IF_NOT_SET_BOOL(val, wasSetBool) if (style.wasSetBool) {retStyle.val = style.val;}

@implementation RNDJStyle

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
  if (self = [super init]) {
    _fontFamily = GET(fontFamily, NSString);
    _fontSize = GET(fontSize, NSNumber);
    _fontWeight = GET(fontWeight, NSString);
    _fontStyle = GET(fontStyle, NSString);
    _fontVariant = GET(fontVariant, NSArray);
    _letterSpacing = GET(letterSpacing, NSNumber);
    _color = GET(color, NSString);
    _backgroundColor = GET(backgroundColor, NSString);
    _opacity = GET(opacity, NSNumber);
    _lineHeight = GET(lineHeight, NSNumber);
    _textDecorationColor = GET(textDecorationColor, NSString);
    _textShadowRadius = GET(textShadowRadius, NSNumber);
    _textShadowColor = GET(textShadowColor, NSString);
    _allowFontScaling = GET(allowFontScaling, NSString);

    NSValue* textShadowOffset = dictionary[@"textShadowOffset"];
    if ([textShadowOffset isKindOfClass:[NSValue class]]) {
      CGSize textShadowOffsetSize = [textShadowOffset CGSizeValue];
      if (!isnan(textShadowOffsetSize.width) && !isnan(textShadowOffsetSize.height)) {
        _textShadowOffsetWidth = @(textShadowOffsetSize.width);
        _textShadowOffsetHeight = @(textShadowOffsetSize.height);
      }
    }
    
    NSString* textAlign = GET(textAlign, NSString);
    if ([textAlign isEqualToString:@"auto"]) {
      _textAlign = NSTextAlignmentNatural;
      _wasTextAlignSet = YES;
    } else if ([textAlign isEqualToString:@"left"]) {
      _textAlign = NSTextAlignmentLeft;
      _wasTextAlignSet = YES;
    } else if ([textAlign isEqualToString:@"center"]) {
      _textAlign = NSTextAlignmentCenter;
      _wasTextAlignSet = YES;
    } else if ([textAlign isEqualToString:@"right"]) {
      _textAlign = NSTextAlignmentRight;
      _wasTextAlignSet = YES;
    } else if ([textAlign isEqualToString:@"justify"]) {
      _textAlign = NSTextAlignmentJustified;
      _wasTextAlignSet = YES;
    }
    
    NSString* textDecorationLine = GET(textDecorationLine, NSString);
    if ([textDecorationLine isEqualToString:@"none"]) {
      _wasTextDecorationLineSet = YES;
    } else if ([textDecorationLine isEqualToString:@"underline"]) {
      _textDecorationLine = RCTTextDecorationLineTypeUnderline;
      _wasTextDecorationLineSet = YES;
    } else if ([textDecorationLine isEqualToString:@"line-through"]) {
      _textDecorationLine = RCTTextDecorationLineTypeStrikethrough;
      _wasTextDecorationLineSet = YES;
    } else if ([textDecorationLine isEqualToString:@"underline line-through"]) {
      _textDecorationLine = RCTTextDecorationLineTypeUnderlineStrikethrough;
      _wasTextDecorationLineSet = YES;
    }
    
    NSString* textDecorationStyle = GET(textDecorationStyle, NSString);
    if ([textDecorationStyle isEqualToString:@"solid"]) {
      _textDecorationStyle = NSUnderlineStyleSingle;
      _wasTextDecorationStyleSet = YES;
    } else if ([textDecorationStyle isEqualToString:@"double"]) {
      _textDecorationStyle = NSUnderlineStyleDouble;
      _wasTextDecorationStyleSet = YES;
    } else if ([textDecorationStyle isEqualToString:@"dotted"]) {
      _textDecorationStyle = NSUnderlinePatternDot | NSUnderlineStyleSingle;
      _wasTextDecorationStyleSet = YES;
    } else if ([textDecorationStyle isEqualToString:@"dashed"]) {
      _textDecorationStyle = NSUnderlinePatternDash | NSUnderlineStyleSingle;
      _wasTextDecorationStyleSet = YES;
    }
  }
  
  return self;
}

- (void) setTextDecorationStyle:(NSUnderlineStyle)textDecorationStyle {
  _textDecorationStyle = textDecorationStyle;
  _wasTextDecorationStyleSet = YES;
}

- (void) setTextDecorationLine:(RCTTextDecorationLineType)textDecorationLine {
  _textDecorationLine = textDecorationLine;
  _wasTextDecorationLineSet = YES;
}

- (void) setTextAlign:(NSTextAlignment)textAlign {
  _textAlign = textAlign;
  _wasTextAlignSet = YES;
}

- (instancetype) initWithShadowView:(RNTShadowDraftJSEditor *)shadowView {
  if (self = [super init]) {
    GET_SV(fontFamily)
    GET_SV(fontWeight)
    GET_SV(fontStyle)
    GET_SV(fontVariant)
    GET_SV(color)
    GET_SV(textDecorationColor)
    GET_SV(textShadowColor)
    GET_SV(backgroundColor)

    GET_SV(textAlign)
    _wasTextAlignSet = YES;
    GET_SV(textDecorationStyle)
    _wasTextDecorationStyleSet = YES;
    GET_SV(textDecorationLine)
    _wasTextDecorationLineSet = YES;
    
    GET_SV_FLOAT(fontSize)
    GET_SV_FLOAT(letterSpacing)
    GET_SV_FLOAT(opacity)
    GET_SV_FLOAT(lineHeight)
    GET_SV_FLOAT(textShadowRadius)
    
    if (!isnan(shadowView.textShadowOffset.width) && !isnan(shadowView.textShadowOffset.height)) {
      _textShadowOffsetWidth = @(shadowView.textShadowOffset.width);
      _textShadowOffsetHeight = @(shadowView.textShadowOffset.height);
    }
    
    _allowFontScaling = @(shadowView.allowFontScaling);
  }
  
  return self;
}

- (instancetype) initWithStyle:(RNDJStyle *)style {
  if (self = [super init]) {
    COPY(fontFamily)
    COPY(fontSize)
    COPY(fontWeight)
    COPY(fontStyle)
    COPY(fontVariant)
    COPY(letterSpacing)
    COPY(color)
    COPY(backgroundColor)
    COPY(opacity)
    COPY(wasTextAlignSet)
    COPY(textAlign)
    COPY(lineHeight)
    COPY(wasTextDecorationStyleSet)
    COPY(textDecorationStyle)
    COPY(wasTextDecorationLineSet)
    COPY(textDecorationLine)
    COPY(textDecorationColor)
    COPY(textShadowOffsetWidth)
    COPY(textShadowOffsetHeight)
    COPY(textShadowRadius)
    COPY(textShadowColor)
    COPY(allowFontScaling)
  }
  
  return self;
}


- (RNDJStyle *) applyStyle:(RNDJStyle *)style {
  RNDJStyle* retStyle = [[RNDJStyle alloc] initWithStyle:self];
  
  if (!style) {
    return retStyle;
  }
  
  COPY_IF_NOT_SET(fontFamily)
  COPY_IF_NOT_SET(fontSize)
  COPY_IF_NOT_SET(fontWeight)
  COPY_IF_NOT_SET(fontStyle)
  COPY_IF_NOT_SET(fontVariant)
  COPY_IF_NOT_SET(letterSpacing)
  COPY_IF_NOT_SET(color)
  COPY_IF_NOT_SET(backgroundColor)
  COPY_IF_NOT_SET(opacity)
  COPY_IF_NOT_SET(lineHeight)
  COPY_IF_NOT_SET(textDecorationColor)
  COPY_IF_NOT_SET(textShadowOffsetWidth)
  COPY_IF_NOT_SET(textShadowOffsetHeight)
  COPY_IF_NOT_SET(textShadowRadius)
  COPY_IF_NOT_SET(textShadowColor)
  COPY_IF_NOT_SET(allowFontScaling)
  
  COPY_IF_NOT_SET_BOOL(textAlign, wasTextAlignSet)
  COPY_IF_NOT_SET_BOOL(textDecorationStyle, wasTextDecorationStyleSet)
  COPY_IF_NOT_SET_BOOL(textDecorationLine, wasTextDecorationLineSet)

  return retStyle;
}

@end
