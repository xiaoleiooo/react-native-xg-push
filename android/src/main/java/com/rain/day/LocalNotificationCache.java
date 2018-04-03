package com.rain.day;

import android.content.Intent;

import java.util.ArrayList;

/**
 * Created by rain on 2018/4/3.
 */

public class LocalNotificationCache {

    private ArrayList<Object> cache = new ArrayList<>();

    private boolean stopCache = false;

    private static LocalNotificationCache instance = new LocalNotificationCache();
    private LocalNotificationCache(){
        cache.clear();
        stopCache = false;
    }
    public static LocalNotificationCache getInstance(){
        return  instance;
    }

    public void addNotification(Object object){
        if(stopCache){
            return;
        }
        Logger.d("LocalNotificationCache",object.toString());
        cache.add(object);
    }

    public Object popNotification(){
        if(cache.isEmpty()){
           return null;
        }
        Object res = cache.get(0);
        cache.remove(res);
        return res;
    }

    public void clearCache(){
        cache.clear();
    }

    public boolean isCacheEmpty(){
        return cache.isEmpty();
    }

    public void setStopCache(boolean isStop){
        stopCache = isStop;
    }

    public void checkNotificationIdAndRemove(long id){
        for (Object item: cache) {
            if(id == ((Intent)item).getLongExtra("msgId",0)){
                cache.remove(item);
                return;
            }
        }
    }
}
