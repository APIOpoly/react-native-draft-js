//
//  RNDJBaseModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

@interface RNDJBaseModel : NSObject
{
  NSDictionary* properties;
}

+ (instancetype) fromDictionary:(NSDictionary*)modelDictionary;
+ (NSArray*) fromDictionaries:(NSArray*)modelDictionaries;
+ (NSDictionary*) fromMap:(NSDictionary*)modelDictionaryMap;

@end

#define REGISTER_PROPERTY(propName, DictionaryType, PropertyType, propertyTypeFromDictionaryType, default) \
- (PropertyType) propName \
{ \
DictionaryType dictValue = [properties objectForKey:NSStringize(propName)]; \
if (dictValue) {return propertyTypeFromDictionaryType(dictValue);} \
return default; \
}

NSString* stringFromString(NSString* inString) {
  return [inString isKindOfClass:[NSString class]] ? inString : nil;
}
#define REGISTER_STRING(propName) REGISTER_PROPERTY(propName, NSString*, NSString*, stringFromString, nil)

//NSNumberFormatterNoStyle
//NSNumberFormatterDecimalStyle
#define CONVERT_NSNUMBER_IF_NEEDED(inObject, formatterStyle) \
if ([inObject isKindOfClass:[NSString class]]) { \
NSNumberFormatter* f = [[NSNumberFormatter alloc] init]; \
f.numberStyle = formatterStyle; \
inObject = [f numberFromString:(NSString*) inObject]; \
}

NSUInteger unsignedIntegerFromNSNumber(NSNumber* inNumber) {
  CONVERT_NSNUMBER_IF_NEEDED(inNumber, NSNumberFormatterNoStyle)
  return [inNumber unsignedIntegerValue];
}
#define REGISTER_UINTEGER(propName) REGISTER_PROPERTY(propName, NSNumber*, NSUInteger, unsignedIntegerFromNSNumber, 0)

CGFloat floatFromNSNumber(NSNumber* inNumber) {
  CONVERT_NSNUMBER_IF_NEEDED(inNumber, NSNumberFormatterDecimalStyle)
  return [inNumber floatValue];
}
#define REGISTER_FLOAT(propName) REGISTER_PROPERTY(propName, NSNumber*, CGFloat, floatFromNSNumber, 0)

bool boolFromNSNumber(NSNumber* inNumber) {
  if ([inNumber isKindOfClass:[NSString class]]) {
    NSString* inString = [((NSString*) inNumber) uppercaseString];
    if ([inString isEqualToString:@"YES"] || [inString isEqualToString:@"TRUE"]) {
      return true;
    }
    return false;
  }
  return [inNumber boolValue];
}
#define REGISTER_BOOL(propName) REGISTER_PROPERTY(propName, NSNumber*, bool, boolFromNSNumber, false)

UIColor* colorFromColor(UIColor* inColor) {
  return [inColor isKindOfClass:[UIColor class]] ? inColor : nil;
}
#define REGISTER_COLOR(propName) REGISTER_PROPERTY(propName, UIColor*, UIColor*, colorFromColor, nil)

NSDictionary* dictionaryFromDictionary(NSDictionary* inDict) {
  return [inDict isKindOfClass:[NSDictionary class]] ? inDict : nil;
}
#define REGISTER_DICTIONARY(propName) REGISTER_PROPERTY(propName, NSDictionary*, NSDictionary*, dictionaryFromDictionary, nil)

#define REGISTER_SUBOBJECT(propName, ModelType) \
- (ModelType) propName \
{ \
NSDictionary* subObjectDictionary = [properties objectForKey:NSStringize(propName)]; \
if (subObjectDictionary) {return [ModelType fromDictionary:subObjectDictionary];} \
return nil; \
}

#define REGISTER_SUBOBJECT_ARRAY(propName, ModelType) \
- (NSArray*) propName \
{ \
NSArray* subObjectArray = [properties objectForKey:NSStringize(propName)]; \
if (subObjectArray) {return [ModelType fromDictionaries:subObjectArray];} \
return @[]; \
}

#define REGISTER_SUBOBJECT_MAP(propName, ModelType) \
- (NSDictionary*) propName \
{ \
NSDictionary* subObjectMap = [properties objectForKey:NSStringize(propName)]; \
if (subObjectMap) {return [ModelType fromMap:subObjectMap];} \
return @{}; \
}

