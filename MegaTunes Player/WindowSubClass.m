//
//  WindowSubClass.m
//  MegaTunes Player
//
//  Created by Lori Hill on 4/2/13.
//
//

#import "WindowSubClass.h"

@implementation WindowSubClass

@synthesize beganTouches;
@synthesize cancelTouches;
@synthesize endTouches;
@synthesize moveTouches;
@synthesize touchesObserver;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)sendEvent:(UIEvent *)event {
	[super sendEvent:event];
	
	// only if it is a touch event type and we have observer
	if ((touchesObserver) && (event.type == UIEventTypeTouches)) {
        NSLog (@"here i am");
		// empty sets
		[beganTouches removeAllObjects];
		[cancelTouches removeAllObjects];
		[endTouches removeAllObjects];
		[moveTouches removeAllObjects];
		
		// fill in sets
		for (UITouch * touch in [event allTouches]) {
			if (touch.phase == UITouchPhaseBegan) [beganTouches addObject:touch];
			else if (touch.phase == UITouchPhaseCancelled) [cancelTouches addObject:touch];
			else if (touch.phase == UITouchPhaseMoved) [moveTouches addObject:touch];
			else if (touch.phase == UITouchPhaseEnded) [endTouches addObject:touch];
		}
		
		// call methods
		if ([beganTouches count] > 0) [touchesObserver touchesBegan:beganTouches withEvent:event];
		if ([cancelTouches count] > 0) [touchesObserver touchesCancelled:cancelTouches withEvent:event];
		if ([moveTouches count] > 0) [touchesObserver touchesMoved:moveTouches withEvent:event];
		if ([endTouches count] > 0) [touchesObserver touchesEnded:endTouches withEvent:event];
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
