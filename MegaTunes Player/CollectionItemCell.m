//
//  CollectionItemCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "CollectionItemCell.h"

@implementation CollectionItemCell
//@synthesize scrollView; 
@synthesize nameLabel;
@synthesize durationLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        NSLog (@"self.scrollView.frame.size.width in CollectionItemCell is %f", self.scrollView.frame.size.width);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];


    // Configure the view for the selected state
}

@end
