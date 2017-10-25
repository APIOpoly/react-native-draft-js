//
//  RNDJEntityRangeModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"

@interface RNDJEntityRangeModel : RNDJBaseModel

@property(readonly) NSUInteger key;
@property(readonly) NSUInteger length;
@property(readonly) NSUInteger offset;

@end
