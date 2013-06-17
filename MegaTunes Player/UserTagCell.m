//
//  UserTagCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import "UserTagCell.h"

@implementation UserTagCell

@synthesize cellBackgroundImageView;
@synthesize tagLabel;
//@synthesize centerXAlignmentConstraint;
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
- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x += self.xOffset;
    textLabelFrame.size.width -= self.xOffset;
    self.textLabel.frame = textLabelFrame;
}
@end