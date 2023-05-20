package com.d954mas.defold.android.toast;

import android.app.Activity;
import android.content.Context;
import android.widget.Toast;


public class ToastManager {
    private static final String TAG = "ToastManager";
    private static Context context;
    private static Activity activity;

    public static void init(Context context) {
        ToastManager.context = context;
        ToastManager.activity = (Activity) context;
    }

    public static void toast(String text, int toastLen) {
        activity.runOnUiThread(new Runnable() {
            public void run() {
                int toast = Toast.LENGTH_SHORT;
                if(toastLen==1){
                    toast = Toast.LENGTH_LONG;
                }
                Toast.makeText(context, text, toast).show();
            }
        });
    }

}