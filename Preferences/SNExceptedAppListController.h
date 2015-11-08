#import <UIKit/UIKit.h>
#import "Preferences.h"

#import "../../FilteredAppListTableView/PSFilteredAppListListController.h"


@interface SNExceptedAppListController : PSEditableListController <PSFilteredAppListDelegate>
- (void)dealloc;

- (void)loadSettings;
- (void)saveSettings;
- (void)addExceptedApp:(NSString *)displayId;
- (void)openAppList:(int)section;
- (void)closeAppListView;
@end
