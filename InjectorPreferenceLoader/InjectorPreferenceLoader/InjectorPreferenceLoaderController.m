//
//  InjectorPreferenceLoaderController.m
//  InjectorPreferenceLoader
//
//  Created by 聲華 陳 on 2015/4/17.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import "InjectorPreferenceLoaderController.h"
#import <Preferences/PSSpecifier.h>
#import <dlfcn.h>

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

@implementation InjectorPreferenceLoaderController


- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = (NSMutableString*)[NSString stringWithFormat:@"%@.plist", *plistPath];
	else
		*plistPath = (NSMutableString*)[NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, *plistPath];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}

- (void)injectorWebsite:(PSSpecifier*)specifier {
    NSString *url = @"https://nrl.cce.mcu.edu.tw/injector";
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (NSString *)serialNumber
{
    if(geteuid())
        return @"C32NM0E8G5MR";
    
    NSString *sn = nil;
    
    void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
    if (IOKit)
    {
        mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
        CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
        mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
        CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
        kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
        
        if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
        {
            mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
            if (platformExpertDevice)
            {
                CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
                if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
                {
                    sn = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
                    CFRelease(platformSerialNumber);
                }
                IOObjectRelease(platformExpertDevice);
            }
        }
        dlclose(IOKit);
    }
    
    return sn;
}

- (void)sendTo: (NSString *)email {
    email = [NSString stringWithFormat:@"mailto:%@?subject=Sent From Injector&body=\n\n\nSN : %@", email, [self serialNumber]];
    NSString *url = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


- (void)appMaintainer:(PSSpecifier*)specifier {
    [self sendTo:@"jr89197@hotmail.com"];
}


- (void)websiteMaintainer:(PSSpecifier*)specifier {
    [self sendTo:@"melody70161@gmail.com"];
}

- (void)managerInterfaceMaintainer:(PSSpecifier*)specifier {
    [self sendTo:@"asdfff32@yahoo.com.tw,jeffa01160714@gmail.com"];
}

- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"InjectorPreferenceLoader" target:self];
		#if ! __has_feature(objc_arc)
		[_specifiers retain];
		#endif
	}
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init])) {
	}
	
	return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[super dealloc];
}
#endif

@end