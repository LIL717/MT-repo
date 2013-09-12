//
//  SongInfoCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/17/12.
//
//

#import "SongInfoCell.h"

@implementation SongInfoCell
//130909 1.1 add iTunesStoreButton begin
@synthesize scrollView;
@synthesize nameLabel;
@synthesize iTunesStoreButton;
@synthesize scrollViewToCellConstraint;
@synthesize centerXAlignmentConstraint;
//130909 1.1 add iTunesStoreButton end


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

@end
