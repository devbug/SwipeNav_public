#import <UIKit/UIKit.h>
#import "SNExceptedAppListController.h"


extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);



@interface SNAppListNavigationController : UINavigationController
@end

@implementation SNAppListNavigationController

- (BOOL)shouldAutorotate {
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end


@interface SNExceptedAppListController ()
@property (nonatomic, retain) NSMutableArray *blacklist;
@property (nonatomic, readonly) PSFilteredAppListListController *blackListController;
@property (nonatomic, readonly) SNAppListNavigationController *blacklistNavigationController;
@property (nonatomic) int addMode;
@end


@implementation SNExceptedAppListController


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[PSRootController setPreferenceValue:value specifier:specifier];
}

- (id)getPreferenceValue:(PSSpecifier *)specifier {
	return [PSRootController readPreferenceValue:specifier];
}

- (void)loadSettings {
	NSMutableDictionary *plist = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/me.deVbug.SwipeNav.plist"]) {
		plist = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/me.deVbug.SwipeNav.plist"];
	}
	
	//self.blacklist = data[@"BlackList"];
	
	//if (self.blacklist == nil)
	//	self.blacklist = [NSMutableArray array];
	
	NSArray *data = [self getPreferenceValue:self.specifier];
	
	if (data && [data isKindOfClass:[NSArray class]]) {
		self.blacklist = [NSMutableArray arrayWithArray:data];
	}
	else {
		self.blacklist = [NSMutableArray array];
	}
	
	for (NSString *identifier in plist[@"ForceBlackList"]) {
		if (![self.blacklist containsObject:identifier]) {
			[self.blacklist addObject:identifier];
		}
	}
	
	[self saveSettings];
}

- (void)saveSettings {
	NSArray *data = [NSArray arrayWithArray:self.blacklist];
	
	[self setPreferenceValue:data specifier:self.specifier];
}


- (PSSpecifier *)newAppSpecifier:(NSString *)displayId asLink:(BOOL)asLink {
	NSString *name = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayId);
	PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:(name && name.length != 0 ? name : displayId)
															target:self
															   set:nil
															   get:nil
															detail:Nil
															  cell:PSStaticTextCell
															  edit:nil];
	[specifier setProperty:displayId forKey:@"displayIdentifier"];
	[specifier setProperty:@(YES) forKey:PSLazyIconLoading];
	[specifier setProperty:displayId forKey:PSLazyIconAppID];
	[specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
	[specifier setProperty:@(YES) forKey:@"enabled"];
	
	return specifier;
}

- (void)addExceptedApp:(NSString *)displayId {
	[self closeAppListViewWithHandler:^{
		if (self.addMode == 0) {
			if (![self.blacklist containsObject:displayId]) {
				[self.blacklist addObject:displayId];
				
				[self saveSettings];
				
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.table numberOfRowsInSection:0]-1) inSection:0];
				[self insertSpecifier:[self newAppSpecifier:displayId asLink:NO] atIndex:[self indexForIndexPath:indexPath] animated:YES];
				
				[self.blackListController setNeedsToReload];
			}
		}
	}];
}

- (void)closeAppListView {
	[self closeAppListViewWithHandler:nil];
}

- (void)closeAppListViewWithHandler:(void (^)(void))handler {
	if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
		[self dismissViewControllerAnimated:YES completion:handler];
	}
	else {
		[self dismissModalViewControllerAnimated:YES];
		if (handler != nil)
			handler();
	}
	
	NSIndexPath *selected = [self.table indexPathForSelectedRow];
	if (selected) {
		[self.table deselectRowAtIndexPath:selected animated:YES];
	}
}

- (void)openAppList:(int)section {
	self.addMode = section;
	
	self.blacklistNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[self presentViewController:self.blacklistNavigationController animated:YES completion:nil];
	}
	else {
		[self presentModalViewController:self.blacklistNavigationController animated:YES];
	}
}


- (BOOL)isOtherFilteredForIdentifier:(NSString *)identifier {
	BOOL isOtherFiltered = NO;
	
	if ([self.blacklist containsObject:identifier])
		isOtherFiltered = YES;
	
	return isOtherFiltered;
}

- (FilteredListType)filteredListTypeForIdentifier:(NSString *)identifier {
	return FilteredListNone;
}

- (void)didSelectRowAtCell:(PSFilteredAppListCell *)cell {
	NSString *identifier = cell.displayId;
	
	cell.filteredListType = FilteredListNone;
	
	[self addExceptedApp:identifier];
}


- (id)specifiers {
	if (!_specifiers) {
		[self loadSettings];
		
		NSString *addItemTitle = [[self bundle] localizedStringForKey:@"Add item" value:@"Add item" table:@"Advanced"];
		_blackListController = [[PSFilteredAppListListController alloc] init];
		self.blackListController.delegate = self;
		self.blackListController.enableForceType = NO;
		self.blackListController.filteredAppType = (FilteredAppAll & ~FilteredAppWebapp);
		self.blackListController.isPopover = YES;
		self.blackListController.title = addItemTitle;
		_blacklistNavigationController = [[SNAppListNavigationController alloc] initWithRootViewController:(UIViewController *)self.blackListController];
		
		NSMutableArray *__specifiers = [[NSMutableArray alloc] initWithObjects:[PSSpecifier groupSpecifierWithName:[[self bundle] localizedStringForKey:@"Disable" value:@"Disable" table:@"Advanced"]], nil];
		
		for (NSString *displayIdentifier in self.blacklist) {
			[__specifiers addObject:[self newAppSpecifier:displayIdentifier asLink:NO]];
		}
		
		PSSpecifier *addButton = [PSSpecifier preferenceSpecifierNamed:addItemTitle
																 target:self
																	set:nil
																	get:nil
																 detail:nil
																   cell:PSButtonCell
																   edit:nil];
		[addButton setProperty:@(0) forKey:@"section"];
		addButton.buttonAction = @selector(openAppListForSpecifier:);
		
		[__specifiers addObject:addButton];
		
		_specifiers = __specifiers;
	}
	
	return _specifiers;
}

- (BOOL)openAppListForSpecifier:(PSSpecifier *)specifier {
	int section = [[specifier propertyForKey:@"section"] intValue];
	
	[self openAppList:section];
	
	return YES;
}

- (void)removedSpecifier:(PSSpecifier *)specifier {
	NSIndexPath *indexPath = [self indexPathForSpecifier:specifier];
	if (indexPath.section == 0) {
		[self.blacklist removeObjectAtIndex:indexPath.row];
	}
	
	[self saveSettings];
	
	[self.blackListController setNeedsToReload];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == [self.blacklist count]) {
			[self openAppList:indexPath.section];
			return;
		}
	}
	
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == [self.blacklist count]) {
			return UITableViewCellEditingStyleInsert;
		}
	}
	
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self openAppList:indexPath.section];
	}
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}


- (void)dealloc {
	[_blackListController release], _blackListController = nil;
	[_blacklistNavigationController release], _blacklistNavigationController = nil;
	self.blacklist = nil;
	
	[super dealloc];
}


@end

