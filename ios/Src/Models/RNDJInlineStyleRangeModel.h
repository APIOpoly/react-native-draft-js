//
//  RNDJInlineStyleRangeModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"

@interface RNDJInlineStyleRangeModel : RNDJBaseModel

@property(readonly) NSUInteger length;
@property(readonly) NSUInteger offset;
@property(readonly) NSString* style;

@end
