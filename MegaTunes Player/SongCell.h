//
//  PlaylistCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

@interface SongCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
//@property (strong, nonatomic) IBOutlet UILabel *BPM;
@property (strong, nonatomic) IBOutlet UIImageView *playingIndicator;

//@property (nonatomic, strong) IBOutlet UIImageView *artworkImageView;


@end