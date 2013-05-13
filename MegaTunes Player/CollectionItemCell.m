//
//  CollectionItemCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "CollectionItemCell.h"

@implementation CollectionItemCell
@synthesize scrollView; 
@synthesize nameLabel;
@synthesize durationLabel;
@synthesize scrollViewToCellConstraint;
@synthesize centerXInScrollView;

CGFloat inset = -10;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];


    // Configure the view for the selected state
}
//- (void)setFrame:(CGRect)frame {
//    frame.origin.x += inset;
//    frame.size.width -= 2 * inset;
//    [super setFrame:frame];
//    
//}
//- (void) layoutSubviews {
//    [super layoutSubviews];
//    
//    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
//
//    UILabel *newLabel = [[UILabel alloc] initWithFrame: self.textLabel.frame];
//    CGRect myFrame = newLabel.frame;
//    
//    if (isPortrait) {
//        myFrame.size.width -= 2 * inset;
//        self.textLabel.frame = myFrame;
//
//    } else {
//        myFrame.size.width -= 116;
//        self.textLabel.frame = myFrame;
//    }
//    self.textLabel.font = [UIFont systemFontOfSize:44];
//    self.textLabel.textColor = [UIColor whiteColor];
//    self.textLabel.highlightedTextColor = [UIColor blueColor];
//    self.textLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"list-backwseparator.png"]];
//    self.textLabel.lineBreakMode = NSLineBreakByClipping;
//
//}
@end
