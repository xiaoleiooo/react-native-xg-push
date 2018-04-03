//
//  RCTXGPushModule.m
//  RCTXGPushModule
//
//  Created by rain on 2018/3/20.
//  Copyright © 2018年 com.rain.day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTXGPushModule.h"
#import "RCTXGActionQueue.h"
#import "XGPush.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>


//#import <RCTEventDispatcher.h>
//#import <RCTRootView.h>
//#import <RCTBridge.h>

@interface RCTXGPushModule() <XGPushTokenManagerDelegate>{
    BOOL _isXGPushDidLogin;
}
@end

@implementation RCTXGPushModule

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

+ (id)allocWithZone:(NSZone *)zone {
    static RCTXGPushModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    
//    [defaultCenter addObserver:self
//                      selector:@selector(networkDidLogin:)
//                          name:kJPFNetworkDidLoginNotification
//                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(receiveRemoteNotification:)
                          name:kJPFDidReceiveRemoteNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(reactJSDidload)
                          name:RCTJavaScriptDidLoadNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(openNotification:)
                          name:kJPFOpenNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(openNotificationToLaunchApp:)
                          name:kJPFOpenNotificationToLaunchApp
                        object:nil];
    
    if ([RCTXGActionQueue sharedInstance].openedLocalNotification != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotificationToLaunchApp object:[RCTXGActionQueue sharedInstance].openedLocalNotification];
    }
    
    [XGPushTokenManager defaultTokenManager].delegatge = self;
    
    return self;
}

- (void)reactJSDidload {
    [RCTXGActionQueue sharedInstance].isReactDidLoad = YES;
    [[RCTXGActionQueue sharedInstance] scheduleNotificationQueue];
    
    if ([RCTXGActionQueue sharedInstance].openedRemoteNotification != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotificationToLaunchApp object:[RCTXGActionQueue sharedInstance].openedRemoteNotification];
    }
    
    if ([RCTXGActionQueue sharedInstance].openedLocalNotification != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotificationToLaunchApp object:[RCTXGActionQueue sharedInstance].openedLocalNotification];
    }
    
//    if (_isXGPushDidLogin) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFNetworkDidLoginNotification object:nil];
//    } else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFNetworkDidCloseNotification object:nil];
//    }
    
}

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
    [RCTXGActionQueue sharedInstance].openedRemoteNotification = [_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [RCTXGActionQueue sharedInstance].openedLocalNotification = [_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
}

//// request push notification permissions only，不一定需要
RCT_EXPORT_METHOD(setupPush) {

//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
//        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
//                                                          UIUserNotificationTypeSound |
//                                                          UIUserNotificationTypeAlert)
//                                              categories:nil];
//    } else {
//        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                          UIRemoteNotificationTypeSound |
//                                                          UIRemoteNotificationTypeAlert)
//                                              categories:nil];
//    }
}

RCT_EXPORT_METHOD(getApplicationIconBadge:(RCTResponseSenderBlock)callback) {
    callback(@[@([UIApplication sharedApplication].applicationIconBadgeNumber)]);
}

- (void)openNotificationToLaunchApp:(NSNotification *)notification {
    id obj = [notification object];
    [self.bridge.eventDispatcher sendAppEventWithName:@"openNotificationLaunchApp" body:obj];
}

- (void)openNotification:(NSNotification *)notification {
    id obj = [notification object];
    [self.bridge.eventDispatcher sendAppEventWithName:@"openNotification" body:obj];
}

//- (void)networkDidLogin:(NSNotification *)notification {
//    _isXGPushDidLogin = YES;
//    [[RCTXGActionQueue sharedInstance] scheduleGetRidCallbacks];
//    //  [self.bridge.eventDispatcher sendAppEventWithName:@"connectionChange"
//    //                                               body:@(true)];
//    [self.bridge.eventDispatcher sendAppEventWithName:@"networkDidLogin"
//                                                 body:nil];
//
//}


//收到自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:@"receiveCustomPushMsg"
                                                 body:[notification userInfo]];
}

