#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "header.h"
#import "SNPageGestureRecognizer.h"




BOOL isFirmware70 = NO;
BOOL isFirmware80 = NO;
BOOL isFirmware90 = NO;

BOOL SNEnable = YES;
NSMutableArray *SNBlackList = nil;

NSUserDefaults *userDefaults = nil;
NSMutableArray *navigations = nil;



#define isEnable() (SNEnable == YES && ![SNBlackList containsObject:[[NSBundle mainBundle] bundleIdentifier]])



%hook _UIScreenEdgePanRecognizer

+ (BOOL)_edgeSwipeNavigationGestureEnabled {
	if (SNEnable == NO || [SNBlackList containsObject:[[NSBundle mainBundle] bundleIdentifier]])
		return %orig;
	
	return NO;
}

%end

%hook _UINavigationInteractiveTransition

- (void)_configureNavigationGesture {
	%orig;
	
	if (isEnable()) {
		UIPanGestureRecognizer *&g = MSHookIvar<UIPanGestureRecognizer *>(self, "_gestureRecognizer");
		[self._parent.view removeGestureRecognizer:g];
		g = nil;
		
		g = [[SNPageGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
		[g _setHysteresis:g._hysteresis * 2.0f];
		[g setMaximumNumberOfTouches:1];
		[g setDelegate:self];
		[g _setRequiresSystemGesturesToFail:YES];
		
		[self._parent.view addGestureRecognizer:g];
		[g release];
	}
	
	if (![navigations containsObject:self])
		[navigations addObject:self];
}

- (void)dealloc {
	[navigations removeObject:self];
	
	%orig;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch {
	BOOL rtn = %orig;
	
	if (rtn && isEnable()) {
		if ([touch tapCount] == 1) {
			if ([[touch view] isKindOfClass:[UISlider class]]
					|| ([[touch view] isKindOfClass:[UITextView class]] && ((UITextView *)[touch view]).editable == YES)
					|| [[touch view] isKindOfClass:%c(UITableViewCellReorderControl)]) {
				rtn = NO;
			}
		}
		else rtn = NO;
	}
	
	return rtn;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture {
	BOOL rtn = %orig;
	
	if (rtn && isEnable()) {
		if ([[%c(UIPeripheralHost) activeInstance] isOnScreen]) {
			//rtn = NO;
		}
	}
	
	return rtn;
}

%end



void LoadSettings() {
	@autoreleasepool {
		if (!isFirmware80) {
			NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/me.deVbug.SwipeNav.plist"];
			
			SNEnable = [dict[@"SwipeNavEnable"] boolValue];
			if (dict[@"SwipeNavEnable"] == nil)
				SNEnable = YES;
			
			[SNBlackList release];
			SNBlackList = nil;
			
			if (dict[@"BlackList"]) {
				SNBlackList = [[NSMutableArray arrayWithArray:dict[@"BlackList"]] retain];
				
				for (NSString *identifier in dict[@"ForceBlackList"]) {
					if (![SNBlackList containsObject:identifier]) {
						[SNBlackList addObject:identifier];
					}
				}
			}
			
			[dict release];
		}
		else {
			SNEnable = [userDefaults boolForKey:@"SwipeNavEnable"];
			
			[SNBlackList release];
			SNBlackList = nil;
			
			if ([userDefaults objectForKey:@"BlackList"]) {
				SNBlackList = [[NSMutableArray arrayWithArray:[userDefaults objectForKey:@"BlackList"]] retain];
				
				for (NSString *identifier in [userDefaults objectForKey:@"ForceBlackList"]) {
					if (![SNBlackList containsObject:identifier]) {
						[SNBlackList addObject:identifier];
					}
				}
			}
		}
		
		for (_UINavigationInteractiveTransition *transition in navigations) {
			[transition _configureNavigationGesture];
		}
	}
}

static void reloadPrefsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	LoadSettings();
}


%ctor
{
	isFirmware70 = (kCFCoreFoundationVersionNumber >= 847.20);
	isFirmware80 = (kCFCoreFoundationVersionNumber >= 1129.15);
	isFirmware90 = (kCFCoreFoundationVersionNumber >= 1240.10);
	
	if (!isFirmware70) return;
	
	navigations = [[NSMutableArray array] retain];
	
	userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"me.deVbug.SwipeNav"];
	[userDefaults registerDefaults:@{
		@"SwipeNavEnable" : @YES,
		@"BlackList" : @[],
		@"ForceBlackList" : @[]
	}];
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPrefsNotification, CFSTR("me.devbug.swipenav.prefnoti"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	LoadSettings();
	
	%init;
}

