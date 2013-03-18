//
//  PlaylistCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "SongCell.h"

@implementation SongCell

@synthesize playingIndicator;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize durationLabel;
@synthesize infoBackground;
//@synthesize BPM;
@synthesize scrollViewToCellConstraint;
@synthesize centerXAlignmentConstraint;



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
//- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
//{
//    NSLog(@"touch cell");
//    [super touchesEnded: touches withEvent: event];
//}
@end
