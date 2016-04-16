import {
    NativeModules,
    DeviceEventEmitter
} from 'react-native';

const RongcloudModule = NativeModules.RongcloudModule;

var _onRongCloudMessageReceived = function(resp) {

}
DeviceEventEmitter.addListener('onRongCloudMessageReceived', resp => {
    typeof _onRongCloudMessageReceived === 'function' && _onRongCloudMessageReceived(resp);
});

const ConversationType = {
    PRIVATE: 'PRIVATE',
    DISCUSSION: 'DISCUSSION',
    SYSTEM: 'SYSTEM'
};

export default {
    ConversationType: ConversationType,
    initWithAppKey (appKey) {
        return RongcloudModule.initWithAppKey(appKey);
    },
    connectWithToken (token) {
        return RongcloudModule.connectWithToken(token);
    },
    sendTextMessage (conversationType, targetId, content) {
        return RongcloudModule.sendTextMessage(conversationType, targetId, content, content);
    }
};
