//
//  ShuffleButton.m
//  MegaTunes Player
//
//  Created by Lori Hill on 8/2/13.
//
//

#import "AccessibleButton.h"

@implementation AccessibleButton

@synthesize isSelected;

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


- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits traits = [super accessibilityTraits];
    
    if ( [self isSelected] )
    {
        traits |= UIAccessibilityTraitSelected;
    }
    
    return traits;
}

@end
