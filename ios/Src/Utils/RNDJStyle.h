//
//  RNDJStyle.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/26/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNTShadowDraftJSEditor.h"
#import <React/RCTTextDecorationLineType.h>

@interface RNDJStyle : NSObject

@property (nonatomic, copy) NSString *fontFamily;
@property (nonatomic, copy) NSNumber *fontSize;
@property (nonatomic, copy) NSString *fontWeight;
@property (nonatomic, copy) NSString *fontStyle;
@property (nonatomic, copy) NSArray *fontVariant;
@property (nonatomic, assign) NSNumber *letterSpacing;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) NSNumber *opacity;

@property (nonatomic, assign) BOOL wasTextAlignSet;
@property (nonatomic, assign) NSTextAlignment textAlign;

@property (nonatomic, assign) NSNumber *lineHeight;

@property (nonatomic, assign) BOOL wasTextDecorationStyleSet;
@property (nonatomic, assign) NSUnderlineStyle textDecorationStyle;
@property (nonatomic, assign) BOOL wasTextDecorationLineSet;
@property (nonatomic, assign) RCTTextDecorationLineType textDecorationLine;
@property (nonatomic, strong) UIColor *textDecorationColor;

@property (nonatomic, assign) NSNumber *textShadowOffsetWidth;
@property (nonatomic, assign) NSNumber *textShadowOffsetHeight;
@property (nonatomic, assign) NSNumber *textShadowRadius;
@property (nonatomic, strong) UIColor *textShadowColor;

@property (nonatomic, assign) NSNumber *allowFontScaling;

- (instancetype) initWithStyle:(RNDJStyle *)style;
- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (instancetype) initWithShadowView:(RNTShadowDraftJSEditor *)shadowView;

- (RNDJStyle *) applyStyle:(RNDJStyle *)otherStyle;

@end
