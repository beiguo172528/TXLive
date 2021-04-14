//
//  AppDelegate.m
//  TXLive
//
//  Created by DOFAR on 2021/4/14.
//

#import "AppDelegate.h"
#import <TXLiveBase.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self licenseTXLiveBase];
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.isForceLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else if (self.isForcePortrait){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

// 返回是否支持设备自动旋转
- (BOOL)shouldAutorotate{
    return YES;
}

#pragma mark 腾讯直播
- (void)licenseTXLiveBase{
    NSString * const licenceURL = @"http://license.vod2.myqcloud.com/license/v1/69556306f3938fc69c1b50dc2b0baf70/TXLiveSDK.licence";
    NSString * const licenceKey = @"20613ae89db415880015bb071631481c";

    //TXLiveBase 位于 "TXLiveBase.h" 头文件中
    [TXLiveBase setLicenceURL:licenceURL key:licenceKey];
//    [TXLiveBase setLicenceURL:@"" key:@""];
    NSLog(@"SDK Version = %@", [TXLiveBase getSDKVersionStr]);
}


@end
