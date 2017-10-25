//
//  RNDJContentModel.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJContentModel.h"

@implementation RNDJContentModel

REGISTER_SUBOBJECT_ARRAY(blocks, RNDJBlockModel)
REGISTER_SUBOBJECT_MAP(entityMap, RNDJEntityModel)

@end
