#if defined(DM_PLATFORM_ANDROID)

#include <dmsdk/sdk.h>

namespace djni {
	JNIEnv* env();
	jclass GetClass(JNIEnv* env, const char* classname);
}

struct ThreadAttacher {
	JNIEnv *env;
	bool has_attached;
	ThreadAttacher() : env(NULL), has_attached(false) {
		if (dmGraphics::GetNativeAndroidJavaVM()->GetEnv((void **)&env, JNI_VERSION_1_6) != JNI_OK) {
			dmGraphics::GetNativeAndroidJavaVM()->AttachCurrentThread(&env, NULL);
			has_attached = true;
		}
	}
	~ThreadAttacher() {
		if (has_attached) {
			if (env->ExceptionCheck()) {
				env->ExceptionDescribe();
			}
			env->ExceptionClear();
			dmGraphics::GetNativeAndroidJavaVM()->DetachCurrentThread();
		}
	}
};

#endif
