#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
BOOL isCharging;

@interface SpringBoard : UIApplication
-(void)popAlertView;
-(void)playVibrate;
-(void)playSound;
-(void)recordChargingLog;
@end

%hook SpringBoard

//create a dic to record charging status
NSMutableDictionary *mutableLog = [NSMutableDictionary dictionary];
NSDictionary *batteryStatusDic, *dicLog;

- (void)batteryStatusDidChange:(id)batteryStatus
{
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue];
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    BOOL fullyCharged = [[batteryStatus objectForKey:@"FullyCharged"] boolValue];
    
    /***********************************************
     record the charging status,
     it can be removed if you don't want to use it. 
     ***********************************************/
    if (isCharging || fullyCharged){
        [self recordChargingLog];
    }

    static BOOL alertFlag = YES;
    
    /* check the charging is complete or not. */
    if(currentCapacity == maxCapacity && isCharging)
    {
        //[batteryStatus writeToFile:@"/tmp/a.plist" atomically:YES];
        
        /* Load the Preferences */
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
    
    

	%orig;
}

%new
-(void)popAlertView
{
    /* check the os language */
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
    
    //pop the alert view
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cbButton otherButtonTitles:nil];
    [alert show];
    [alert release];
}

%new
-(void)playVibrate
{
    SystemSoundID vibrate;
    vibrate = kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(vibrate);
}

%new
-(void)playSound
{
    SystemSoundID sameViewSoundID;
    NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/alert_sound.wav"]; //the path of sound file.
    CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);//create the ID of sound
    AudioServicesPlaySystemSound(sameViewSoundID); //play SoundID's sound
}

%new

/* a method to record the charging status */
-(void)recordChargingLog
{
    //battery level
    float batteryLevel = ((float)currentCapacity /maxCapacity) * 100;
    
    //now date
    NSDate *date = [NSDate date];
    NSString *now;
    now = [NSString stringWithFormat:@"%@", date];
    
    //is fully charged
    BOOL fullyCharged = [[batteryStatusDic objectForKey:@"FullyCharged"] boolValue];
    
    //remaining time
    float timeHour;
    int hour, min;
    NSString *timeMsg;
    if(isCharging){
        if(batteryLevel < 100 && instantAmperage > 0){
            timeHour = ((float)maxCapacity  - currentCapacity) / instantAmperage;
            hour = timeHour;
            min = (timeHour - hour) * 60;
            if (hour == 0) {
                timeMsg = [NSString stringWithFormat:@"0:%d", min];
            }else{
                timeMsg = [NSString stringWithFormat:@"%d:%d", hour, min];
            }
        }else if(batteryLevel == 100){
            timeMsg = [NSString stringWithFormat:@"充电已完成"];
        }else{
            timeMsg = [NSString stringWithFormat:@"正在预估时间..."];
        }
    }else{
        timeMsg = [NSString stringWithFormat:@"未充电"];
    }
    
    //record string
    NSString *recordMsg;
    recordMsg = [NSString stringWithFormat:@"%.2f%% 剩余:%@ 当前电流:%d 充电:%@ 充满电:%@ ", batteryLevel, timeMsg, instantAmperage,isCharging ? @"Yes" : @"No", fullyCharged ? @"Yes" : @"No"];
    
    //record log
    [mutableLog setObject:recordMsg forKey:now];
    dicLog = mutableLog;
    
    //write to file
    [dicLog writeToFile:@"/tmp/ChargingHelper_log.plist" atomically:YES];
}
%end

/* When the Firmware <= iOS 6, use SBAwayChaingView */

@interface SBAwayChargingView : UIView
-(void)initChargingTextView;
@end

%hook SBAwayChargingView
BOOL isInited = NO;
UIView *containView;
UILabel *batteryLevel, *remainingTime;
- (void)addChargingView
{
    %orig;
    
    if(!isInited){
        [self initChargingTextView];
        isInited = YES;
    }
    float currentLevel = ((float)currentCapacity / maxCapacity);
    float levelPercent = currentLevel * 100;
    
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",levelPercent];
    
    /* check the os language */
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

%new
-(void)initChargingTextView
{
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
%end

/* When the Firmware > iOS 7, use SBLockScreenBatteryChargingView */

@interface SBLockScreenBatteryChargingView : UIView
-(void)initChargingTextView;
@end

%hook SBLockScreenBatteryChargingView
- (void)layoutSubviews
{
    %orig;
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
    
    /* check the os language */
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
-(void)dealloc
{
    [remainingTime removeFromSuperview];
    [containView removeFromSuperview];
    
    [remainingTime release];
    [containView release];
    
    isInited = NO;
    
    %orig;
}

%new
-(void)initChargingTextView
{
    containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    containView.center = CGPointMake(160, 160);
    containView.backgroundColor = [UIColor clearColor];
    
    remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    remainingTime.font = [UIFont systemFontOfSize:17];
    [remainingTime setTextAlignment:NSTextAlignmentCenter];
    remainingTime.backgroundColor = [UIColor clearColor];
    [containView addSubview:remainingTime];
}
%end
