#import "Preferences.h"


@implementation SNListController

- (void)loadView {
	[super loadView];
	
	if ([self respondsToSelector:@selector(navigationItem)]) {
		[[self navigationItem] setTitle:self._title];
	}
}

- (void)setTitle:(NSString *)title {
	if (title) {
		[super setTitle:title];
		self._title = title;
	}
}

@end


