# react-native-xg-push

## 注意：

* 只集成了信鸽基本的功能，未集成海外推送，渠道推送


## 安装

```
yarn add react-native-smart-xgpush
```
或

```
npm install react-native-smart-xgpush --save
```

## 配置

配置需要两步：自动配置和手动添加

### 1.自动部分(link)

```
react-native link react-native-smart-xgpush
```

### 2.手动添加

#### android
* 打开android/app/build.gradle
找到
```
android {
    compileSdkVersion 23
    buildToolsVersion "23.0.1"
	defaultConfig {
   		applicationId "com.tcoadebug"
    	minSdkVersion 16
	    targetSdkVersion 22
	    versionCode 1
    	versionName "1.0"
	    ndk {
    	    abiFilters "armeabi-v7a", "x86"
	    }
	}
....
在ndk{}下面添加manifestPlaceholders = [
            XG_ACCESS_ID:你的信鸽id,
            XG_ACCESS_KEY:你的信鸽key,
            HW_APPID:"随便填吧，这个未集成，后面在集成，不填会有错误提示"
	    ]
      
```      

* 混淆设置

```
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep class com.tencent.android.tpush.** {* ;}
-keep class com.tencent.mid.** {* ;}
-keep class com.qq.taf.jce.** {*;}
```



#### ios
* 1、添加以下库/framework 的引用 CoreTelephony.framework, SystemConfiguration.framework, UserNotifications.framework, libXG-SDK.a 以及 libz.tbd, libsqlite3.0.tbd
* 2、AppDelegate.m文件头部导入下面的引用
```
#import "XGPush.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
#import "RCTXGPushModule.h"
```
* 3、在AppDelegate.m文件中的 @implementation AppDelegate 上一行添加
```
@interface AppDelegate ()<XGPushDelegate>
@end
```
* 4、在didFinishLaunchingWithOptions方法中添加如下代码

```
  [[XGPush defaultManager] setEnableDebug:YES];
  XGNotificationAction *action1 = [XGNotificationAction actionWithIdentifier:@"xgaction001" title:@"xgAction1" options:XGNotificationActionOptionNone];
  XGNotificationAction *action2 = [XGNotificationAction actionWithIdentifier:@"xgaction002" title:@"xgAction2" options:XGNotificationActionOptionDestructive];
  XGNotificationCategory *category = [XGNotificationCategory categoryWithIdentifier:@"xgCategory" actions:@[action1, action2] intentIdentifiers:@[] options:XGNotificationCategoryOptionNone];
  XGNotificationConfigure *configure = [XGNotificationConfigure configureNotificationWithCategories:nil types:XGUserNotificationTypeAlert|XGUserNotificationTypeBadge|XGUserNotificationTypeSound];
  [[XGPush defaultManager] setNotificationConfigure:configure];
  [[XGPush defaultManager] startXGWithAppID:你的信鸽id appKey:你的appkey delegate:self];
  [[XGPush defaultManager] setXgApplicationBadgeNumber:0];
  [[XGPush defaultManager] reportXGNotificationInfo:launchOptions];
```


* 5、AppDelegate.m文件添加如下方法
```
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
  NSLog(@"[XGDemo] register APNS fail.\n[XGDemo] reason : %@", error);
  [[NSNotificationCenter defaultCenter] postNotificationName:@"registerDeviceFailed" object:nil];
}

/**
 收到通知的回调
 
 @param application  UIApplication 实例
 @param userInfo 推送时指定的参数
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"[XGDemo] receive Notification");
  [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
  NSLog(@"ios 9 ");
  if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
  {
    //NSLog(@"didReceiveRemoteNotification:APP在前台运行时，不做处理");
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
  }//当APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面
  else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
    // 取得 APNs 标准信息内容
    //NSLog(@"didReceiveRemoteNotification:APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面");
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotification object:userInfo];
  }
  
}

/**
 收到静默推送的回调
 
 @param application  UIApplication 实例
 @param userInfo 推送时指定的参数
 @param completionHandler 完成回调
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  NSLog(@"[XGDemo] receive slient Notification");
  NSLog(@"[XGDemo] userinfo %@", userInfo);
  [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
  
  if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
  {
    //NSLog(@"didReceiveRemoteNotification:APP在前台运行时，不做处理");
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
  }//当APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面
  else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
    // 取得 APNs 标准信息内容
    //NSLog(@"didReceiveRemoteNotification:APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面");
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotification object:userInfo];
  }
  
  completionHandler(UIBackgroundFetchResultNewData);
}


// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// App 用户点击通知
// App 用户选择通知中的行为
// App 用户在通知中心清除消息
// 无论本地推送还是远程推送都会走这个回调
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  NSLog(@"[XGDemo] click notification");
//  if ([response.actionIdentifier isEqualToString:@"xgaction001"]) {
//    NSLog(@"click from Action1");
//  } else if ([response.actionIdentifier isEqualToString:@"xgaction002"]) {
//    NSLog(@"click from Action2");
//  }
  
  [[XGPush defaultManager] reportXGNotificationResponse:response];
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  //  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
  [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
  [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotification object:userInfo];
  completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  [[XGPush defaultManager] reportXGNotificationInfo:notification.request.content.userInfo];
  NSLog(@"xgPushUserNotificationCenter");
  NSDictionary * userInfo = notification.request.content.userInfo;
  //  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
  [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
  [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
  completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
#endif

#pragma mark - XGPushDelegate
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
  NSLog(@"%s, result %@, error %@", __FUNCTION__, isSuccess?@"OK":@"NO", error);
}

- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
  NSLog(@"%s, result %@, error %@", __FUNCTION__, isSuccess?@"OK":@"NO", error);
}

```


#### react native
具体查看demo
```
在App中引入import XGPushModule from 'react-native-smart-xgpush';
componentDidMount() {
    if(Platform.OS === 'android'){
        XGPushModule.bindAccount('41411',(msg)=>{
            console.log('bindAccount',msg);
            XGPushModule.getToken((msg1)=>{
                console.log('getToken',msg1);
            })
        });
    }
    XGPushModule.addReceiveCustomMsgListener(this._iReceiveCustomMsgListener);
    XGPushModule.addReceiveNotificationListener(this._iReceiveNotificationListener);
    XGPushModule.addReceiveOpenNotificationListener(this._iReceiveOpenNotificationListener);
    XGPushModule.addOpenNotificationLaunchAppListener(this._iOpenNotificationLaunchAppListener);
    XGPushModule.addTag('testTag',(msg)=>{
        console.log(msg);
    });
    if(Platform.OS ==='android'){
        XGPushModule.notifyJSDidLoad((msg)=>{});
    }

}

componentWillUnmount() {
    XGPushModule.removeReceiveCustomMsgListener();

}

```


###### ps：参考了https://github.com/jpush/jpush-react-native的一些思路
