#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
BOOL isCharging;

%hook SpringBoard
- (void)batteryStatusDidChange:(id)batteryStatus
{
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue]; //1352
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    
  
    NSDictionary *preference = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cn.ming.ChargingHelper.plist"];
    
    static BOOL alertFlag = YES;
    BOOL isRepeat = [[preference objectForKey:@"isRepeat"]boolValue];
    BOOL isVibrate = [[preference objectForKey:@"isVibrate"] boolValue];
    BOOL isSound = [[preference objectForKey:@"isSound"] boolValue];
    /* check the charging is complete or not. */
    
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
                NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/Voicemail.caf"]; //音乐文件路径
                CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
                AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
                //变量SoundID与URL对应
                AudioServicesPlaySystemSound(sameViewSoundID); //播放SoundID声音
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
                    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/Voicemail.caf"]; //音乐文件路径
                    CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
                    AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
                    //变量SoundID与URL对应
                    AudioServicesPlaySystemSound(sameViewSoundID); //播放SoundID声音
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

	%orig;
}

%end

/* When the Firmware <= iOS 6, use SBAwayChaingView */
%hook SBAwayChargingView

BOOL isInited = NO;
UIView *containView;
UILabel *batteryLevel, *chargingStatus, *remainingTime;

- (void)addChargingView
{
    %orig;
    
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

-(void)dealloc
{
    [batteryLevel removeFromSuperview];
    [chargingStatus removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];

    [chargingStatus release];
    [batteryLevel release];
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    %orig;
}

%end


/* When the Firmware > iOS 7, use SBLockScreenBatteryChargingView */

%hook SBLockScreenBatteryChargingView

- (void)layoutSubviews
{
    %orig;
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
-(void)dealloc
{
    [batteryLevel removeFromSuperview];
    [chargingStatus removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];
    
    [chargingStatus release];
    [batteryLevel release];
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    
    %orig;
}

%end
