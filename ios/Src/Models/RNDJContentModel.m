//
//  RNDJContentModel.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJContentModel.h"

@implementation RNDJContentModel

- (NSArray*) blocks
{
  NSArray* subObjectArray = [properties objectForKey:@"blocks"];

  if (subObjectArray) {
    NSArray* blocks = [RNDJBlockModel fromDictionaries:subObjectArray];
    ((RNDJBlockModel*)[blocks lastObject]).isLastBlock = YES;
    return blocks;
  }

  return @[];
}

REGISTER_SUBOBJECT_MAP(entityMap, RNDJEntityModel)

@end
