//
//  UserTagCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//
@class KSLabel;
#import "FMMoveTableViewCell.h"

@interface UserTagCell : UITableViewCell
//@interface UserTagCell : FMMoveTableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) IBOutlet KSLabel *tagLabel;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXAlignmentConstraint;

- (void)prepareForMove;


@end