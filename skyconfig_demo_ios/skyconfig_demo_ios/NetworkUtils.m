//
//  NetworkUtils.m
//  skyconfig_demo
//
//  Created by marklei on 2020/1/20.
//  Copyright © 2020 Skyworth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkUtils.h"
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NetworkUtils

+ (NSString*) getWifiSsid {
    if (@available(iOS 13.0, *)) {
        //用户明确拒绝，可以弹窗提示用户到设置中手动打开权限
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            NSLog(@"User has explicitly denied authorization for this application, or location services are disabled in Settings.");
            //使用下面接口可以打开当前应用的设置页面
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            return nil;
        }
        CLLocationManager* cllocation = [[CLLocationManager alloc] init];
        if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            //弹框提示用户是否开启位置权限
            [cllocation requestWhenInUseAuthorization];
            usleep(500);
            //递归等待用户选选择
            return [self getWifiSsid];
        }
    }
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

@end
