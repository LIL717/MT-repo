//
//  InCellScrollView.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/21/13.
//
//

#import "InCellScrollView.h"


@implementation InCellScrollView


//@synthesize tapGestureRecognizer;
//
//- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
//{
//    NSLog(@"**********************************touchesEnded in scrollview");
//
////    if (self.dragging) {
////        [super touchesEnded: touches withEvent: event];
//////        NSLog (@"touches that ended dragging are %@", touches);
////        NSLog(@"touch scroll is dragging");
////    } else {
//        [[self.nextResponder nextResponder]  touchesEnded: touches withEvent:event];
//        [super touchesEnded: touches withEvent: event];
////    }
//    if ( !self.dragging ) {
//        
//        [self.nextResponder.nextResponder touchesEnded:touches withEvent:event];
//    }
//    [super touchesEnded:touches withEvent:event];
//}
//
////OMG need this too for nextResponder to handled passed through touchesEnded
//- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
//{
//    LogMethod();
////        NSLog(@"touchesBegan in scrollview");
//////        [self.nextResponder touchesBegan: touches withEvent:event];
////    [[self.nextResponder nextResponder] touchesBegan: touches withEvent:event];
////
////        [super touchesBegan: touches withEvent: event];
//////    for (UITouch *touch in touches) {
//////        NSLog (@"BEGINNING TOUCH: %@", touch);
//////    }
//    UITouch *touch = [[event allTouches] anyObject];
//    
//    NSLog(@"touch view = %@", [[touch view].class description]);
//    if ([[[touch view].class description] isEqualToString:@"UITableView"]) {
//        NSLog (@"You have touched a UITableView");
//    } else if ([[[touch view].class description] isEqualToString:@"UIView"]) {
//        NSLog (@"You have touched a UIView");
//    } else {
//        //Ignore the category and return the touch to the UIScrollView.
//        [self.nextResponder.nextResponder touchesBegan:touches withEvent:event]; // or 1 nextResponder, depends
//        [super touchesBegan:touches withEvent:event];
//    }
//}
//
//- (void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event
//{
//    NSLog(@"touchesCancelled in scrollview **************");
//    [[self.nextResponder nextResponder]  touchesCancelled: touches withEvent:event];
//    [super touchesCancelled: touches withEvent: event];
//    [self touchesEnded: touches withEvent: event];
//    for (UITouch *touch in touches) {
//        [self.tapGestureRecognizer ignoreTouch: touch forEvent: event];
////        [super ignoreTouch: touch forEvent: event];
//        NSLog (@"CANCELLED TOUCH: %@", touch);
//    }
//}

@end
