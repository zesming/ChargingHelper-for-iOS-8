#line 1 "/Users/zhao/Desktop/My Program/ChargingHelper/ChargingHelper/ChargingHelper.xm"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

int currentCapacity, maxCapacity, instantAmperage;
NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
NSDictionary *recordResult;

#include <logos/logos.h>
#include <substrate.h>
@class SBAwayChargingView; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard*, SEL, id); static void (*_logos_orig$_ungrouped$SBAwayChargingView$addChargingView)(SBAwayChargingView*, SEL); static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView*, SEL); 

#line 8 "/Users/zhao/Desktop/My Program/ChargingHelper/ChargingHelper/ChargingHelper.xm"



static void _logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$(SpringBoard* self, SEL _cmd, id batteryStatus) {
	currentCapacity = [[batteryStatus objectForKey:@"CurrentCapacity"] intValue]; 
    maxCapacity = [[batteryStatus objectForKey:@"MaxCapacity"] intValue];
    instantAmperage = [[batteryStatus objectForKey:@"InstantAmperage"] intValue];
    BOOL isCharging = [[batteryStatus objectForKey:@"IsCharging"]boolValue];
    BOOL fullyCharged = [[batteryStatus objectForKey:@"FullyCharged"]boolValue];

    
    float currentLevel = ((float)currentCapacity/maxCapacity) * 100;
    NSString *levelStr = [NSString stringWithFormat:@"%.2f%%", currentLevel];
    
    if(isCharging){
        [recordDic setObject:[NSString stringWithFormat:@"输入电流：%d 是否充满电：%@", instantAmperage, fullyCharged ? @"Yes" : @"No"] forKey:levelStr];
    }
    recordResult = recordDic;
    [recordResult writeToFile:@"/tmp/chargingResult.plist" atomically:YES];

    
    

















	_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$(self, _cmd, batteryStatus);
}







static void _logos_method$_ungrouped$SBAwayChargingView$addChargingView(SBAwayChargingView* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayChargingView$addChargingView(self, _cmd);
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

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(batteryStatusDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStatusDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$batteryStatusDidChange$);Class _logos_class$_ungrouped$SBAwayChargingView = objc_getClass("SBAwayChargingView"); MSHookMessageEx(_logos_class$_ungrouped$SBAwayChargingView, @selector(addChargingView), (IMP)&_logos_method$_ungrouped$SBAwayChargingView$addChargingView, (IMP*)&_logos_orig$_ungrouped$SBAwayChargingView$addChargingView);} }
#line 103 "/Users/zhao/Desktop/My Program/ChargingHelper/ChargingHelper/ChargingHelper.xm"
