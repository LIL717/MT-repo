//
//  AccessibleLabel.m
//  MegaTunes Player
//
//  Created by Lori Hill on 8/2/13.
//
//

#import "AccessibleLabel.h"

@implementation AccessibleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (NSString *)accessibilityHint
{
    NSString *hint = NSLocalizedString(@"Tap to magnify", nil);
    
    return hint;
}

@end
