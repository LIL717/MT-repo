//
//  CollectionItemCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "CollectionItemCell.h"

@implementation CollectionItemCell
@synthesize nameLabel;
@synthesize durationLabel;


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
