//
//  CustomSongCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/22/13.
//
//

#import "CustomSongCell.h"

@implementation CustomSongCell

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
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    NSLog(@"touch cell");
    [super touchesEnded: touches withEvent: event];
}
@end
