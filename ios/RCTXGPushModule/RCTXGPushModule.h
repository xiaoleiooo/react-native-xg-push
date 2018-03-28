//
//  RCTXGPushModule.h
//  RCTXGPushModule
//
//  Created by rain on 2018/3/20.
//  Copyright © 2018年 com.rain.day. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#elif __has_include("React/RCTBridgeModule.h")
#import "React/RCTBridgeModule.h"
#endif

#define kJPFDidReceiveRemoteNotification  @"kJPFDidReceiveRemoteNotification"

#define kJPFOpenNotification @"kJPFOpenNotification" // 通过点击通知事件
#define kJPFOpenNotificationToLaunchApp @"kJPFOpenNotificationToLaunchApp" // 通过点击通知启动应用


//extern NSString *const kJPFNetworkIsConnectingNotification; // 正在连接中
//extern NSString *const kJPFNetworkDidSetupNotification;     // 建立连接
//extern NSString *const kJPFNetworkDidCloseNotification;     // 关闭连接
//extern NSString *const kJPFNetworkFailedRegisterNotification; //注册失败
//extern NSString *const kJPFNetworkDidLoginNotification;     // 登录成功
//extern NSString *const kJPFNetworkDidReceiveMessageNotification;         // 收到消息(非APNS)
//extern NSString *const kJPFServiceErrorNotification;  // 错误提示


@interface RCTXGPushModule : NSObject<RCTBridgeModule>
@property(strong,nonatomic)RCTResponseSenderBlock asyCallback;

- (void)didRegistRemoteNotification:(NSString *)token;
@end
