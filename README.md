# react-native-rongcloud-imlib
Rongcloud IMLib Module For React Native
# prepare
```
npm install -g rnpm
```
# usage
```
npm install --save https://github.com/lotosbin/react-native-rongcloud-imlib.git
rnpm link react-native-rongcloud-imlib
```
## ios config
add framework
libopencore-amrnb.a
RongIMLib.framework
libsqlite3.tbd

add framework search paths & library search paths $(PROJECT_DIR)/../node_modules/react-native-rongcloud-imlib/ios/lib

## import
```
import RongCloud from 'react-native-rongcloud-imlib'
```
