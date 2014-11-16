#line 1 "/Projects/ChargingHelper-for-iOS-8/ChargingHelper/ChargingHelper.xm"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage, designCapacity, cycleCount, temperature;
BOOL isCharging, externalConnected, externalChargeCapable;

@interface SpringBoard : UIApplication
- (void)popAlertView;
- (void)popDIYLevelAlertView;
- (void)popBatteryDetail;
- (void)playVibrate;
- (void)playSound;


@end

#include <logos/logos.h>
#include <substrate.h>
@class SBLockScreenBatteryChargingViewController; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$popAlertView(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$popDIYLevelAlertView(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$popBatteryDetail(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$playVibrate(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$playSound(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$loadView)(SBLockScreenBatteryChargingViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$loadView(SBLockScreenBatteryChargingViewController*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc)(SBLockScreenBatteryChargingViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc(SBLockScreenBatteryChargingViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$initChargingTextView(SBLockScreenBatteryChargingViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$setupContainViewCenter(SBLockScreenBatteryChargingViewController*, SEL); 

#line 17 "/Projects/ChargingHelper-for-iOS-8/ChargingHelper/ChargingHelper.xm"









static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard* self, SEL _cmd, id batteryStatus) {
	currentCapacity = [[batteryStatus objectForKey:@"AppleRawCurrentCapacity"] intValue];
    maxCapacity = [[batteryStatus objectForKey:@"AppleRawMaxCapacity"] intValue];
    designCapacity = [[batteryStatus objectForKey:@"DesignCapacity"] intValue];
    cycleCount = [[batteryStatus objectForKey:@"CycleCount"] intValue];
    temperature = [[batteryStatus objectForKey:@"Temperature"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    externalConnected = [[batteryStatus objectForKey:@"ExternalConnected"] boolValue];
    externalChargeCapable = [[batteryStatus objectForKey:@"ExternalChargeCapable"] boolValue];
    BOOL fullyCharged = [[batteryStatus objectForKey:@"FullyCharged"] boolValue];
    
    



    
    








    static BOOL repeatFlag = YES;
    static BOOL alertLevelFlag = YES;
    static BOOL detailFlag = YES;
    
    
    
    if(externalConnected || externalChargeCapable)
    {
        
        NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
        BOOL isRepeat = [[preference objectForKey:@"isRepeat"]boolValue];
        BOOL isPopAlert = [[preference objectForKey:@"isPopAlert"]boolValue];
        BOOL isVibrate = [[preference objectForKey:@"isVibrate"] boolValue];
        BOOL isSound = [[preference objectForKey:@"isSound"] boolValue];
        BOOL isShowDetail = [[preference objectForKey:@"isShowDetail"] boolValue];
        int chargeMode = [[preference objectForKey:@"chargeMode"] intValue];
        int alertLevel = [[preference objectForKey:@"alertLevel"] intValue];
        [preference release];
        
        
        if(isShowDetail && detailFlag){
            [self popBatteryDetail];
            detailFlag = NO;
        }
        
        
        if(alertLevel != 0 && alertLevel != 100)
        {
            int currentLevel = ((float)currentCapacity / maxCapacity) * 100;
            if (currentLevel >= alertLevel)
            {
                if (alertLevelFlag)
                {
                    [self popDIYLevelAlertView];
                    
                    if(isVibrate)
                    {
                        [self playVibrate];
                    }
                    if(isSound)
                    {
                        [self playSound];
                    }

                    alertLevelFlag = NO;
                }
            }
        }
        
        
        if(currentCapacity == maxCapacity && (chargeMode == 1 || chargeMode == 0))
        {
            if(isRepeat)
            {
                if(repeatFlag && isPopAlert)
                {
                    [self popAlertView];
                    repeatFlag = NO;
                }
                if(isVibrate)
                {
                    [self playVibrate];
                }
                if(isSound)
                {
                    [self playSound];
                }
                
            }
            else
            {
                if(repeatFlag)
                {
                    if(isPopAlert)
                    {
                        [self popAlertView];
                    }
                    if(isVibrate)
                    {
                        [self playVibrate];
                    }
                    if(isSound)
                    {
                        [self playSound];
                    }
                    repeatFlag = NO;
                }
            }
            
        }
        
        else if(fullyCharged && chargeMode == 2)
        {
            if(isRepeat)
            {
                if(repeatFlag && isPopAlert)
                {
                    [self popAlertView];
                    repeatFlag = NO;
                }
                if(isVibrate)
                {
                    [self playVibrate];
                }
                if(isSound)
                {
                    [self playSound];
                }
                
            }
            else
            {
                if(repeatFlag)
                {
                    if(isPopAlert)
                    {
                        [self popAlertView];
                    }
                    if(isVibrate)
                    {
                        [self playVibrate];
                    }
                    if(isSound)
                    {
                        [self playSound];
                    }
                    repeatFlag = NO;
                }
            }
        }
    }else{
        repeatFlag = YES;
        alertLevelFlag = YES;
        
        
        if(!detailFlag)
        {
            [self popBatteryDetail];
            detailFlag = YES;
        }
    }
 
    _logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$(self, _cmd, batteryStatus);
}



static void _logos_method$_ungrouped$SpringBoard$popAlertView(SpringBoard* self, SEL _cmd) {
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *title, *msg, *cbButton;
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        title = @"提示";
        msg = @"充电已完成";
        cbButton = @"确定";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        title = @"提示";
        msg = @"充電已完成";
        cbButton = @"好";
    }else{
        title = @"Message";
        msg = @"Charging is complete";
        cbButton = @"OK";
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cbButton otherButtonTitles:nil];
    [alert show];
    [alert release];
}



static void _logos_method$_ungrouped$SpringBoard$popDIYLevelAlertView(SpringBoard* self, SEL _cmd) {
    
    NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
    int alertLevel = [[preference objectForKey:@"alertLevel"] intValue];
    [preference release];
    
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *title, *msg, *cbButton;
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        title = @"提示";
        msg = @"充电已到达";
        cbButton = @"确定";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        title = @"提示";
        msg = @"充電已到达";
        cbButton = @"好";
    }else{
        title = @"Message";
        msg = @"Charging has reached";
        cbButton = @"OK";
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@ %d%%", msg, alertLevel] delegate:nil cancelButtonTitle:cbButton otherButtonTitles:nil];
    [alert show];
    [alert release];
}



static void _logos_method$_ungrouped$SpringBoard$popBatteryDetail(SpringBoard* self, SEL _cmd) {
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *title, *msg, *currentCapacityLabel, *maxCapacityLabel, *designCapacityLabel, *batteryLifeLabel, *cycleCountLabel, *temperatureLabel, *cbButton;
    float batteryLife, batteryTemperature;
    
    batteryLife = ((float)maxCapacity /designCapacity) * 100;
    batteryTemperature = ((float)temperature / 100);
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        title = @"电池信息";
        currentCapacityLabel = @"当前容量";
        maxCapacityLabel = @"最大容量";
        designCapacityLabel = @"设计容量";
        batteryLifeLabel = @"健康度";
        cycleCountLabel = @"循环次数";
        temperatureLabel = @"电池温度";
        cbButton = @"确定";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        title = @"電池信息";
        currentCapacityLabel = @"當前容量";
        maxCapacityLabel = @"最大容量";
        designCapacityLabel = @"設計容量";
        batteryLifeLabel = @"健康度";
        cycleCountLabel = @"循環次數";
        temperatureLabel = @"電池溫度";
        cbButton = @"好";
    }else{
        title = @"Battery Info";
        currentCapacityLabel = @"Current Capacity";
        maxCapacityLabel = @"Max Capacity";
        designCapacityLabel = @"Design Capacity";
        batteryLifeLabel = @"Remain";
        cycleCountLabel = @"Cycles";
        temperatureLabel = @"Temperature";
        cbButton = @"OK";
    }
    
    msg = [NSString stringWithFormat:@"%@:%d mAh \n%@:%d mAh \n%@:%d mAh \n%@:%.1f%% \n%@:%d \n%@:%.1f℃", currentCapacityLabel, currentCapacity, maxCapacityLabel, maxCapacity, designCapacityLabel, designCapacity, batteryLifeLabel, batteryLife, cycleCountLabel, cycleCount, temperatureLabel, batteryTemperature];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cbButton otherButtonTitles:nil];
    [alert show];
    [alert release];
}



static void _logos_method$_ungrouped$SpringBoard$playVibrate(SpringBoard* self, SEL _cmd) {
    SystemSoundID vibrate;
    vibrate = kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(vibrate);
}



static void _logos_method$_ungrouped$SpringBoard$playSound(SpringBoard* self, SEL _cmd) {
    SystemSoundID sameViewSoundID;
    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; 
    CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
    AudioServicesPlaySystemSound(sameViewSoundID); 
}
































































#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface SBLockScreenBatteryChargingViewController : UIViewController
- (void)initChargingTextView;
- (void)setupContainViewCenter;
@end



BOOL isContentViewInited = NO;
UIView *containView;
UILabel *batteryLevel, *remainingTime;


static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$loadView(SBLockScreenBatteryChargingViewController* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$loadView(self, _cmd);
    
    NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
    
    if(!isContentViewInited){
        [self initChargingTextView];
        isContentViewInited = YES;
    }
    [self setupContainViewCenter];
    
    
    int colorValue = [[preference objectForKey:@"textColor"] intValue];
    
    UIColor *textColor;
    switch (colorValue) {
        case 1:
            textColor = [UIColor whiteColor];
            break;
        case 2:
            textColor = [UIColor blackColor];
            break;
        default:
            textColor = [UIColor whiteColor];
            break;
    }
    [remainingTime setTextColor:textColor];
    
    [self.view addSubview:containView];
    
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *timeMsg,*chargingLabel, *hourLabel, *minLabel, *completeLabel, *calulateLabel, *notChargingLabel, *trickleCharging;
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        chargingLabel = @"预计充电";
        hourLabel = @"小时";
        minLabel = @"分钟";
        completeLabel = @"充电已完成";
        calulateLabel = @"正在预估时间...";
        notChargingLabel = @"不在充电";
        trickleCharging = @"涓流充电中...";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        chargingLabel = @"預計充電";
        hourLabel = @"小時";
        minLabel = @"分鐘";
        completeLabel = @"充電已完成";
        calulateLabel = @"正在預估時間...";
        notChargingLabel = @"不在充電";
        trickleCharging = @"涓流充電中...";
    }else{
        chargingLabel = @"Remaining Time";
        hourLabel = @"hour(s)";
        minLabel = @"min(s)";
        completeLabel = @"Charging is complete";
        calulateLabel = @"Calculating...";
        notChargingLabel = @"Not charging";
        trickleCharging = @"Trickle Charging...";
    }
    
    float timeHour;
    int hour, min;
    
    int chargeMode = [[preference objectForKey:@"chargeMode"] intValue];
    
    float currentLevel = ((float)currentCapacity / maxCapacity);
    float levelPercent = currentLevel * 100;
    
    if(isCharging){
        if(levelPercent < 100 && instantAmperage > 0){
            
            if(levelPercent < 80){
                timeHour = (((maxCapacity * 0.8) - currentCapacity) / instantAmperage) + 1;
                hour = timeHour;
                min = (timeHour - hour) * 60;
                timeMsg = timeMsg = [NSString stringWithFormat:@"%@: %d%@ %d%@", chargingLabel, hour, hourLabel, min, minLabel];
            }else{
                min = (100 - levelPercent) * 3;
                timeMsg = [NSString stringWithFormat:@"%@:%d%@", chargingLabel, min, minLabel];
            }

        }else if(levelPercent == 100){
            switch (chargeMode) {
                case 1:
                    timeMsg = completeLabel;
                    break;
                case 2:
                    timeMsg = trickleCharging;
                    break;
                default:
                    timeMsg = completeLabel;
                    break;
            }
        }else{
            timeMsg = calulateLabel;
        }
    }else if(!externalChargeCapable && externalConnected) {
        timeMsg = notChargingLabel;
    } else {
        switch(chargeMode){
            case 1:
                timeMsg = notChargingLabel;
                break;
            case 2:
                timeMsg = completeLabel;
                break;
            default:
                timeMsg = notChargingLabel;
                break;
        }
    }
    remainingTime.text = timeMsg;

    
    [preference release];
}


static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc(SBLockScreenBatteryChargingViewController* self, SEL _cmd) {
    if(isContentViewInited)
    {
        [remainingTime removeFromSuperview];
        [containView removeFromSuperview];
        
        [remainingTime release];
        [containView release];
        
        isContentViewInited = NO;
    }
    
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc(self, _cmd);
}



static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$initChargingTextView(SBLockScreenBatteryChargingViewController* self, SEL _cmd) {
    containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [self setupContainViewCenter];
    containView.backgroundColor = [UIColor clearColor];
    
    remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    remainingTime.font = [UIFont systemFontOfSize:17];
    [remainingTime setTextAlignment:NSTextAlignmentCenter];
    remainingTime.backgroundColor = [UIColor clearColor];
    [containView addSubview:remainingTime];
}



static void _logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$setupContainViewCenter(SBLockScreenBatteryChargingViewController* self, SEL _cmd) {
    
    if(isPad) {
        UIDeviceOrientation interfaceOrientation=[[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            containView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 220);
        } else if (interfaceOrientation==UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
            containView.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2, 205);
        }
    } else {
        containView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 155);
    }
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(batteryStatusDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(popAlertView), (IMP)&_logos_method$_ungrouped$SpringBoard$popAlertView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(popDIYLevelAlertView), (IMP)&_logos_method$_ungrouped$SpringBoard$popDIYLevelAlertView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(popBatteryDetail), (IMP)&_logos_method$_ungrouped$SpringBoard$popBatteryDetail, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(playVibrate), (IMP)&_logos_method$_ungrouped$SpringBoard$playVibrate, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(playSound), (IMP)&_logos_method$_ungrouped$SpringBoard$playSound, _typeEncoding); }Class _logos_class$_ungrouped$SBLockScreenBatteryChargingViewController = objc_getClass("SBLockScreenBatteryChargingViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingViewController, @selector(loadView), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$loadView, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$loadView);MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingViewController, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingViewController$dealloc);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenBatteryChargingViewController, @selector(initChargingTextView), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$initChargingTextView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenBatteryChargingViewController, @selector(setupContainViewCenter), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingViewController$setupContainViewCenter, _typeEncoding); }} }
#line 566 "/Projects/ChargingHelper-for-iOS-8/ChargingHelper/ChargingHelper.xm"
