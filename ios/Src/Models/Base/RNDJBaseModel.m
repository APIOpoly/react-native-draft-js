//
//  RNDJBaseModel.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"

@implementation RNDJBaseModel

- (instancetype) initWithProperties:(NSDictionary*)inProperties {
  if ([inProperties isKindOfClass:[NSDictionary class]] && (self = [super init])) {
    properties = inProperties;
    return self;
  }
  return nil;
}

+ (instancetype) fromDictionary:(NSDictionary*)modelDictionary
{
  return [[self alloc] initWithProperties:modelDictionary];
}

+ (NSArray*) fromDictionaries:(NSArray*)modelDictionaries
{
  NSMutableArray* outArray = [@[] mutableCopy];
  for (NSDictionary* modelDictionary in modelDictionaries) {
    id obj = [[self alloc] initWithProperties:modelDictionary];
    if (obj) {
      [outArray addObject:obj];
    }
  }
  return [NSArray arrayWithArray:outArray];
}

+ (NSDictionary*) fromMap:(NSDictionary*)modelDictionaryMap
{
  NSMutableDictionary* outMap = [@{} mutableCopy];
  for (id<NSCopying> key in [modelDictionaryMap allKeys]) {
    id obj = [[self alloc] initWithProperties:[modelDictionaryMap objectForKey:key]];
    if (obj) {
      outMap[key] = obj;
    }
  }
  return [NSDictionary dictionaryWithDictionary:outMap];
}

@end