- (void)receiveRemoteNotification:(NSNotification *)notification {
    
    if ([RCTXGActionQueue sharedInstance].isReactDidLoad == YES) {
        id obj = [notification object];
        [self.bridge.eventDispatcher sendAppEventWithName:@"receiveNotification" body:obj];
    } else {
        [[RCTXGActionQueue sharedInstance] postNotification:notification];
    }
    
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)didRegistRemoteNotification:(NSString *)token {
    [self.bridge.eventDispatcher sendAppEventWithName:@"didRegisterToken"
                                                 body:token];
}

//RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location callback:(RCTResponseSenderBlock)callback) {
//    callback(@[name]);
//}

///----------------------------------------------------
/// @name APNs about 通知相关
///----------------------------------------------------

/*!
 * @abstract 注册要处理的远程通知类型
 *
 * @param types 通知类型
 * @param categories
 *
 * @discussion
 */
//RCT_EXPORT_METHOD(registerForRemoteNotificationTypes:(NSUInteger)types
//                  categories:(NSSet *)categories) {
//    [JPUSHService registerForRemoteNotificationTypes:types categories:categories];
//}

RCT_EXPORT_METHOD(registerDeviceToken:(NSData *)deviceToken) {
    [[XGPushTokenManager defaultTokenManager] registerDeviceToken:deviceToken];
}

/*!
 * @abstract 处理收到的 APNs 消息
 */
RCT_EXPORT_METHOD(handleRemoteNotification:(NSDictionary *)remoteInfo) {
    //todo
//    [JPUSHService handleRemoteNotification:remoteInfo];
}

#pragma mark - 初始化相关
/**
 * 打开 Debug 模式以后可以在终端看到详细的信鸽 Debug 信息.方便定位问题
 */
RCT_EXPORT_METHOD(setEnableDebug:(BOOL)isDebug){
    [[XGPush defaultManager] setEnableDebug:isDebug];
}

/**
 * 查看debug开关是否打开
 */
RCT_EXPORT_METHOD(isEnableDebug:(RCTResponseSenderBlock) callback){
    BOOL isDebug = [XGPush defaultManager].isEnableDebug;
    callback(@[@(isDebug)]);
}

RCT_EXPORT_METHOD(xgNotificationStatus:(RCTResponseSenderBlock) callback){
    BOOL xgNotificationStatus = [XGPush defaultManager].xgNotificationStatus;
    callback(@[@(xgNotificationStatus)]);
}

///**
// @brief 通过使用在信鸽官网注册的应用的信息，启动信鸽推送服务
//
// @param appID 通过前台申请的应用ID
// @param appKey 通过前台申请的appKey
// @param delegate 回调对象
// @note 接口所需参数必须要正确填写，反之信鸽服务将不能正确为应用推送消息
// */
//RCT_EXPORT_METHOD(startXGWithAppID:(uint32_t)appID appKey:(nonnull NSString *)appKey delegate:(nullable id<XGPushDelegate>)delegate){
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[XGPush defaultManager] startXGWithAppID:appID appKey:appKey delegate:appDelegate];
//}


/**
 @brief 上报地理位置信息
 
 @param latitude 纬度
 @param longitude 经度
 */
RCT_EXPORT_METHOD(reportLocationWithLatitude:(double)latitude longitude:(double)longitude){
    [[XGPush defaultManager] reportLocationWithLatitude:latitude longitude:longitude];
}

/**
 @brief 上报当前App角标数到信鸽服务器

 @param badgeNumber 应用的角标数
 @note (后台维护中)此接口是为了实现角标+1的功能，服务器会在这个数值基础上进行角标数新增的操作，调用成功之后，会覆盖之前值
 */
RCT_EXPORT_METHOD(setBadge:(NSInteger)badgeNumber){
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    [[XGPush defaultManager] setBadge:badgeNumber];
}

/*!
 * @abstract 重置脚标(为0)
 *
 * @discussion 相当于 [setBadge:0] 的效果.
 */
RCT_EXPORT_METHOD(resetBadge) {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[XGPush defaultManager] setBadge:0];
}

