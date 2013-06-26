//
//  UserTagCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//
@class KSLabel;

@interface UserTagCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) IBOutlet KSLabel *tagLabel;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXAlignmentConstraint;

- (void)prepareForMove;


@end