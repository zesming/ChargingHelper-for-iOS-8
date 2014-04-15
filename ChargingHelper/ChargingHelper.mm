#line 1 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
BOOL isCharging;

@interface SpringBoard : UIApplication
-(void)popAlertView;
-(void)playVibrate;
-(void)playSound;
@end

#include <logos/logos.h>
#include <substrate.h>
@class SBLockScreenBatteryChargingView; @class SBAwayChargingView; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$popAlertView(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$playVibrate(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$playSound(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SBAwayChargingView$addChargingView)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBAwayChargingView$dealloc)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$dealloc(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$initChargingTextView(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(SBLockScreenBatteryChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$initChargingTextView(SBLockScreenBatteryChargingView*, SEL); 

#line 13 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"


static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard* self, SEL _cmd, id batteryStatus) {
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue];
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];

    static BOOL alertFlag = YES;
    
    
    if(currentCapacity == maxCapacity && isCharging)
    {
        [batteryStatus writeToFile:@"/tmp/a.plist" atomically:YES];
        
        
        NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
        BOOL isRepeat = [[preference objectForKey:@"isRepeat"]boolValue];
        BOOL isPopAlert = [[preference objectForKey:@"isPopAlert"]boolValue];
        BOOL isVibrate = [[preference objectForKey:@"isVibrate"] boolValue];
        BOOL isSound = [[preference objectForKey:@"isSound"] boolValue];
        [preference release];
        
        if(isRepeat)
        {
            if(alertFlag && isPopAlert)
            {
                [self popAlertView];
                alertFlag = NO;
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
            if(alertFlag)
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
                alertFlag = NO;
            }
        }
        
    }
    else if(!isCharging)
    {
        alertFlag = YES;
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





@interface SBAwayChargingView : UIView
-(void)initChargingTextView;
@end


BOOL isInited = NO;
UIView *containView;
UILabel *batteryLevel, *remainingTime;

static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayChargingView$addChargingView(self, _cmd);
    
    if(!isInited){
        [self initChargingTextView];
        isInited = YES;
    }
    float currentLevel = ((float)currentCapacity/maxCapacity);
    float levelPercent = currentLevel * 100;
    
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",levelPercent];
    
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *timeMsg, *chargingLabel, *hourLabel, *minLabel, *completeLabel, *calulateLabel, *notChargingLabel;
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        chargingLabel = @"预计充电";
        hourLabel = @"小时";
        minLabel = @"分钟";
        completeLabel = @"充电已完成";
        calulateLabel = @"正在预估时间...";
        notChargingLabel = @"未充电";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        chargingLabel = @"預計充電";
        hourLabel = @"小時";
        minLabel = @"分鐘";
        completeLabel = @"充電已完成";
        calulateLabel = @"正在預估時間...";
        notChargingLabel = @"未充電";
    }else{
        chargingLabel = @"Remaining Time";
        hourLabel = @"hour(s)";
        minLabel = @"min(s)";
        completeLabel = @"Charging is complete";
        calulateLabel = @"Calculating...";
        notChargingLabel = @"Not charging";
    }
    
    float timeHour;
    int hour, min;
    if(isCharging){
        if(levelPercent < 100 && instantAmperage > 0){
            timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
            hour = timeHour;
            min = (timeHour - hour) * 60;
            if (hour == 0) {
                timeMsg = [NSString stringWithFormat:@"%@:%d%@", chargingLabel, min, minLabel];
            }else{
                timeMsg = [NSString stringWithFormat:@"%@: %d%@ %d%@", chargingLabel, hour, hourLabel, min, minLabel];
            }
        }else if(levelPercent == 100){
            timeMsg = [NSString stringWithFormat:@"%@", completeLabel];
        }else{
            timeMsg = [NSString stringWithFormat:@"%@", calulateLabel];
        }
    }else{
        timeMsg = [NSString stringWithFormat:@"%@", notChargingLabel];
    }
    remainingTime.text = timeMsg;

}


static void _logos_method$_ungrouped$SBAwayChargingView$dealloc(SBAwayChargingView* self, SEL _cmd) {
    [batteryLevel removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];

    [batteryLevel release];
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    _logos_orig$_ungrouped$SBAwayChargingView$dealloc(self, _cmd);
}



static void _logos_method$_ungrouped$SBAwayChargingView$initChargingTextView(SBAwayChargingView* self, SEL _cmd) {
    containView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 280, 60)];
    containView.center = CGPointMake(130, 210);
    containView.backgroundColor = [UIColor clearColor];
    
    batteryLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
    batteryLevel.font = [UIFont systemFontOfSize:25];
    [batteryLevel setTextAlignment:NSTextAlignmentCenter];
    [batteryLevel setTextColor:[UIColor whiteColor]];
    batteryLevel.backgroundColor = [UIColor clearColor];
    [containView addSubview:batteryLevel];
    
    remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 280, 30)];
    remainingTime.font = [UIFont systemFontOfSize:17];
    [remainingTime setTextAlignment:NSTextAlignmentCenter];
    [remainingTime setTextColor:[UIColor whiteColor]];
    remainingTime.backgroundColor = [UIColor clearColor];
    [containView addSubview:remainingTime];
    
    [self addSubview:containView];
}




