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

//CGFloat inset = -10;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.nameLabel.textColor = [UIColor blueColor];
        self.durationLabel.textColor = [UIColor blueColor];
//        NSLog(@"setSelected:YES");
        //        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //        self.nameLabel.highlightedTextColor = [UIColor blueColor];
        
//        CGRect frame = CGRectMake(0, 53, self.frame.size.width, 1);
//        UIView *separatorLine = [[UILabel alloc] initWithFrame:frame];
//        separatorLine.backgroundColor = [UIColor whiteColor];
//        [self.backgroundView addSubview: separatorLine];
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
        self.durationLabel.textColor = [UIColor whiteColor];
    }
}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//
//    // Configure the view for the selected state
//}
//- (void)setFrame:(CGRect)frame {
//    frame.origin.x += inset;
//    frame.size.width -= 2 * inset;
//    [super setFrame:frame];
//    
//}
//- (void) layoutSubviews {
//    [super layoutSubviews];
//    //move the accessory cell over to the right 15 pixels because the grouped cells have too much trailing space
//    if (self.accessoryType != UITableViewCellAccessoryNone) {
//        UIView* defaultAccessoryView = [self.subviews lastObject];
//        
//        if (defaultAccessoryView){
//            CGRect r = defaultAccessoryView.frame;
//            r.origin.x += 15;
//            defaultAccessoryView.frame = r;
//        }
//    }
//
//}
@end
