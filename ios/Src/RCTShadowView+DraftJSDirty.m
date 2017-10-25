//
//  RCTShadowView+DraftJSDirty.m
//  RNDraftJs
//
//  Created by Andrew Beck on 10/24/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RCTShadowView+DraftJSDirty.h"
#import <objc/runtime.h>

static char kAssociatedDraftJsTextLifecycleKey;

@implementation RCTShadowView (DraftJSDirty)

- (void) setDraftJsTextLifecycle:(RCTUpdateLifecycle)draftJsTextLifecycle
{
  NSNumber* draftJsLifecycleObject = [NSNumber numberWithUnsignedInteger:draftJsTextLifecycle];
  objc_setAssociatedObject(self, &kAssociatedDraftJsTextLifecycleKey, draftJsLifecycleObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RCTUpdateLifecycle) draftJsTextLifecycle
{
  NSNumber* draftJsLifecycleObject = objc_getAssociatedObject(self, &kAssociatedDraftJsTextLifecycleKey);
  RCTUpdateLifecycle draftJsLifecycle = [draftJsLifecycleObject unsignedIntegerValue];
  return draftJsLifecycle;
}

- (void) dirtyDraftJsText
{
  if ([self draftJsTextLifecycle] != RCTUpdateLifecycleDirtied) {
    [self setDraftJsTextLifecycle: RCTUpdateLifecycleDirtied];
    [[self superview] dirtyDraftJsText];
  }
}

- (BOOL) isDraftJsTextDirty
{
  return [self draftJsTextLifecycle] != RCTUpdateLifecycleComputed;
}

- (void) setDraftJsTextComputed
{
  [self setDraftJsTextLifecycle: RCTUpdateLifecycleComputed];
}

@end
