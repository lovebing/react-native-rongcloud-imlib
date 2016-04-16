import {
    NativeModules,
    DeviceEventEmitter
} from 'react-native';

const RongCloudIMLib = NativeModules.RongCloudIMLibModule;

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
    onReceived (callback) {
        _onRongCloudMessageReceived = callback;
    },
    initWithAppKey (appKey) {
        return RongCloudIMLib.initWithAppKey(appKey);
    },
    connectWithToken (token) {
        return RongCloudIMLib.connectWithToken(token);
    },
    sendTextMessage (conversationType, targetId, content) {
        return RongCloudIMLib.sendTextMessage(conversationType, targetId, content, content);
    }
};
