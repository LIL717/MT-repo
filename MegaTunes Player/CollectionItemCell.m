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


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        UIFont *font = [UIFont systemFontOfSize:12];
//        UIFont *newFont = [font fontWithSize:44];
//        self.textLabel.font = newFont;
//        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];


    // Configure the view for the selected state
}

@end
