//
//  UserTagCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import "UserTagCell.h"
#import "KSLabel.h"

@implementation UserTagCell

@synthesize cellBackgroundImageView;
@synthesize tagLabel;
//@synthesize centerXAlignmentConstraint;

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
    self.textLabel.frame = textLabelFrame;
}
- (void)prepareForMove
{
	[[self textLabel] setText:@""];
	[[self detailTextLabel] setText:@""];
	[[self imageView] setImage:nil];
    [self.tagLabel setText: @""];

}
@end