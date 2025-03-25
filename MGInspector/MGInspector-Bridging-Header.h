#import <Foundation/Foundation.h>
#import <dlfcn.h>

// Function pointer type for MGCopyAnswer
typedef id (*MGCopyAnswerFunc)(CFStringRef);

// Helper function to get MGCopyAnswer
static inline id MGCopyAnswer(CFStringRef property) {
    static MGCopyAnswerFunc _MGCopyAnswer;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
        if (gestalt) {
            _MGCopyAnswer = (MGCopyAnswerFunc)dlsym(gestalt, "MGCopyAnswer");
        }
    });
    
    if (_MGCopyAnswer) {
        return _MGCopyAnswer(property);
    }
    
    return nil;
}
