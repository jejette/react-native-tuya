//
//  TuyaRNActivatorModule.m
//  TuyaRnDemo
//
//  Created by 浩天 on 2019/2/28.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "TuyaRNActivatorModule.h"
#import <TuyaSmartActivatorKit/TuyaSmartActivatorKit.h>
#import <TuyaSmartBaseKit/TuyaSmartBaseKit.h>
#import <TuyaSmartDeviceKit/TuyaSmartDeviceKit.h>
#import "TuyaRNUtils+Network.h"
#import "YYModel.h"

#import "TuyaRNEventEmitter.h"

#define kTuyaRNActivatorModuleHomeId @"homeId"
#define kTuyaRNActivatorModuleSSID @"ssid"
#define kTuyaRNActivatorModulePassword @"password"
#define kTuyaRNActivatorModuleActivatorMode @"type"
#define kTuyaRNActivatorModuleOverTime @"time"
#define kTuyaRNActivatorModuleAcccessToken @"token"
#define kTuyaRNActivatorModuleDeviceId @"devId"
#define kTuyaRNActivatorModuleGWId @"GWId"
#define kTuyaRNActivatorModuleProductId @"ProductId"

static TuyaRNActivatorModule * activatorInstance = nil;

@interface TuyaRNActivatorModule()<TuyaSmartActivatorDelegate>

@property(copy, nonatomic) RCTPromiseResolveBlock promiseResolveBlock;
@property(copy, nonatomic) RCTPromiseRejectBlock promiseRejectBlock;

@end

@implementation TuyaRNActivatorModule

RCT_EXPORT_MODULE(TuyaActivatorModule)

/** 开始配网
 * @param homeId  当前用户的homeId
 * @param ssid   配网之后，设备工作WiFi的名称。（家庭网络）
 * @param password   配网之后，设备工作WiFi的密码。（家庭网络）
 * @param activatorModel:    现在给设备配网有以下两种方式:
 ActivatorModelEnum.TY_EZ: 传入该参数则进行EZ配网
 ActivatorModelEnum.TY_AP: 传入该参数则进行AP配网
 * @param timeout     配网的超时时间设置，默认是100s.
 */
RCT_EXPORT_METHOD(initActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];
  NSString *ssid = params[kTuyaRNActivatorModuleSSID];
  NSString *password = params[kTuyaRNActivatorModulePassword];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
  NSString *type = params[kTuyaRNActivatorModuleActivatorMode];
//  NSString *token = params[kTuyaRNActivatorModuleActivatorToken];
  
  TYActivatorMode mode =  TYActivatorModeEZ;
  if ([type isEqualToString:@"TY_EZ"]) {
    mode = TYActivatorModeEZ;
  } else if([type isEqualToString:@"TY_AP"]) {
    mode = TYActivatorModeAP;
  } else if([type isEqualToString:@"TY_QR"]) {
    mode = TYActivatorModeQRCode;
  }
  
  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId.longLongValue success:^(NSString *result) {
    //开始配置网络：
    [[TuyaSmartActivator sharedInstance] startConfigWiFi:mode ssid:ssid password:password token:result timeout:time.doubleValue];
  } failure:^(NSError *error) {
    [TuyaRNUtils rejecterWithError:error handler:rejecter];
  }];
}

RCT_EXPORT_METHOD(initWifiEzDeviceActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];
  NSString *ssid = params[kTuyaRNActivatorModuleSSID];
  NSString *password = params[kTuyaRNActivatorModulePassword];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
  
  TYActivatorMode mode =  TYActivatorModeEZ;
  mode = TYActivatorModeEZ;
  
  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId.longLongValue success:^(NSString *result) {
    //开始配置网络：
    [[TuyaSmartActivator sharedInstance] startConfigWiFi:mode ssid:ssid password:password token:result timeout:time.doubleValue];
  } failure:^(NSError *error) {
    [TuyaRNUtils rejecterWithError:error handler:rejecter];
  }];
}

RCT_EXPORT_METHOD(getTokenForActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];

  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;

  [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId.longLongValue success:^(NSString *result) {
    // resolver with result
    if (resolver) {
      resolver(result);
    }
  } failure:^(NSError *error) {
    [TuyaRNUtils rejecterWithError:error handler:rejecter];
  }];
}

RCT_EXPORT_METHOD(initWifiApDeviceActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];
  NSString *ssid = params[kTuyaRNActivatorModuleSSID];
  NSString *password = params[kTuyaRNActivatorModulePassword];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
  NSString *token = params[kTuyaRNActivatorModuleAcccessToken];
  
  TuyaSmartActivatorNotificationFindGatewayDevice;

  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] startConfigWiFi:TYActivatorModeAP ssid:ssid password:password token:token timeout:time.doubleValue];
}


RCT_EXPORT_METHOD(initWiredGwActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];
  NSString *ssid = params[kTuyaRNActivatorModuleSSID];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
