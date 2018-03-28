import {
	NativeModules,
	Platform,
	DeviceEventEmitter
} from 'react-native';

const XGPushModule = NativeModules.XGPushModule;
const listeners = {};
const receiveCustomMsgEvent = "receivePushMsg";
const receiveNotificationEvent = "receiveNotification";
const openNotificationEvent = "openNotification";
const connectionChangeEvent = "connectionChange";

const getRegistrationIdEvent = "getRegistrationId"; // Android Only
const openNotificationLaunchAppEvent = "openNotificationLaunchApp"; // iOS Only
const networkDidLogin = "networkDidLogin"; // iOS Only
const receiveExtrasEvent = "receiveExtras"; // Android Only

/**
 * Logs message to console with the [XGPush] prefix
 * @param  {string} message
 */
const log = (message) => {
		// console.log(`[XGPush] ${message}`);
    console.log('[XGPush]', message);
	}
	// is function
const isFunction = (fn) => typeof fn === 'function';
/**
 * create a safe fn env
 * @param  {any} fn
 * @param  {any} success
 * @param  {any} error
 */
const safeCallback = (fn, success, error) => {

	XGPushModule[fn](function(params) {
		log(params);
		isFunction(success) && success(params)
	}, function(error) {
		log(error)
		isFunction(error) && error(error)
	})

}

export default class XGPush {

	/**
     * Android Only
     * 启动并注册APP，同时绑定账号,推荐有帐号体系的APP使用
     * （此接口会覆盖设备之前绑定过的账号，仅当前注册的账号生效）
     */
    static registerPush() {
        XGPushModule.registerPush((msg)=>{
            log(msg);
        });
    }


    /**
     * Android Only
     * 启动并注册APP
     */
    static bindAccount(account,cb) {
        XGPushModule.bindAccount(account,(msg)=>{
            cb(msg)
        });
    }


    /**
     * Android Only
     * 启动并注册APP，同时绑定账号,推荐有帐号体系的APP使用
     * （此接口保留之前的账号，只做增加操作，一个token下最多只能有3个账号超过限制会自动顶掉之前绑定的账号）
     */
    static appendAccount(account) {
        XGPushModule.appendAccount(account,(msg)=>{
            log(msg);
        });
    }

    /**
     * Android Only
     * 获取设备的token，只有注册成功才能获取到正常的结果
     */
    static getToken(cb) {
        XGPushModule.getToken((msg)=>{
            cb(msg);
        });
    }


