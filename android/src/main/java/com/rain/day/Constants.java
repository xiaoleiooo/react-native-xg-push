package com.rain.day;

/**
 * 常量
 * Created by Jeepeng on 16/8/15.
 */
public class Constants {
    public static final String ACTION_ON_REGISTERED = "XGPushnRegisterResult";
    public static final String ACTION_ON_TEXT_MESSAGE = "XGPushonTextMessage";
    /**
     * 收到通知
     */
    public static final String ACTION_ON_NOTIFICATION_SHOWED = "XGPushnNotifactionShowedResult";
    /**
     * 通知被点击
     */
    public static final String ACTION_ON_NOTIFICATION_CLICKED = "XGPushOnNotifactionClickedResult";

    public static final String EVENT_REGISTERED_ID = "getRegistrationId";
    /**
     * 收到推送消息
     */
    public static final String EVENT_REMOTE_NOTIFICATION_RECEIVED = "receiveNotification";
    /**
     * 打开消息
     */
    public static final String EVENT_OPEN_NOTIFICATION = "openNotification";
    /**
     * 收到本地推送消息
     */
    public static final String EVENT_LOCAL_NOTIFICATION_RECEIVED = "localNotificationReceived";
    /**
     * 自定义消息 透传消息
     */
    public static final String EVENT_MESSAGE_RECEIVED = "receivePushMsg";

    /**
     *
     */
    public final static String CONNECTION_CHANGE = "connectionChange";
}

