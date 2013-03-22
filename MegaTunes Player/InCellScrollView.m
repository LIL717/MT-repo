//
//  inCellScrollView.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/21/13.
//
//

#import "InCellScrollView.h"


@implementation InCellScrollView

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    if (self.dragging) {
        [super touchesEnded: touches withEvent: event];
//        NSLog (@"touches that ended dragging are %@", touches);
        NSLog(@"touch scroll is dragging");
    } else {
        [self.nextResponder touchesEnded: touches withEvent:event];
        [super touchesBegan: touches withEvent: event];
    }
}

//OMG need this too for nextResponder to handled passed through touchesEnded
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
        NSLog(@"touchesBegan in scrollview");
        [self.nextResponder touchesBegan: touches withEvent:event];
        [super touchesBegan: touches withEvent: event];
//    for (UITouch *touch in touches) {
//        NSLog (@"BEGINNING TOUCH: %@", touch);
//    }
}

@end
