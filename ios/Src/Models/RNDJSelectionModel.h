//
//  RNDJSelectionModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/26/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"

@interface RNDJSelectionModel : RNDJBaseModel

@property(readonly) BOOL hasFocus;

@property(readonly) NSString* startKey;
@property(readonly) NSUInteger startOffset;

@property(readonly) NSString* endKey;
@property(readonly) NSUInteger endOffset;

@end
