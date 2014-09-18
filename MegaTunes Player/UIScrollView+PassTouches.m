//
//  UIScrollView+PassTouches.m
//  MegaTunes Player
//
//  Created by Lori Hill on 4/2/13.
//
//

#import "UIScrollView+PassTouches.h"

UITouch *savedTouch;

@implementation UIScrollView (PassTouches)

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    LogMethod();
    UITouch *touch = [[event allTouches] anyObject];
    savedTouch = touch;

//    NSLog(@"touch BEGAN in view = %@", [[touch view].class description]);
    // If not dragging, send event to next responder

    if (!self.dragging){
//        NSLog (@"not dragging");
        [self.nextResponder touchesBegan: touches withEvent:event];
        [super touchesBegan:touches withEvent:event];

    }
    else{
//        NSLog (@"dragging");
        [super touchesEnded: touches withEvent: event];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    LogMethod();

//    UITouch *touch = [[event allTouches] anyObject];
//
//    NSLog(@"touch MOVED in view = %@", [[touch view].class description]);
    // If not dragging, send event to next responder
    if (!self.dragging){
//        NSLog (@"not dragging");

        [self.nextResponder touchesBegan: touches withEvent:event];
        [super touchesMoved: touches withEvent: event];
        
        [self touchesEnded: touches withEvent: event];

    }
    else{
//        NSLog (@"dragging");

        [super touchesEnded: touches withEvent: event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    LogMethod();

    UITouch *touch = [[event allTouches] anyObject];
    
    if (touch == savedTouch) {
//        [self.nextResponder touchesBegan: touches withEvent:event];
        [self.nextResponder touchesEnded: touches withEvent:event];

        savedTouch = nil;
//        NSLog(@"touch ENDED in view = %@", [[touch view].class description]);
        
    }
    [super touchesEnded: touches withEvent: event];

}

@end
