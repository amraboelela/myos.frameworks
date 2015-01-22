
#import <android/log.h>

#ifndef RD_LOG
#define RD_LOG
#define printf(...) __android_log_print(ANDROID_LOG_DEBUG, "", __VA_ARGS__);
#define printfWithProcess(process, ...) __android_log_print(ANDROID_LOG_DEBUG, process, __VA_ARGS__);
#endif