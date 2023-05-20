#define EXTENSION_NAME android_toast
#define LIB_NAME "android_toast"
#define MODULE_NAME "android_toast"
// include the Defold SDK
#include <dmsdk/sdk.h>
#include "djni.h"
#include <game_utils.h>


#if defined(DM_PLATFORM_ANDROID)

//register callbacks from java to native
void AndroidToastInitialize() {
    JNIEnv* env = djni::env();
    jclass cls = djni::GetClass(env, "com.d954mas.defold.android.toast.ToastManager");
    jmethodID method = env->GetStaticMethodID(cls, "init", "(Landroid/content/Context;)V");
    env->CallStaticVoidMethod(cls, method, dmGraphics::GetNativeAndroidActivity());
}

void AndroidToastMakeToast(const char* text, int toastLen){
     ThreadAttacher attacher;
     JNIEnv *env = attacher.env;
     jclass cls = djni::GetClass(env, "com.d954mas.defold.android.toast.ToastManager");
     jmethodID method = env->GetStaticMethodID(cls, "toast", "(Ljava/lang/String;I)V");

    jstring jString = env->NewStringUTF(text);
    jint jint = toastLen;
    env->CallStaticVoidMethod(cls, method,jString,jint);
}


static int AndroidToastMakeToastLua(lua_State *L) {
	d954masGameUtils::check_arg_count(L, 2);
    AndroidToastMakeToast(lua_tostring(L, 1),lua_tonumber(L, 2));
	return 0;
}

static const luaL_reg Module_methods[] = {
    {"toast", AndroidToastMakeToastLua},
    {0, 0}
};


static void LuaInit(lua_State* L){
	int top = lua_gettop(L);
	// Register lua names
	luaL_register(L, MODULE_NAME, Module_methods);
	lua_pop(L, 1);
	assert(top == lua_gettop(L));
}



static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) {
    printf("Registered %s Extension\n", MODULE_NAME);
    AndroidToastInitialize();
    LuaInit(params->m_L);
    printf("Registered2 %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}



#else

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) {
    printf("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}
#endif

dmExtension::Result FinalizeMyExtension(dmExtension::Params *params){
    return dmExtension::RESULT_OK;
}


DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, NULL, NULL, InitializeMyExtension, FinalizeMyExtension, 0, 0)
