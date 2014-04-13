#line 1 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
BOOL isCharging;

#include <logos/logos.h>
#include <substrate.h>
@class SBLockScreenBatteryChargingView; @class SBAwayChargingView; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard*, SEL, id); static void (*_logos_orig$_ungrouped$SBAwayChargingView$addChargingView)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBAwayChargingView$dealloc)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$dealloc(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(SBLockScreenBatteryChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc(SBLockScreenBatteryChargingView*, SEL); 

#line 7 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"


static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard* self, SEL _cmd, id batteryStatus) {
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue]; 
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    
  
    NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
    
    static BOOL alertFlag = YES;
    BOOL isRepeat = [[preference objectForKey:@"isRepeat"]boolValue];
    BOOL isVibrate = [[preference objectForKey:@"isVibrate"] boolValue];
    BOOL isSound = [[preference objectForKey:@"isSound"] boolValue];
    
    
    if(currentCapacity == maxCapacity && isCharging)
    {
        [batteryStatus writeToFile:@"/tmp/a.plist" atomically:YES];
        
        if(isRepeat)
        {
            if(alertFlag)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"充电已完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                
                [alert release];
                alertFlag = NO;
            }
            if(isVibrate)
            {
                SystemSoundID vibrate;
                vibrate = kSystemSoundID_Vibrate;
                AudioServicesPlaySystemSound(vibrate);
            }
            if(isSound)
            {
                SystemSoundID sameViewSoundID;
                NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; 
                CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
                AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
                
                AudioServicesPlaySystemSound(sameViewSoundID); 
            }
            
        }
        else
        {
            if(alertFlag)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"充电已完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                
                [alert release];
                if(isVibrate)
                {
                    SystemSoundID vibrate;
                    vibrate = kSystemSoundID_Vibrate;
                    AudioServicesPlaySystemSound(vibrate);
                }
                if(isSound)
                {
                    SystemSoundID sameViewSoundID;
                    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; 
                    CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
                    AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
                    
                    AudioServicesPlaySystemSound(sameViewSoundID); 
                }
                alertFlag = NO;
            }
        }
        
    }
    else if(!isCharging)
    {
        alertFlag = YES;
    }
    
    [preference release];

	_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$(self, _cmd, batteryStatus);
}






BOOL isInited = NO;
UIView *containView;
UILabel *batteryLevel, *remainingTime;


static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayChargingView$addChargingView(self, _cmd);
    
    if(!isInited){
        containView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 280, 30)];
        containView.center = CGPointMake(130, 210);
        containView.backgroundColor = [UIColor clearColor];
        
        batteryLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
        batteryLevel.font = [UIFont systemFontOfSize:25];
        [batteryLevel setTextAlignment:NSTextAlignmentCenter];
        [batteryLevel setTextColor:[UIColor whiteColor]];
        batteryLevel.backgroundColor = [UIColor clearColor];
        [containView addSubview:batteryLevel];
        
        remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 170, 30)];
        remainingTime.font = [UIFont systemFontOfSize:17];
        [remainingTime setTextAlignment:NSTextAlignmentCenter];
        [remainingTime setTextColor:[UIColor whiteColor]];
        remainingTime.backgroundColor = [UIColor clearColor];
        [containView addSubview:remainingTime];
        
        [self addSubview:containView];
        
        isInited = YES;
    }
    float currentLevel = ((float)currentCapacity/maxCapacity);
    float levelPercent = currentLevel * 100;
    
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",levelPercent];
    
    float timeHour;
    int hour, min;
    NSString * timeMsg;
    if(isCharging){
        if(levelPercent < 100 && instantAmperage > 0){
            timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
            hour = timeHour;
            min = (timeHour - hour) * 60;
            if (hour == 0) {
                timeMsg = [NSString stringWithFormat:@"预计充电:%d分钟", min];
            }else{
                timeMsg = [NSString stringWithFormat:@"预计充电:%d小时%d分钟", hour, min];
            }
        }else if(levelPercent == 100){
            timeMsg = @"充电已完成！";
        }else{
            timeMsg = @"正在预估时间...";
        }
    }else{
        timeMsg = @"未充电";
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









static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(SBLockScreenBatteryChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(self, _cmd);
    if(!isInited){
        
        containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        containView.center = CGPointMake(160, 165);
        containView.backgroundColor = [UIColor clearColor];
        
        remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        remainingTime.font = [UIFont systemFontOfSize:17];
        [remainingTime setTextAlignment:NSTextAlignmentCenter];
        remainingTime.backgroundColor = [UIColor clearColor];
        [containView addSubview:remainingTime];
        
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
    
    float timeHour;
    int hour, min;
    NSString * timeMsg;
    
    if(isCharging){
        if(currentCapacity < maxCapacity && instantAmperage > 0){
            timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
            hour = timeHour;
            min = (timeHour - hour) * 60;
            if (hour == 0) {
                timeMsg = [NSString stringWithFormat:@"预计充电:%d分钟", min];
            }else{
                timeMsg = [NSString stringWithFormat:@"预计充电:%d小时%d分钟", hour, min];
            }
        }else if(currentCapacity == maxCapacity){
            timeMsg = @"充电已完成！";
        }else{
            timeMsg = @"正在预估时间...";
        }
    }else{
        timeMsg = @"未充电";
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


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(batteryStatusDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$);Class _logos_class$_ungrouped$SBAwayChargingView = objc_getClass("SBAwayChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(addChargingView), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$addChargingView, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$addChargingView);MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$dealloc);Class _logos_class$_ungrouped$SBLockScreenBatteryChargingView = objc_getClass("SBLockScreenBatteryChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews);MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc);} }
#line 257 "/Users/Ming/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
