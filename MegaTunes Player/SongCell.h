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
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
//@property (strong, nonatomic) IBOutlet UILabel *BPM;
@property (strong, nonatomic) IBOutlet UIView *infoBackground;



@end