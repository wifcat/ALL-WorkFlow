#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <android/log.h>

extern int main_luac(int argc, char **argv);

JNIEXPORT jint JNICALL
Java_com_aqua_luacompiler_MainActivity_compileLua__Ljava_lang_String_2Ljava_lang_String_2Z(
        JNIEnv *env, jobject thiz,
        jstring jinput, jstring joutput, jboolean jstrip) {

    const char *inPathUtf  = (*env)->GetStringUTFChars(env, jinput, 0);
    const char *outPathUtf = (*env)->GetStringUTFChars(env, joutput, 0);

    char *argv[6];
    int argc = 0;
    argv[argc++] = "luac";
    if (jstrip == JNI_TRUE) {
        argv[argc++] = "-s";
    }
    argv[argc++] = "-o";
    argv[argc++] = (char *)outPathUtf;
    argv[argc++] = (char *)inPathUtf;

    __android_log_print(ANDROID_LOG_INFO, "LuaJNI",
                        "Calling main_luac with argc=%d", argc);
    for (int i = 0; i < argc; i++) {
        __android_log_print(ANDROID_LOG_INFO, "LuaJNI", "argv[%d]=%s", i, argv[i]);
    }

    int res = main_luac(argc, argv);

    (*env)->ReleaseStringUTFChars(env, jinput, inPathUtf);
    (*env)->ReleaseStringUTFChars(env, joutput, outPathUtf);

    return res;
}
