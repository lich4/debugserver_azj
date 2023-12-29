
#include <dlfcn.h>
#include <time.h>
#import <Foundation/Foundation.h>

static void nouse(){}
static void* _SMJobSubmit = (void*)nouse;
static void* _CFPropertyListCreateData = (void*)nouse;
static int last_inst_time = 0;

#ifdef THEOS_PACKAGE_INSTALL_PREFIX
#define ROOTDIR THEOS_PACKAGE_INSTALL_PREFIX
#else
#define ROOTDIR
#endif

%hookf(CFDataRef, _CFPropertyListCreateData, CFAllocatorRef allocator, CFPropertyListRef propertyList, CFPropertyListFormat format, CFOptionFlags options, CFErrorRef* error) {
    if (CFGetTypeID(propertyList) == CFDictionaryGetTypeID()) {
        NSDictionary* info = (__bridge NSDictionary*)propertyList;
        if (info[@"Service"] != nil && [info[@"Service"] isEqualToString:@"com.apple.mobile.installation_proxy"]) {
            last_inst_time = time(0);
        }
    }
    return %orig;
}

%hookf(Boolean, _SMJobSubmit, CFStringRef domain, CFDictionaryRef job, CFTypeID auth, CFErrorRef *outError) {
    NSMutableDictionary* mjob = [(__bridge NSDictionary*)job mutableCopy];
    if (job != nil && mjob[@"ProgramArguments"] != nil) {
        NSArray* argv = mjob[@"ProgramArguments"];
        NSString* full_cmd = [argv componentsJoinedByString:@" "];
        NSLog(@"debugserver_azj %@", full_cmd);
        NSString* path = argv.firstObject;
        if (time(0) - last_inst_time > 3) { // 防止影响Xcode安装调试普通App
            NSOperatingSystemVersion sysver = NSProcessInfo.processInfo.operatingSystemVersion;;
            int mv = sysver.majorVersion;
            if ([path isEqualToString:@"/Developer/usr/bin/debugserver"]) {
                NSMutableArray* margv = [argv mutableCopy];
                if (mv <= 8) {
                    // not implement
                } else if (mv == 9 || mv == 10) {
                    margv[0] = @(ROOTDIR "/usr/bin/debugserver_azj10");
                } else if (mv == 11 || mv == 12) {
                    margv[0] = @(ROOTDIR "/usr/bin/debugserver_azj12");
                } else if (mv == 13 || mv == 14) {
                    margv[0] = @(ROOTDIR "/usr/bin/debugserver_azj14");
                } else if (mv >= 15) { // XCode 12+ is need for iOS15  // not test on iOS16+
                    margv[0] = @(ROOTDIR "/usr/bin/debugserver_azj15"); 
                }
                mjob[@"UserName"] = @"root";
                mjob[@"ProgramArguments"] = margv;
            } else if ([path isEqualToString:@"/Developer/usr/libexec/gputoolsd"]) {
                NSMutableArray* margv = [argv mutableCopy];
                if (mv <= 8) {
                    // not implement
                } else if (mv == 9 || mv == 10) {
                    margv[0] = @(ROOTDIR "/usr/bin/gputoolsd_azj10");
                } else if (mv == 11 || mv == 12) {
                    margv[0] = @(ROOTDIR "/usr/bin/gputoolsd_azj12");
                } else if (mv == 13 || mv == 14) {
                    margv[0] = @(ROOTDIR "/usr/bin/gputoolsd_azj14");
                } else if (mv >= 15) { // not test on iOS16+
                    margv[0] = @(ROOTDIR "/usr/bin/gputoolsd_azj15"); 
                }
                mjob[@"UserName"] = @"root";
                mjob[@"ProgramArguments"] = margv;
            } 
            job = (__bridge_retained CFDictionaryRef)mjob;
        }      
    }
    return %orig;
}

%ctor {
    // launchctl start com.apple.mobile.lockdown
    NSLog(@"debugserver_azj init");
    _SMJobSubmit = dlsym(RTLD_DEFAULT, "SMJobSubmit");
    _CFPropertyListCreateData = dlsym(RTLD_DEFAULT, "CFPropertyListCreateData");
}

