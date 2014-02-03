//
//  MediaGroupCell.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroupCell.h"

@implementation MediaGroupCell

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
        
        //        self.nameLabel.highlightedTextColor = [UIColor blueColor];
        
        CGRect frame = CGRectMake(0, 53, self.frame.size.width, 1);
        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor whiteColor];
        [self.backgroundView addSubview: separatorLine];
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
    }
}
@end
