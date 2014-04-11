#line 1 "/Users/zhao/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
BOOL isCharging;

#include <logos/logos.h>
#include <substrate.h>
@class SBLockScreenBatteryChargingView; @class SBAwayChargingView; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard*, SEL, id); static void (*_logos_orig$_ungrouped$SBAwayChargingView$addChargingView)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBAwayChargingView$dealloc)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$dealloc(SBAwayChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews(SBLockScreenBatteryChargingView*, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc)(SBLockScreenBatteryChargingView*, SEL); static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc(SBLockScreenBatteryChargingView*, SEL); 

#line 7 "/Users/zhao/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"


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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机充电已完成，建议拔掉充电器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
                NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/Voicemail.caf"]; 
                CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
                AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
                
                AudioServicesPlaySystemSound(sameViewSoundID); 
            }
            
        }
        else
        {
            if(alertFlag)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机充电已完成，建议拔掉充电器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
                    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/Voicemail.caf"]; 
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
UILabel *batteryLevel, *chargingStatus, *remainingTime;


static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayChargingView$addChargingView(self, _cmd);
    
    if(!isInited){
        containView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 280, 30)];
        containView.center = CGPointMake(140, 210);
        containView.backgroundColor = [UIColor clearColor];
        
        batteryLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
        batteryLevel.font = [UIFont boldSystemFontOfSize:25];
        [batteryLevel setTextAlignment:NSTextAlignmentCenter];
        [batteryLevel setTextColor:[UIColor whiteColor]];
        batteryLevel.backgroundColor = [UIColor clearColor];
        [containView addSubview:batteryLevel];
        
        chargingStatus = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 170, 15)];
        chargingStatus.font = [UIFont systemFontOfSize:12];
        [chargingStatus setTextColor:[UIColor orangeColor]];
        chargingStatus.backgroundColor = [UIColor clearColor];
        [containView addSubview:chargingStatus];
        
        remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 170, 15)];
        remainingTime.font = [UIFont systemFontOfSize:12];
        [remainingTime setTextColor:[UIColor whiteColor]];
        remainingTime.backgroundColor = [UIColor clearColor];
        [containView addSubview:remainingTime];
        
        [self addSubview:containView];
        
        isInited = YES;
    }
    float currentLevel = ((float)currentCapacity/maxCapacity);
    float levelPercent = currentLevel * 100;
    
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",levelPercent];
    
    NSString *chargingMsg;
    if (levelPercent == 100.0f) {
        chargingMsg = @"充电已完成！";
    }else if(!isCharging){
        chargingMsg = @"请拔掉充电器";
    }else{
        chargingMsg = @"正在充电中...";
    }
    chargingStatus.text = chargingMsg;
    
    float timeHour;
    int hour, min;
    NSString * timeMsg;
    
    if (instantAmperage <= 0 ) {
        timeMsg = @"充电已完成，请拔掉充电器。";
    } else {
        timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
        hour = timeHour;
        min = (timeHour - hour) * 60;
        if (hour == 0) {
            timeMsg = [NSString stringWithFormat:@"预计充电时间：%d分钟", min];
        }else{
            timeMsg = [NSString stringWithFormat:@"预计充电时间：%d小时%d分钟", hour, min];
        }
    }
    remainingTime.text = timeMsg;

}


static void _logos_method$_ungrouped$SBAwayChargingView$dealloc(SBAwayChargingView* self, SEL _cmd) {
    [batteryLevel removeFromSuperview];
    [chargingStatus removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];

    [chargingStatus release];
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
        containView.center = CGPointMake(160, 200);
        containView.backgroundColor = [UIColor clearColor];
        
        batteryLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
        batteryLevel.font = [UIFont boldSystemFontOfSize:25];
        [batteryLevel setTextAlignment:NSTextAlignmentCenter];
        [batteryLevel setTextColor:[UIColor blackColor]];
        batteryLevel.backgroundColor = [UIColor clearColor];
        [containView addSubview:batteryLevel];
        
        chargingStatus = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 170, 15)];
        chargingStatus.font = [UIFont systemFontOfSize:12];
        [chargingStatus setTextColor:[UIColor orangeColor]];
        chargingStatus.backgroundColor = [UIColor clearColor];
        [containView addSubview:chargingStatus];
        
        remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 170, 15)];
        remainingTime.font = [UIFont systemFontOfSize:12];
        [remainingTime setTextColor:[UIColor blackColor]];
        remainingTime.backgroundColor = [UIColor clearColor];
        [containView addSubview:remainingTime];
        
        [self addSubview:containView];
        
        isInited = YES;
    }
    float currentLevel = ((float)currentCapacity/maxCapacity);
    float levelPercent = currentLevel * 100;
    
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",levelPercent];

    NSString *chargingMsg;
    if (levelPercent == 100.0f) {
        chargingMsg = @"充电已完成！";
    }else if(!isCharging){
        chargingMsg = @"请拔掉充电器";
    }else{
        chargingMsg = @"正在充电中...";
    }
    chargingStatus.text = chargingMsg;
    
    float timeHour;
    int hour, min;
    NSString * timeMsg;
    
    if (instantAmperage <= 0 ) {
        timeMsg = @"充电已完成，请拔掉充电器。";
    } else {
        timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
        hour = timeHour;
        min = (timeHour - hour) * 60;
        if (hour == 0) {
            timeMsg = [NSString stringWithFormat:@"预计充电时间：%d分钟", min];
        }else{
            timeMsg = [NSString stringWithFormat:@"预计充电时间：%d小时%d分钟", hour, min];
        }
    }
    remainingTime.text = timeMsg;

}

static void _logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc(SBLockScreenBatteryChargingView* self, SEL _cmd) {
    [batteryLevel removeFromSuperview];
    [chargingStatus removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];
    
    [chargingStatus release];
    [batteryLevel release];
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    
    _logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc(self, _cmd);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(batteryStatusDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$);Class _logos_class$_ungrouped$SBAwayChargingView = objc_getClass("SBAwayChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(addChargingView), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$addChargingView, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$addChargingView);MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$dealloc);Class _logos_class$_ungrouped$SBLockScreenBatteryChargingView = objc_getClass("SBLockScreenBatteryChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$layoutSubviews);MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenBatteryChargingView, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBLockScreenBatteryChargingView$dealloc, (IMP*)&_logos_orig$_ungrouped$SBLockScreenBatteryChargingView$dealloc);} }
#line 275 "/Users/zhao/Desktop/ChargingHelper/ChargingHelper/ChargingHelper.xm"
