//
//  RNDJEntityModel.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNDJBaseModel.h"

@interface RNDJEntityModel : RNDJBaseModel

@property(readonly) NSDictionary* data;
@property(readonly) NSString* type;

@end
