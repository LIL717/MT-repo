//
//  PlaylistCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "SongCell.h"
#import "InCellScrollView.h"

@implementation SongCell

@synthesize playingIndicator;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize durationLabel;
//140122 1.2 iOS 7 begin
//@synthesize cellBackgroundImageView;
//140122 1.2 iOS 7 end

@synthesize infoBackground;
//@synthesize BPM;
@synthesize scrollViewToCellConstraint;
@synthesize centerXAlignmentConstraint;
@synthesize centerYAlignmentConstraint;
@synthesize durationToCellConstraint;
@synthesize textLabelOffset;
//140116 1.2 iOS 7 begin
//@synthesize cellOffset;
//140116 1.2 iOS 7 end



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
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.nameLabel.textColor = [UIColor blueColor];
        self.durationLabel.textColor = [UIColor blueColor];
//        NSLog(@"setSelected:YES");
//        self.selectionStyle = UITableViewCellSelectionStyleGray;

//        self.nameLabel.highlightedTextColor = [UIColor blueColor];

        CGRect frame = CGRectMake(0, 53, self.frame.size.width, 1);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
        [self.backgroundView addSubview: separatorLine];
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
        self.durationLabel.textColor = [UIColor whiteColor];
    }
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x += self.textLabelOffset;
    textLabelFrame.size.width -= self.textLabelOffset;
    self.textLabel.frame = textLabelFrame;
    
//    CGRect cellFrame = self.frame;
//    cellFrame.size.width += self.xOffset;
//    self.frame = cellFrame;
}
//140116 1.2 iOS 7 begin
//- (void)setFrame:(CGRect)frame {
//    
//    //do this to make cell the same width as ungrouped table cell - otherwise wastes space on right)
//    //resource intensive!!
//    frame.size.width += self.cellOffset;
//    [super setFrame:frame];
//}
//140116 1.2 iOS 7 end

@end
