#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "SNPageGestureRecognizer.h"



@interface SNPageGestureRecognizer ()
@property (nonatomic, assign) CGPoint touchStartPosition;
@property (nonatomic, assign) BOOL secondTouchReceived;
@end

@implementation SNPageGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	self.touchStartPosition = [touch locationInView:self.view];
	self.secondTouchReceived = NO;
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.secondTouchReceived == NO) {
		self.secondTouchReceived = YES;
		
		UITouch *touch = [touches anyObject];
		CGPoint tempPoint = [touch locationInView:self.view];
		CGFloat moveX = ABS(tempPoint.x - self.touchStartPosition.x);
		CGFloat moveY = ABS(tempPoint.y - self.touchStartPosition.y);
		
		// 22.5"
		if (moveY * 2.0f > moveX) {
			self.state = UIGestureRecognizerStateFailed;
			return;
		}
	}
	
	[super touchesMoved:touches withEvent:event];
}

- (void)reset {
	[super reset];
	
	self.touchStartPosition = CGPointZero;
	self.secondTouchReceived = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
}

@end
