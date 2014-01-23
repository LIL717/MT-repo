//
//  InCellScrollView.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/21/13.
//
//

#import "InCellScrollView.h"


@implementation InCellScrollView

//UIEvent *touchEvent;
//131216 1.2 iOS 7 begin
//@synthesize scrollViewImageView;
//131216 1.2 iOS 7 end

UITouch *savedTouch;

- (void) awakeFromNib {
    //this must be NO to enable tables to scrollToTop with tap of status bar
    self.scrollsToTop = NO;

}

#pragma mark - UIScrollView delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    LogMethod();
    NSLog(@"scrolling ended");
    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:touchEvent forKey:@"touchKey"];
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"CellScrolled" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CellScrolled" object:nil];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *result = [super hitTest:point withEvent:event];
//
//    touchEvent = event;
//
//    return result;
//}
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