//  NSString *token = params[kTuyaRNActivatorModuleActivatorToken];
  
  TuyaSmartActivatorNotificationFindGatewayDevice;

  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId.longLongValue success:^(NSString *result) {
    //开始配置网络：
    [[TuyaSmartActivator sharedInstance] startConfigWiFiWithToken:result timeout:time.doubleValue];
  } failure:^(NSError *error) {
    [TuyaRNUtils rejecterWithError:error handler:rejecter];
  }];
}

// Checked by Using
RCT_EXPORT_METHOD(InitSearchedGwDevice:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  NSNumber *homeId = params[kTuyaRNActivatorModuleHomeId];
  NSString *gwId = params[kTuyaRNActivatorModuleGWId];
  NSString *productId = params[kTuyaRNActivatorModuleProductId];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
  
  NSLog(@"%s", gwId);




  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId.longLongValue success:^(NSString *result) {
    //开始配置网络：
    NSLog(@"%s", result);
    [[TuyaSmartActivator sharedInstance] activeGatewayDeviceWithGwId:gwId productId:productId token:result timeout:time.doubleValue];
  } failure:^(NSError *error) {
    [TuyaRNUtils rejecterWithError:error handler:rejecter];
  }];
}

// Checked by Using
RCT_EXPORT_METHOD(StartSearcingGwDevice) {
  TuyaSmartActivatorNotificationFindGatewayDevice;
}

RCT_EXPORT_METHOD(stopConfig:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  [[TuyaSmartActivator sharedInstance] stopConfigWiFi];
}

//ZigBee子设备配网需要ZigBee网关设备云在线的情况下才能发起,且子设备处于配网状态。
// Checked by Using
RCT_EXPORT_METHOD(newGwSubDevActivator:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSString *deviceId = params[kTuyaRNActivatorModuleDeviceId];
  NSNumber *time = params[kTuyaRNActivatorModuleOverTime];
  
  if (activatorInstance == nil) {
    activatorInstance = [TuyaRNActivatorModule new];
  }
  
  [TuyaSmartActivator sharedInstance].delegate = activatorInstance;
  activatorInstance.promiseResolveBlock = resolver;
  activatorInstance.promiseRejectBlock = rejecter;
  
  [[TuyaSmartActivator sharedInstance] activeSubDeviceWithGwId:deviceId timeout:time.doubleValue];
  
}

// Checked by Using
RCT_EXPORT_METHOD(stopNewGwSubDevActivatorConfig:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
  NSString *deviceId = params[kTuyaRNActivatorModuleDeviceId];
  [[TuyaSmartActivator sharedInstance] stopActiveSubDeviceWithGwId:deviceId];
}

/**
 获取wifi信息
 */
RCT_EXPORT_METHOD(getCurrentWifi:(NSDictionary *)params success:(RCTResponseSenderBlock)succ failure:(RCTResponseErrorBlock)fail) {
  NSString *ssid = [TuyaSmartActivator currentWifiSSID];
  if ([ssid isKindOfClass:[NSString class]] && ssid.length > 0) {
    succ(@[ssid]);
  } else {
    fail(nil);
  }
}


//判断网络
RCT_EXPORT_METHOD(openNetworkSettings:(NSDictionary *)params resolver :(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
   [TuyaRNUtils openNetworkSettings];
  
}

RCT_EXPORT_METHOD(onDestory:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter) {
  
}


#pragma mark -
#pragma mark - delegate
/// 配网状态更新的回调，wifi单品，zigbee网关，zigbee子设备
- (void)activator:(TuyaSmartActivator *)activator didReceiveDevice:(TuyaSmartDeviceModel *)deviceModel error:(NSError *)error {
  
  if (error) {
    NSDictionary *dic = @{
              @"result": @"onError",
              @"var1": [@(error.code) stringValue],
              @"var2": error.domain
              };

    [TuyaRNEventEmitter ty_sendEvent:kNotificationResultSubDevice withBody:dic];

    if (activatorInstance.promiseRejectBlock) {
      [TuyaRNUtils rejecterWithError:error handler:activatorInstance.promiseRejectBlock];
    }
    return;
  }
  
  //开始回调
  if (activatorInstance.promiseResolveBlock) {
    if (deviceModel.deviceType == 5) {
        NSDictionary *dic = @{
                      @"result": @"onActiveSuccess",
                      @"var1": deviceModel.yy_modelToJSONObject,
                      @"var2": @"none"
                      };

        [TuyaRNEventEmitter ty_sendEvent:kNotificationResultSubDevice withBody:dic];
    } else {
        self.promiseResolveBlock([deviceModel yy_modelToJSONObject]);
    }
    NSLog(@"deviceModel.gwType : %@", deviceModel.gwType);
    NSLog(@"deviceModel.name : %@", deviceModel.name);
    NSLog(@"deviceModel.schema : %@", deviceModel.schema);
    NSLog(@"deviceModel.name : %@", deviceModel.productId);
    NSLog(@"deviceModel.name : %lu", deviceModel.deviceType);
  }
}

@end
