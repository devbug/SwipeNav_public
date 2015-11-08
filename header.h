#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface _UINavigationInteractiveTransitionBase : UIPercentDrivenInteractiveTransition <UIGestureRecognizerDelegate>
@property(nonatomic, assign, setter=_setParent:) UIViewController *_parent;
@property(nonatomic, weak) UIPanGestureRecognizer *gestureRecognizer;
@end

@interface _UINavigationInteractiveTransition : _UINavigationInteractiveTransitionBase
@property(readonly, nonatomic) UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;
- (void)_configureNavigationGesture;
@end


@interface UIPeripheralHost : NSObject
+ (id)activeInstance;
+ (id)sharedInstance;
+ (struct CGRect)visiblePeripheralFrame;
- (BOOL)isOffScreen;
- (BOOL)isOnScreen;
@end


@interface UIScreenEdgePanGestureRecognizer (Private)
- (id)initWithTarget:(id)target action:(SEL)action type:(int)type;
- (CGFloat)_edgeRegionSize;
- (CGPoint)_locationForTouch:(id)arg1;
- (void)_setEdgeRegionSize:(CGFloat)arg1;
- (void)_setHysteresis:(CGFloat)arg1;
- (UIInterfaceOrientation)_touchInterfaceOrientation;
@end

@interface UIPanGestureRecognizer (Private)
- (CGFloat)_hysteresis;
- (void)_setHysteresis:(CGFloat)arg1;
@end

@interface UIGestureRecognizer (Private)
- (void)_setRequiresSystemGesturesToFail:(BOOL)arg1;
@end




@interface PreferencesAppController : NSObject
- (id)rootController;
@end

