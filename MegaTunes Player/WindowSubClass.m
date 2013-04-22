//
//  WindowSubClass.m
//  MegaTunes Player
//
//  Created by Lori Hill on 4/2/13.
//
//

#import "WindowSubClass.h"

@implementation WindowSubClass

@synthesize viewToObserve;
@synthesize controllerThatObserves;
@synthesize tapPoint;
@synthesize pointValue;

- (void)forwardTouchBegan:(id)touch onView:(UIView*)aView {
    [controllerThatObserves userTouchBegan:touch onView:aView];
}
- (void)forwardTouchMoved:(id)touch onView:(UIView*)aView {
    [controllerThatObserves userTouchMoved:touch onView:aView];
}
- (void)forwardTouchEnded:(id)touch onView:(UIView*)aView {
    [controllerThatObserves userTouchEnded:touch onView:aView];
}

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    
    if (viewToObserve == nil || controllerThatObserves == nil) return;
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    if ([touch.view isDescendantOfView:viewToObserve] == NO) return;
    
    self.tapPoint = [touch locationInView:viewToObserve];
    self.pointValue = [NSValue valueWithCGPoint:self.tapPoint];
    
    if (touch.phase == UITouchPhaseBegan)
        [self forwardTouchBegan:self.pointValue onView:touch.view];
    else if (touch.phase == UITouchPhaseMoved)
        [self forwardTouchMoved:self.pointValue onView:touch.view];
    else if (touch.phase == UITouchPhaseEnded)
        [self forwardTouchEnded:self.pointValue onView:touch.view];
    else if (touch.phase == UITouchPhaseCancelled)
        [self forwardTouchEnded:self.pointValue onView:touch.view];
}

@end
