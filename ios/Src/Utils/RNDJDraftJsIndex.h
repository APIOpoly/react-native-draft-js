//
//  RNDJDraftJsIndex.h
//  RNDraftJs
//
//  Created by Andrew Beck on 10/27/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNDJDraftJsIndex : NSObject

- (instancetype) initWithKey:(NSString*)key offset:(NSUInteger)offset;

@property(readonly) NSString* key;
@property(readonly) NSUInteger offset;

@end

