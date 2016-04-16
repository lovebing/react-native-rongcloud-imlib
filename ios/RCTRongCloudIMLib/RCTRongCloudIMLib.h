//
//  RCTRongCloudIMLib.h
//  RCTRongCloudIMLib
//
//  Created by lovebing on 3/21/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "RCTBridge.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMLib/RCIMClient.h>


@interface RCTRongCloudIMLib: NSObject <RCTBridgeModule, RCIMClientReceiveMessageDelegate> {
    
}
-(RCIMClient *) getClient;

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object;

-(void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body;

-(void)sendMessage:(NSString *)type
          targetId:(NSString *)targetId
           content:(RCMessageContent *)content
       pushContent:(NSString *) pushContent
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

-(NSMutableDictionary *)getEmptyBody;

@end
