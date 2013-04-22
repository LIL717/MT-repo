//
//  TapGestureRecognizer.m
//  MegaTunes Player
//
//  Created by Lori Hill on 3/19/13.
//
//

#import "TapGestureRecognizer.h"

@implementation TapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action {
    self  = [super initWithTarget:target action:action];

    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event {
    [super ignoreTouch:touch forEvent:event];
}

-(void)reset {
    [super reset];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return [super canPreventGestureRecognizer:preventedGestureRecognizer];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    NSLog (@"TOUCH MOVED touch in TapGestureRecognizer");

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
        NSLog (@"END IT NOW touch in TapGestureRecognizer");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}
@end