package org.lovebing.reactnative.rongcloud;

import java.util.List;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import android.support.annotation.Nullable;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.message.RichContentMessage;
import io.rong.message.TextMessage;

/**
 * Created by lovebing on 3/25/16.
 */
public class RongCloudIMLibModule  extends ReactContextBaseJavaModule {

    protected ReactApplicationContext context;
    /**
     *
     * @param reactContext
     */
    public RongCloudIMLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    @Override
    public String getName() {
        return "RongCloudIMLibModule";
    }


    @ReactMethod
    public void initWithAppKey(String appKey) {
        RongIMClient.init(context, appKey);
    }

    @ReactMethod
    public void connectWithToken(String token, final Promise promise) {
        final RongCloudIMLibModule instance = this;
        RongIMClient.setOnReceiveMessageListener(new RongIMClient.OnReceiveMessageListener() {
            @Override
            public boolean onReceived(Message message, int i) {

                WritableMap map = Arguments.createMap();
                WritableMap msg = instance.formatMessage(message);

                map.putMap("message", msg);
                map.putString("left","0");
                map.putString("errcode", "0");

                instance.sendEvent("onRongCloudMessageReceived", map);
                return true;
            }
        });

        RongIMClient.connect(token, new RongIMClient.ConnectCallback() {
            /**
             * Token 错误，在线上环境下主要是因为 Token 已经过期，您需要向 App Server 重新请求一个新的 Token
             */
            @Override
            public void onTokenIncorrect() {
                promise.reject("-1", "tokenIncorrect");
            }

            /**
             * 连接融云成功
             * @param userid 当前 token
             */
            @Override
            public void onSuccess(String userid) {
                WritableMap map = Arguments.createMap();
                map.putString("userid", userid);
                promise.resolve(map);
            }

            /**
             * 连接融云失败
             * @param errorCode 错误码，可到官网 查看错误码对应的注释
             */
            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                String code = errorCode.getValue() + "";
                String msg = errorCode.getMessage();
                promise.reject(code, msg);
            }
        });
    }


    @ReactMethod
    public void getLocalLatestMessages(String type, String targetId, int count, final Promise promise) {
        Conversation.ConversationType conversationType = ConversationType(type);
        RongIMClient.getInstance().getLatestMessages(conversationType, targetId, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject(errorCode.getValue() + "", errorCode.getMessage());
            }


            @Override
            public void onSuccess(List<Message> messages) {
                WritableArray data = Arguments.createArray();
                if(messages != null && !messages.isEmpty()) {
                    for(int i = 0; i < messages.size(); i++) {
                        Message message = messages.get(i);
                        WritableMap item = formatMessage(message);
                        data.pushMap(item);
                    }
                }
                promise.resolve(data);
            }
        });
    }


    @ReactMethod
    public void sendTextMessage(String type, String targetId, String content, String pushContent, Promise promise) {
        TextMessage textMessage = TextMessage.obtain(content);
        sendMessage(type, targetId, textMessage, pushContent, promise);
    }

    /**
     *
     * @param message
     * @return
     */
    protected WritableMap formatMessage(Message message) {
        WritableMap msg = Arguments.createMap();

        msg.putString("targetId", message.getTargetId());
        msg.putString("senderUserId", message.getSenderUserId());
        msg.putString("messageId", message.getMessageId() + "");
        msg.putString("sentTime", message.getSentTime() + "");

        if(message.getContent() instanceof TextMessage) {
            TextMessage textMessage = (TextMessage)message.getContent();
            msg.putString("content", textMessage.getContent());
        }
        else if(message.getContent() instanceof RichContentMessage) {
            RichContentMessage richContentMessage = (RichContentMessage)message.getContent();
            msg.putString("imageUrl", richContentMessage.getImgUrl());
        }

        return msg;
    }
    protected Conversation.ConversationType ConversationType(String type) {
        Conversation.ConversationType conversationType;
        if(type == "PRIVATE") {
            conversationType = Conversation.ConversationType.PRIVATE;
        }
        else if(type == "DISCUSSION") {
            conversationType = Conversation.ConversationType.DISCUSSION;
        }
        else {
            conversationType = Conversation.ConversationType.SYSTEM;
        }
        return conversationType;
    }

    protected void sendMessage(String type, String targetId, MessageContent content, String pushContent, final Promise promise) {

        Conversation.ConversationType conversationType = ConversationType(type);

        String pushData = "";

        RongIMClient.getInstance().sendMessage(conversationType, targetId, content, pushContent, pushData,
                new RongIMClient.SendMessageCallback() {
                    @Override
                    public void onSuccess(Integer integer) {
                        WritableMap map = Arguments.createMap();
                        map.putString("errcode", "0");
                        //promise.resolve(map);
                    }

                    @Override
                    public void onError(Integer integer, RongIMClient.ErrorCode errorCode) {
                        //promise.reject(errorCode.getValue() + "", errorCode.getMessage());
                    }
                },
                new RongIMClient.ResultCallback<Message>(){
                    @Override
                    public void onSuccess(Message message) {
                        WritableMap map = Arguments.createMap();
                        map.putString("errcode", "0");
                        //promise.resolve(map);
                    }
                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        //promise.reject(errorCode.getValue() + "", errorCode.getMessage());
                    }
                });
    }

    protected void sendEvent(String eventName,@Nullable WritableMap params) {
        context
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}