/**
 @brief 查询设备通知权限是否被用户允许
 @param handler 查询结果的返回方法
 @note iOS 10 or later 回调是异步地执行
 */
RCT_EXPORT_METHOD(deviceNotificationIsAllowed:(RCTResponseSenderBlock)callback){
    [[XGPush defaultManager] deviceNotificationIsAllowed:^(BOOL isAllowed) {
        callback(@[@(isAllowed)]);
    }];
}

#pragma -----管理设备Token------
/*!
 * 设置 tag 的方法
 * 开发者可以针对不同的用户绑定标签,然后对该标签推送.对标签推送会让该标签下的所有设备都收到推送.一个设备可以绑定多个标签.(不会覆盖以前的标签)
 PS:经过测试发现，标签起作用有延迟，大概2个小时，慎用
 */

RCT_EXPORT_METHOD( addTag:(NSString *)tag
                  callback:(RCTResponseSenderBlock)callback) {
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:tag type: XGPushTokenBindTypeTag];
}

RCT_EXPORT_METHOD( deleteTag:(NSString *)tag
                  callback:(RCTResponseSenderBlock)callback) {
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:tag type:XGPushTokenBindTypeTag];
}

RCT_EXPORT_METHOD( getAllTags:(RCTResponseSenderBlock)callback) {
    NSArray<NSString *> * tags = [[XGPushTokenManager defaultTokenManager] identifiersWithType:XGPushTokenBindTypeTag];
    NSString *res = [[NSString alloc] init];
    for (NSString *item in tags) {
        res = [res stringByAppendingFormat:@"%@,", item];
    }
    NSLog(@"%@",res);
    if (res) {
        NSString *res = [self arrayToJSONString:tags];
        callback(@[@{@"tags": res}]);
    }else{
        callback(@[@{@"error": @"获取标签错误"}]);
    }
}

/*!
 * 设置 account 的方法
 * 注1: 一个设备只能绑定一个账号,绑定账号的时候前一个账号自动失效.一个账号最多绑定15台设备,超过之后会随机解绑一台设备,然后再进行注册.
 */

RCT_EXPORT_METHOD( setAccount:(NSString *)account
                  callback:(RCTResponseSenderBlock)callback) {
    NSError *error = nil;
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:account type: XGPushTokenBindTypeAccount];
}

RCT_EXPORT_METHOD( deleteAccoun:(NSString *)account
                  callback:(RCTResponseSenderBlock)callback) {
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:account type:XGPushTokenBindTypeAccount];
}
/**
 * 清除tag和account
 */
RCT_EXPORT_METHOD( bindNone:(RCTResponseSenderBlock)callback) {
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:nil type:XGPushTokenBindTypeNone];
}

#pragma mark - XGPushTokenManagerDelegate
- (void)xgPushDidBindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, %@, error:%@", __FUNCTION__, identifier, ((error == nil)?@"成功":@"失败"),error);
}

- (void)xgPushDidUnbindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, %@, error:%@", __FUNCTION__, identifier, ((error == nil)?@"成功":@"失败"),error);
}


- (NSString *)arrayToJSONString:(NSArray *)array

