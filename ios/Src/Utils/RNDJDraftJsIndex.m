//
//  RNDJDraftJsIndex.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/27/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJDraftJsIndex.h"

@implementation RNDJDraftJsIndex

- (instancetype) initWithKey:(NSString*)key offset:(NSUInteger)offset
{
  if (self = [super init]) {
    _key = key;
    _offset = offset;
  }
  return self;
}

@end

