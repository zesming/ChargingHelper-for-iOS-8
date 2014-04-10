#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
NSDictionary *recordResult;

%hook SpringBoard

- (void)batteryStatusDidChange:(id)batteryStatus
{
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue]; //1352
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    BOOL isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    BOOL fullyCharged = [[batteryStatus objectForKey:@"FullyCharged"]boolValue];

    /* Loging the battery status during charging */
    float currentLevel = ((float)currentCapacity/maxCapacity) * 100;
    NSString *levelStr = [NSString stringWithFormat:@"%.2f%%", currentLevel];
    
    if(isCharging){
        [recordDic setObject:[NSString stringWithFormat:@"输入电流：%d 是否充满电：%@", instantAmperage, fullyCharged ? @"Yes" : @"No"] forKey:levelStr];
    }
    recordResult = recordDic;
    [recordResult writeToFile:@"/tmp/chargingResult.plist" atomically:YES];

    
    /*
    if(currentCapacity == maxCapacity && isCharging)
    {
        [batteryStatus writeToFile:@"/tmp/a.plist" atomically:YES];
        SystemSoundID sameViewSoundID;
        NSString *thesoundFilePath = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/New/Sherwood_Forest.caf"]; //音乐文件路径
        CFURLRef thesoundURL = (CFURLRef)[NSURL fileURLWithPath:thesoundFilePath];
        AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
        //变量SoundID与URL对应
        
        AudioServicesPlaySystemSound(sameViewSoundID); //播放SoundID声音
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机充电已完成，请拔掉充电器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
     */

	%orig;
}

%end

/* When the Firmware <= iOS 6, use SBAwayChaingView */
%hook SBAwayChargingView

- (void)addChargingView
{
    %orig;
    float currentLevel = ((float)currentCapacity/maxCapacity) * 100;
    
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    containView.center = CGPointMake(130, 220);
    containView.backgroundColor = [UIColor blackColor];
    
    UILabel *batteryLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    batteryLevel.text = [NSString stringWithFormat:@"%.2f%%",currentLevel];
    [batteryLevel setShadowColor:[UIColor grayColor]];
    batteryLevel.font = [UIFont boldSystemFontOfSize:25];
    [batteryLevel setTextAlignment:NSTextAlignmentCenter];
    [batteryLevel setTextColor:[UIColor whiteColor]];
    batteryLevel.backgroundColor = [UIColor blackColor];
    [containView addSubview:batteryLevel];
    
    NSString *chargingMsg;
    if (currentLevel == 100.00) {
        chargingMsg = @"充电已完成！";
    }else {
        chargingMsg = @"正在充电中...";
    }
    
    UILabel *chargingStatus = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 150, 15)];
    chargingStatus.text = chargingMsg;
    chargingStatus.font = [UIFont systemFontOfSize:12];
    [chargingStatus setTextColor:[UIColor orangeColor]];
    chargingStatus.backgroundColor = [UIColor blackColor];
    [containView addSubview:chargingStatus];
    
    UILabel *remainingTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 150, 15)];
    remainingTime.text = @"预计需充电：4小时59分钟";
    remainingTime.font = [UIFont systemFontOfSize:12];
    [remainingTime setTextColor:[UIColor whiteColor]];
    remainingTime.backgroundColor = [UIColor blackColor];
    [containView addSubview:remainingTime];
    
    [self addSubview:containView];
    
    [containView release];
    [chargingStatus release];
    [batteryLevel release];
    [remainingTime release];
    
}
%end
