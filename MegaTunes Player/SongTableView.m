//
//  SongTableView.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/25/13.
//
//

#import "SongTableView.h"

@implementation SongTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog (@"touch is %@" ,touch);
    
    //resignFirstResponder for the UITextView
    
    //call didSelectRow of tableView again, by passing the touch to the super class
    [super touchesBegan:touches withEvent:event];
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