@interface SBLockScreenBatteryChargingView : UIView
-(void)initChargingTextView;
@end



static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(SBLockScreenBatteryChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(self, _cmd);
    if(!isInited){
        [self initChargingTextView];
        NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
        int colorValue = [[preference objectForKey:@"textColor"] intValue];
        [preference release];
        
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
        
        [self addSubview:containView];
        
        isInited = YES;
    }
    
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *timeMsg,*chargingLabel, *hourLabel, *minLabel, *completeLabel, *calulateLabel, *notChargingLabel;
    
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        chargingLabel = @"预计充电";
        hourLabel = @"小时";
        minLabel = @"分钟";
        completeLabel = @"充电已完成";
        calulateLabel = @"正在预估时间...";
        notChargingLabel = @"未充电";
    }else if([currentLanguage isEqualToString:@"zh-Hant"]){
        chargingLabel = @"預計充電";
        hourLabel = @"小時";
        minLabel = @"分鐘";
        completeLabel = @"充電已完成";
        calulateLabel = @"正在預估時間...";
        notChargingLabel = @"未充電";
    }else{
        chargingLabel = @"Remaining Time";
        hourLabel = @"hour(s)";
        minLabel = @"min(s)";
        completeLabel = @"Charging is complete";
        calulateLabel = @"Calculating...";
        notChargingLabel = @"Not charging";
    }
    
    float timeHour;
    int hour, min;
    if(isCharging){
        if(currentCapacity < maxCapacity && instantAmperage > 0){
            timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
            hour = timeHour;
            min = (timeHour - hour) * 60;
            if (hour == 0) {
                timeMsg = [NSString stringWithFormat:@"%@:%d %@", chargingLabel, min, minLabel];
            }else{
                timeMsg = [NSString stringWithFormat:@"%@: %d%@ %d%@", chargingLabel, hour, hourLabel, min, minLabel];
            }
        }else if(currentCapacity == maxCapacity){
            timeMsg = [NSString stringWithFormat:@"%@", completeLabel];
        }else{
            timeMsg = [NSString stringWithFormat:@"%@", calulateLabel];
        }
    }else{
        timeMsg = [NSString stringWithFormat:@"%@", notChargingLabel];
    }
    remainingTime.text = timeMsg;


}

static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc(SBLockScreenBatteryChargingView* self, SEL _cmd) {
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];
    
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc(self, _cmd);
}



static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$initChargingTextView(SBLockScreenBatteryChargingView* self, SEL _cmd) {
    containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    containView.center = CGPointMake(160, 160);
    containView.backgroundColor = [UIColor clearColor];
    
    remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    remainingTime.font = [UIFont systemFontOfSize:17];
    [remainingTime setTextAlignment:NSTextAlignmentCenter];
    remainingTime.backgroundColor = [UIColor clearColor];
    [containView addSubview:remainingTime];
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(batteryStatusDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(popAlertView), (IMP)&_logos_method$_ungrouped$SpringBoard$popAlertView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(playVibrate), (IMP)&_logos_method$_ungrouped$SpringBoard$playVibrate, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(playSound), (IMP)&_logos_method$_ungrouped$SpringBoard$playSound, _typeEncoding); }Class _logos_class$_ungrouped$SBAwayChargingView = objc_getClass("SBAwayChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(addChargingView), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$addChargingView, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$addChargingView);MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$dealloc);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBAwayChargingView, @selector(initChargingTextView), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$initChargingTextView, _typeEncoding); }Class _logos_class$_ungrouped$SBLockScreenBatteryChargingView = objc_getClass("SBLockScreenBatteryChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews);MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(initChargingTextView), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$initChargingTextView, _typeEncoding); }} }
#line 360 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