    //
	// /**
	//  * Android Only
	//  */
	// static stopPush() {
	// 	XGPushModule.stopPush();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static resumePush() {
	// 	XGPushModule.resumePush();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static crashLogOFF() {
	// 	XGPushModule.crashLogOFF();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static crashLogON() {
	// 	XGPushModule.crashLogON();
	// }
    //
	/**
	 * Android Only
	 *
	 * @param {Function} cb
	 */
	static notifyJSDidLoad(cb) {
		XGPushModule.notifyJSDidLoad((resultCode) => {
			cb(resultCode);
		});
	}
    //
	// /**
	//  * Android Only
	//  */
	// static clearAllNotifications() {
	// 	XGPushModule.clearAllNotifications();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static clearNotificationById(id) {
	// 	XGPushModule.clearNotificationById(id);
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static getInfo(cb) {
	// 	XGPushModule.getInfo((map) => {
	// 		cb(map);
	// 	});
	// }


	/**
	 * 添加 Tag
	 * 
	 * @param tag = String
	 * @param {Function} cb = (result) => {  }
	 * 如果成功 result = {tags: [String]}
	 * 如果失败 result = {errorCode: Int}  
	 */
	static addTag(tag, cb) {
	    if(Platform.OS === 'ios'){
            XGPushModule.addTag(tag, (result) => {
                cb(result);
            });
        }else{
	        XGPushModule.setTag(tag);
        }
	}

	/**
	 * 删除指定的 tag
	 * 
	 * @param tag = String
	 * @param {Function} cb = (result) => {  }
	 * 如果成功 result = {tags: [String]}
	 * 如果失败 result = {errorCode: Int}  
	 * 
	 */
	static deleteTag(tag, cb) {
	    if(Platform.OS === 'ios'){
            XGPushModule.deleteTag(tag, (result) => {
                cb(result);
            });
        }else{
            XGPushModule.deleteTag(tag);
        }
	}

	/**
     *
     * ios only
	 * 获取所有已有标签
	 * 
	 * @param {Function} cb = (result) => { }
	 * 如果成功 result = {tags: [String]}
	 * 如果失败 result = {errorCode: Int}
	 * 
	 */
	static getAllTags(cb) {
		XGPushModule.getAllTags((result) => {
			cb(result);
		});
	}

    /**
     *
     * ios only
     * 重新设置 account
     *
     * @param account = String
     * @param {Function} cb = (result) => {  }
     * 如果成功 result = {tags: [String]}
     * 如果失败 result = {errorCode: Int}
     */
    static setAccount(tag, cb) {
        XGPushModule.setAccount(tag, (result) => {
            cb(result);
        });
    }

    /**
     * 删除指定的 account
     *
     * @param account = String
     * @param {Function} cb = (result) => {  }
     * 如果成功 result = {tags: [String]}
     * 如果失败 result = {errorCode: Int}
     *
     */
    static deleteAccoun(account, cb) {
        if(Platform.OS === 'ios'){
            XGPushModule.deleteAccoun(account, (result) => {
                cb(result);
            });
        }else{
            XGPushModule.delAccount(account, (result) => {
                cb(result);
            });
        }

    }


    /**
     * Android Only
     * 反注册
     */
    static unregisterPush(cb) {
    	XGPushModule.unregisterPush((msg)=>{
    	    cb(msg);
        });
    }


	// /**
	//  * Android Only
	//  */
	// static setStyleBasic() {
	// 	XGPushModule.setStyleBasic();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static setStyleCustom() {
	// 	XGPushModule.setStyleCustom();
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static jumpToPushActivity(activityName) {
	// 	XGPushModule.jumpToPushActivity(activityName);
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static jumpToPushActivityWithParams(activityName, map) {
	// 	XGPushModule.jumpToPushActivityWithParams(activityName, map);
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static finishActivity() {
	// 	XGPushModule.finishActivity();
	// }

	/**
	 * 监听：自定义消息后事件
	 * @param {Function} cb = (Object) => { } 
	 */
	static addReceiveCustomMsgListener(cb) {
		listeners[cb] = DeviceEventEmitter.addListener(receiveCustomMsgEvent,
			(message) => {
				cb(message);
			});
	}

	/**
	 * 取消监听：自定义消息后事件
	 * @param {Function} cb = (Object) => { } 
	 */
	static removeReceiveCustomMsgListener(cb) {
		if (!listeners[cb]) {
			return;
		}
		listeners[cb].remove();
		listeners[cb] = null;
	}

	/**
	 * iOS Only
	 * 监听：应用没有启动的状态点击推送打开应用
	 * @param {Function} cb = (notification) => {}
	 */
	static addOpenNotificationLaunchAppListener(cb) {
		listeners[cb] = DeviceEventEmitter.addListener(openNotificationLaunchAppEvent,
			(registrationId) => {
				cb(registrationId);
			});
	}

	/**
	 * iOS Only
	 * 取消监听：应用没有启动的状态点击推送打开应用
	 * @param {Function} cb = () => {}
	 */
	static removeOpenNotificationLaunchAppEventListener(cb) {
		if (!listeners[cb]) {
			return;
		}
		listeners[cb].remove();
		listeners[cb] = null;
	}


	/**
	 * 监听：接收推送事件
	 * @param {} cb = (Object）=> {}
	 */
	static addReceiveNotificationListener(cb) {
		listeners[cb] = DeviceEventEmitter.addListener(receiveNotificationEvent,
			(map) => {
				cb(map);
			});
	}

	/**
	 * 取消监听：接收推送事件
	 * @param {Function} cb = (Object）=> {}
	 */
	static removeReceiveNotificationListener(cb) {
		if (!listeners[cb]) {
			return;
		}
		listeners[cb].remove();
		listeners[cb] = null;
	}

	/**
	 * 监听：点击推送事件
	 * @param {Function} cb  = (Object）=> {}
	 */
	static addReceiveOpenNotificationListener(cb) {
		listeners[cb] = DeviceEventEmitter.addListener(openNotificationEvent,
			(message) => {
				cb(message);
			});
	}

	/**
	 * 取消监听：点击推送事件
	 * @param {Function} cb  = (Object）=> {}
	 */
	static removeReceiveOpenNotificationListener(cb) {
		if (!listeners[cb]) {
			return;
		}
		listeners[cb].remove();
		listeners[cb] = null;
	}

	// /**
	//  * Android Only
	//  *
	//  * If device register succeed, the server will return registrationId
	//  */
	// static addGetRegistrationIdListener(cb) {
	// 	listeners[cb] = DeviceEventEmitter.addListener(getRegistrationIdEvent,
	// 		(registrationId) => {
	// 			cb(registrationId);
	// 		});
	// }
    //
	// /**
	//  * Android Only
	//  */
	// static removeGetRegistrationIdListener(cb) {
	// 	if (!listeners[cb]) {
	// 		return;
	// 	}
	// 	listeners[cb].remove();
	// 	listeners[cb] = null;
	// }


	/**
	 * 监听：收到 Native 下发的 extra 事件
	 * @param {Function} cb = (map) => { }
	 * 返回 Object，属性和值在 Native 定义
	 */
	static addReceiveExtrasListener(cb) {
		listeners[cb] = DeviceEventEmitter.addListener(receiveExtrasEvent,
			(map) => {
				cb(map);
			});
	}

	static removeReceiveExtrasListener(cb) {
		if (!listeners[cb]) {
			return;
		}
		listeners[cb].remove();
		listeners[cb] = null;
	}


	/**
	 * iOS Only
	 * @param {Function} cb = (int) => { } // 返回应用 icon badge。
	 */
	static getBadge(cb) {
		XGPushModule.getApplicationIconBadge((badge) => {
			cb(badge);
		});
	}

	// /**
	//  * iOS Only
	//  * 设置本地推送
	//  * @param {Date} date  触发本地推送的时间
	//  * @param {String} textContain 推送消息体内容
	//  * @param {Int} badge  本地推送触发后 应用 Badge（小红点）显示的数字
	//  * @param {String} alertAction 弹框的按钮显示的内容（IOS 8默认为"打开", 其他默认为"启动"）
	//  * @param {String} notificationKey  本地推送标示符
	//  * @param {Object} userInfo 推送的附加字段 选填
	//  * @param {String} soundName 自定义通知声音，设置为 null 为默认声音
	//  */
	// static setLocalNotification(date, textContain, badge, alertAction, notificationKey, userInfo, soundName) {
	// 	XGPushModule.setLocalNotification(date, textContain, badge, alertAction, notificationKey, userInfo, soundName);
	// }

	/**
	 * iOS Only
	 * 设置应用 Badge（小红点）
	 * @param {Int} badge 
	 * @param {Function} cb = () => { } //
	 */
	static setBadge(badge, cb) {
		XGPushModule.setBadge(badge, (value) => {
			cb(value);
		});
	}
}