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

export default {
    initWithAppKey (appKey) {
        return RongcloudModule.initWithAppKey(appKey);
    },
    connectWithToken (token) {
        return RongcloudModule.connectWithToken(token);
    },
    sendTextMessage () {
        
    }
};
