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
@synthesize cellBackgroundImageView;

@synthesize infoBackground;
//@synthesize BPM;
@synthesize scrollViewToCellConstraint;
@synthesize centerXAlignmentConstraint;
//@synthesize centerYAlignmentConstraint;
@synthesize xOffset;



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
        NSLog(@"setSelected:YES");
//        self.selectionStyle = UITableViewCellSelectionStyleGray;

        [self.cellBackgroundImageView  setImage: [UIImage imageNamed: @"list-background.png"]];
//        self.nameLabel.highlightedTextColor = [UIColor blueColor];

        CGRect frame = CGRectMake(0, 53, self.frame.size.width, 1);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
        [self.cellBackgroundImageView addSubview: separatorLine];

        [self.scrollView.scrollViewImageView  setImage: [UIImage imageNamed: @"list-background.png"]];
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
    }
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x += self.xOffset;
    textLabelFrame.size.width -= self.xOffset;
    self.textLabel.frame = textLabelFrame;
}
@end
