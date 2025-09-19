LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := luac_jni
LOCAL_SRC_FILES := ../luac_jni.c
LOCAL_LDLIBS    := -llog
include $(BUILD_SHARED_LIBRARY)
