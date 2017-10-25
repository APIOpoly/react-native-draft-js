//
//  RNDJBlockModel.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBlockModel.h"

@implementation RNDJBlockModel

REGISTER_SUBOBJECT_ARRAY(entityRanges, RNDJEntityRangeModel)
REGISTER_SUBOBJECT_ARRAY(inlineStyleRanges, RNDJInlineStyleRangeModel)

REGISTER_STRING(key)
REGISTER_STRING(text)
REGISTER_STRING(type)

@end