{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/////----------------------------------------------------
///// @name Local Notification 本地通知
/////----------------------------------------------------
//
///*!
// * @abstract 本地推送，最多支持64个
// *
// * @param fireDate 本地推送触发的时间
// * @param alertBody 本地推送需要显示的内容
// * @param badge 角标的数字。如果不需要改变角标传-1
// * @param alertAction 弹框的按钮显示的内容（IOS 8默认为"打开", 其他默认为"启动"）
// * @param notificationKey 本地推送标示符
// * @param userInfo 自定义参数，可以用来标识推送和增加附加信息
// * @param soundName 自定义通知声音，设置为nil为默认声音
// *
// * @discussion 最多支持 64 个定义
// */
//RCT_EXPORT_METHOD( setLocalNotification:(NSDate *)fireDate
//                  alertBody:(NSString *)alertBody
//                  badge:(int)badge
//                  alertAction:(NSString *)alertAction
//                  identifierKey:(NSString *)notificationKey
//                  userInfo:(NSDictionary *)userInfo
//                  soundName:(NSString *)soundName) {
//
//    [JPUSHService setLocalNotification:fireDate
//                             alertBody:alertBody
//                                 badge:badge
//                           alertAction:alertAction
//                         identifierKey:notificationKey
//                              userInfo:userInfo
//                             soundName:soundName];
//}
//
//
///*!
// * @abstract 前台展示本地推送
// *
// * @param notification 本地推送对象
// * @param notificationKey 需要前台显示的本地推送通知的标示符
// *
// * @discussion 默认App在前台运行时不会进行弹窗，在程序接收通知调用此接口可实现指定的推送弹窗。
// */
//RCT_EXPORT_METHOD( showLocalNotificationAtFront:(UILocalNotification *)notification
//                  identifierKey:(NSString *)notificationKey) {
//    [JPUSHService showLocalNotificationAtFront:notification identifierKey:notificationKey];
//}
///*!
// * @abstract 删除本地推送定义
// *
// * @param notificationKey 本地推送标示符
// * @param myUILocalNotification 本地推送对象
// */
//RCT_EXPORT_METHOD(deleteLocalNotificationWithIdentifierKey:(NSString *)notificationKey) {
//    [JPUSHService deleteLocalNotificationWithIdentifierKey:notificationKey];
//}
//
///*!
// * @abstract 删除本地推送定义
// */
//RCT_EXPORT_METHOD(deleteLocalNotification:(UILocalNotification *)localNotification) {
//    [JPUSHService deleteLocalNotification:localNotification];
//}
//
///*!
// * @abstract 获取指定通知
// *
// * @param notificationKey 本地推送标示符
// * @return 本地推送对象数组, [array count]为0时表示没找到
// */
//RCT_EXPORT_METHOD(findLocalNotificationWithIdentifier:(NSString *)notificationKey callback:(RCTResponseSenderBlock)callback) {// nsarray
//    callback([JPUSHService findLocalNotificationWithIdentifier:notificationKey]);
//}
//
///*!
// * @abstract 清除所有本地推送对象
// */
//RCT_EXPORT_METHOD(clearAllLocalNotifications) {
//    [JPUSHService clearAllLocalNotifications];
//}
//
//
/////----------------------------------------------------
///// @name Server badge 服务器端 badge 功能
/////----------------------------------------------------
//
///*!
// * @abstract 设置角标(到服务器)
// *
// * @param value 新的值. 会覆盖服务器上保存的值(这个用户)
// *
// * @discussion 本接口不会改变应用本地的角标值.
// * 本地仍须调用 UIApplication:setApplicationIconBadgeNumber 函数来设置脚标.
// *
// * 本接口用于配合 JPush 提供的服务器端角标功能.
// * 该功能解决的问题是, 服务器端推送 APNs 时, 并不知道客户端原来已经存在的角标是多少, 指定一个固定的数字不太合理.
// *
// * JPush 服务器端脚标功能提供:
// *
// * - 通过本 API 把当前客户端(当前这个用户的) 的实际 badge 设置到服务器端保存起来;
// * - 调用服务器端 API 发 APNs 时(通常这个调用是批量针对大量用户),
// *   使用 "+1" 的语义, 来表达需要基于目标用户实际的 badge 值(保存的) +1 来下发通知时带上新的 badge 值;
// */
//RCT_EXPORT_METHOD(setBadge:(NSInteger)value callback:(RCTResponseSenderBlock)callback) {// ->Bool
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
//    NSNumber *badgeNumber = [NSNumber numberWithBool:[JPUSHService setBadge: value]];
//    callback(@[badgeNumber]);
//}
//
///*!
// * @abstract 重置脚标(为0)
// *
// * @discussion 相当于 [setBadge:0] 的效果.
// * 参考 [JPUSHService setBadge:] 说明来理解其作用.
// */
//RCT_EXPORT_METHOD(resetBadge) {
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//    [JPUSHService resetBadge];
//}
@end
