#import <UIKit/UIKit.h>
#import "Preferences.h"
#import "SNExceptedAppListController.h"



@implementation SwipeNavListController


- (id)specifiers {
	if (!_specifiers) {
		[self setTitle:@"SwipeNav"];
		
		PSSpecifier *specifier1 = [PSSpecifier preferenceSpecifierNamed:[[self bundle] localizedStringForKey:@"Enable" value:@"Enable" table:@"SwipeNav"]
																 target:self
																	set:@selector(setPreferenceValue:specifier:)
																	get:@selector(getPreferenceValue:)
																 detail:nil
																   cell:PSSwitchCell
																   edit:nil];
		[specifier1 setProperty:@"SwipeNavEnable" forKey:@"key"];
		[specifier1 setProperty:@"me.devbug.swipenav.prefnoti" forKey:@"PostNotification"];
		[specifier1 setProperty:@"me.deVbug.SwipeNav" forKey:@"defaults"];
		[specifier1 setProperty:@(YES) forKey:@"default"];
		
		PSSpecifier *specifier2 = [PSSpecifier preferenceSpecifierNamed:[[self bundle] localizedStringForKey:@"BlackList Apps" value:@"Excluded Apps" table:@"SwipeNav"]
																 target:self
																	set:nil
																	get:nil
																 detail:[SNExceptedAppListController class]
																   cell:PSLinkCell
																   edit:nil];
		[specifier2 setProperty:@"BlackList" forKey:@"key"];
		[specifier2 setProperty:@"me.devbug.swipenav.prefnoti" forKey:@"PostNotification"];
		[specifier2 setProperty:@"me.deVbug.SwipeNav" forKey:@"defaults"];
		
		PSConfirmationSpecifier *donate = [PSConfirmationSpecifier preferenceSpecifierNamed:[[self bundle] localizedStringForKey:@"Donate" value:@"Donate" table:@"SwipeNav"]
																 target:self
																	set:nil
																	get:nil
																 detail:nil
																   cell:PSButtonCell
																   edit:nil];
		donate.title = [[self bundle] localizedStringForKey:@"Donate" value:@"Donate" table:@"SwipeNav"];
		donate.prompt = [[self bundle] localizedStringForKey:@"DONATION_PROMPT" value:@"Exit Settings and donate via PayPal through Safari?" table:@"SwipeNav"];
		donate.okButton = [[self bundle] localizedStringForKey:@"Yes!" value:@"Yes!" table:@"SwipeNav"];
		donate.cancelButton = [[self bundle] localizedStringForKey:@"Not Now" value:@"Not now" table:@"SwipeNav"];
		donate.confirmationAction = @selector(donate:);
		[donate setProperty:@(2) forKey:@"alignment"];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/swipenav.bundle/icon-paypal.png"];
		[donate setProperty:image forKey:@"iconImage"];
		[image release];
		
		PSSpecifier *footer = [PSSpecifier emptyGroupSpecifier];
		[footer setProperty:[[self bundle] localizedStringForKey:@"COPYRIGHT_MSG" value:@"SwipeNav © deVbug" table:@"SwipeNav"] forKey:@"footerText"];
		
		_specifiers = [[NSMutableArray alloc] initWithObjects:
													[PSSpecifier emptyGroupSpecifier],
													specifier1, 
													[PSSpecifier emptyGroupSpecifier],
													specifier2, 
													[PSSpecifier emptyGroupSpecifier],
													donate,
													footer,
													nil];
	}
	
	return _specifiers;
}

- (void)donate:(id)sender {
	NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=MQVNYVMDU78CG&lc=KR&item_name=SwipeNav&item_number=SwipeNav&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)setPreferenceValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	[PSRootController setPreferenceValue:value specifier:specifier];
}

- (NSNumber *)getPreferenceValue:(PSSpecifier *)specifier {
	return [PSRootController readPreferenceValue:specifier];
}


@end
