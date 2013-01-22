//
//  inCellScrollView.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/21/13.
//
//

#import "InCellScrollView.h"

@implementation InCellScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{

    // If not dragging, send event to next responder
    if (!self.dragging) {
            NSLog(@"touch scroll not dragging");
        [self.nextResponder touchesEnded: touches withEvent:event];
    } else {
        [super touchesEnded: touches withEvent: event];
            NSLog(@"touch scroll is dragging");
    }
    if (self.tracking) {
        NSLog(@"scrollView tracking");
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
