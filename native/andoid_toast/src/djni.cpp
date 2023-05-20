#if defined(DM_PLATFORM_ANDROID)

#define DLIB_LOG_DOMAIN "JNI"
#include <dmsdk/sdk.h>

#include <cstdlib>

#include <pthread.h>

namespace djni {
    
    void threadDestructor(void* env) {
        dmGraphics::GetNativeAndroidJavaVM()->DetachCurrentThread();

        dmLogDebug("Detached JNIEnv: %p.", env);
    }

    JNIEnv* env() {
        JNIEnv* env = NULL;

        JavaVM* jvm = dmGraphics::GetNativeAndroidJavaVM();
        
        jint errorCodeGetEnv = jvm->GetEnv((void**)(&env), JNI_VERSION_1_6);

        switch (errorCodeGetEnv) {
            case JNI_EDETACHED: {                
                jint errorCodeAttach = jvm->AttachCurrentThread(&env, NULL);

                if (errorCodeAttach != JNI_OK) {
                    dmLogFatal("Failed to attach JNIEnv: %p.", env);
                    abort();
                }

                pthread_key_t keyDetach;
                pthread_key_create(&keyDetach, &threadDestructor);
                pthread_setspecific(keyDetach, env);

                dmLogDebug("Attached JNIEnv: %p.", env);

                break;
            }
            case JNI_ERR: {
                dmLogFatal("Failed to get JNIEnv.");
                abort();
            }
            case JNI_EVERSION: {
                dmLogFatal("Wrong JavaVM version.");
                abort();
            }
            case JNI_OK: {
                // Do nothing. Just return JNIEnv.
                break;
            }
        }

        return env;        
    }

    jclass GetClass(JNIEnv* env, const char* classname) {        
        jclass jclass_NativeActivity = env->FindClass("android/app/NativeActivity");
        jmethodID jmethodID_NativeActivity_getClassLoader = env->GetMethodID(jclass_NativeActivity, "getClassLoader", "()Ljava/lang/ClassLoader;");
        env->DeleteLocalRef(jclass_NativeActivity);      
        jobject jobject_ClassLoader = env->CallObjectMethod(dmGraphics::GetNativeAndroidActivity(), jmethodID_NativeActivity_getClassLoader);
        jclass jclass_ClassLoader = env->FindClass("java/lang/ClassLoader");
        jmethodID jmethodID_ClassLoader_loadClass = env->GetMethodID(jclass_ClassLoader, "loadClass", "(Ljava/lang/String;)Ljava/lang/Class;");
        env->DeleteLocalRef(jclass_ClassLoader);                
        jstring jstring_ClassName = env->NewStringUTF(classname);
        jclass jclass_Result = (jclass)env->CallObjectMethod(jobject_ClassLoader, jmethodID_ClassLoader_loadClass, jstring_ClassName);
        env->DeleteLocalRef(jstring_ClassName);
        env->DeleteLocalRef(jobject_ClassLoader);       
        return jclass_Result;
    } 
}

#endif
