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
                NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; //音乐文件路径
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
                    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; //音乐文件路径
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
UILabel *batteryLevel, *remainingTime;

- (void)addChargingView
{
    %orig;
    
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
        if(instantAmperage > 0){
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

-(void)dealloc
{
    [batteryLevel removeFromSuperview];
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];

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
        if(instantAmperage > 0){
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
-(void)dealloc
{
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];
    
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    
    %orig;
}

%end
