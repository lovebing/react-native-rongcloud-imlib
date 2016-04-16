//
//  RCTRongCloudIMLib.m
//  RCTRongCloudIMLib
//
//  Created by lovebing on 3/21/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTRongCloudIMLib.h"

@implementation RCTRongCloudIMLib
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RongCloudIMLibModule)

RCT_EXPORT_METHOD(initWithAppKey:(NSString *) appkey) {
    NSLog(@"initWithAppKey %@", appkey);
    [[self getClient] initWithAppKey:appkey];
    
    [[self getClient] setReceiveMessageDelegate:self object:nil];
}

RCT_EXPORT_METHOD(setDeviceToken:(NSString *) deviceToken) {
    [[self getClient] setDeviceToken:deviceToken];
}

RCT_EXPORT_METHOD(connectWithToken:(NSString *) token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"connectWithToken %@", token);
    
    void (^successBlock)(NSString *userId);
    successBlock = ^(NSString* userId) {
        NSArray *events = [[NSArray alloc] initWithObjects:userId,nil];
        resolve(@[[NSNull null], events]);
    };
    
    void (^errorBlock)(RCConnectErrorCode status);
    errorBlock = ^(RCConnectErrorCode status) {
        NSString *errcode;
        switch (status) {
            case RC_CONN_ID_REJECT:
                errcode = @"RC_CONN_ID_REJECT";
                break;
            case RC_CONN_TOKEN_INCORRECT:
                errcode = @"RC_CONN_TOKEN_INCORRECT";
                break;
            case RC_CONN_NOT_AUTHRORIZED:
                errcode = @"RC_CONN_NOT_AUTHRORIZED";
                break;
            case RC_CONN_PACKAGE_NAME_INVALID:
                errcode = @"RC_CONN_PACKAGE_NAME_INVALID";
                break;
            case RC_CONN_APP_BLOCKED_OR_DELETED:
                errcode = @"RC_CONN_APP_BLOCKED_OR_DELETED";
                break;
            case RC_DISCONN_KICK:
                errcode = @"RC_DISCONN_KICK";
                break;
            case RC_CLIENT_NOT_INIT:
                errcode = @"RC_CLIENT_NOT_INIT";
                break;
            case RC_INVALID_PARAMETER:
                errcode = @"RC_INVALID_PARAMETER";
                break;
            case RC_INVALID_ARGUMENT:
                errcode = @"RC_INVALID_ARGUMENT";
                break;
                
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    void (^tokenIncorrectBlock)();
    tokenIncorrectBlock = ^() {
        reject(@"TOKEN_INCORRECT", @"tokenIncorrect", nil);
    };
    
    [[self getClient] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
    
}

RCT_EXPORT_METHOD(sendTextMessage:(NSString *)type
                  targetId:(NSString *)targetId
                  content:(NSString *)content
                  pushContent:(NSString *) pushContent
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:content];
    [self sendMessage:type targetId:targetId content:messageContent pushContent:pushContent resolve:resolve reject:reject];
    
    
}

RCT_EXPORT_METHOD(getSDKVersion:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString* version = [[self getClient] getSDKVersion];
    resolve(version);
}

RCT_EXPORT_METHOD(disconnect:(BOOL)isReceivePush) {
    [[self getClient] disconnect:isReceivePush];
}

-(RCIMClient *) getClient {
    return [RCIMClient sharedRCIMClient];
}

-(void)sendMessage:(NSString *)type
          targetId:(NSString *)targetId
           content:(RCMessageContent *)content
       pushContent:(NSString *) pushContent
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    
    RCConversationType conversationType;
    if([type isEqualToString:@"PRIVATE"]) {
        conversationType = ConversationType_PRIVATE;
    }
    else if([type isEqualToString:@"DISCUSSION"]) {
        conversationType = ConversationType_DISCUSSION;
    }
    else {
        conversationType = ConversationType_SYSTEM;
    }
    
    void (^successBlock)(long messageId);
    successBlock = ^(long messageId) {
        NSString* id = [NSString stringWithFormat:@"%ld",messageId];
        resolve(id);
    };
    
    void (^errorBlock)(RCErrorCode nErrorCode , long messageId);
    errorBlock = ^(RCErrorCode nErrorCode , long messageId) {
        reject(nil, nil, nil);
    };
    
    
    [[self getClient] sendMessage:conversationType targetId:targetId content:content pushContent:pushContent success:successBlock error:errorBlock];
    
}

-(void)onReceived:(RCMessage *)message
             left:(int)nLeft
           object:(id)object {
    
    NSLog(@"onRongCloudMessageReceived");
    
    NSMutableDictionary *body = [self getEmptyBody];
    NSMutableDictionary *_message = [self getEmptyBody];
    _message[@"targetId"] = message.targetId;
    _message[@"senderUserId"] = message.senderUserId;
    _message[@"messageId"] = [NSString stringWithFormat:@"%ld",message.messageId];
    _message[@"sentTime"] = [NSString stringWithFormat:@"%lld",message.sentTime];
    
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        _message[@"content"] = testMessage.content;
    }
    else if([message.content isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)message.content;
        _message[@"imageUrl"] = imageMessage.imageUrl;
        _message[@"thumbnailImage"] = imageMessage.thumbnailImage;
    }
    else if([message.content isMemberOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *richMessage = (RCRichContentMessage *)message.content;
    }
    
    
    body[@"left"] = [NSString stringWithFormat:@"%d",nLeft];
    body[@"message"] = _message;
    body[@"errcode"] = @"0";
    
    [self sendEvent:@"onRongCloudMessageReceived" body:body];
}

-(NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

-(void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body {
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:name body:body];
}

@end