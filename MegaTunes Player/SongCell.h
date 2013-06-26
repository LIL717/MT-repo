//
//  PlaylistCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class InCellScrollView;

@interface SongCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *playingIndicator;
@property (strong, nonatomic) IBOutlet InCellScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
//@property (strong, nonatomic) IBOutlet UILabel *BPM;
@property (strong, nonatomic) IBOutlet UIView *infoBackground;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewToCellConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXAlignmentConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerYAlignmentConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *durationToCellConstraint;
@property (nonatomic) CGFloat textLabelOffset;
@property (nonatomic) CGFloat cellOffset;



@end