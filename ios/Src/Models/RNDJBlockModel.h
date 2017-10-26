//
//  RNDJBlockModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"
#import "RNDJEntityRangeModel.h"
#import "RNDJInlineStyleRangeModel.h"

@interface RNDJBlockModel : RNDJBaseModel

@property(readonly) NSArray* entityRanges;
@property(readonly) NSArray* inlineStyleRanges;

@property(readonly) NSString* key;
@property(readonly) NSString* text;
@property(readonly) NSString* type;

@property(assign) BOOL isLastBlock;

@end
