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

@end
