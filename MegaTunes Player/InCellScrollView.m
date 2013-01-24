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

    // If not dragging, send event to next responder
    if (!self.dragging) {
//            NSLog(@"touch scroll not dragging");
        [self.nextResponder touchesEnded: touches withEvent:event];
    } else {
        [super touchesEnded: touches withEvent: event];
//            NSLog(@"touch scroll is dragging");
    }
}

//OMG need to for nextResponder to handled passed through touchesEnded 
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
//        NSLog(@"touchesBegan in scrollview");
        [self.nextResponder touchesBegan: touches withEvent:event];
        [super touchesBegan: touches withEvent: event];
}


@end
