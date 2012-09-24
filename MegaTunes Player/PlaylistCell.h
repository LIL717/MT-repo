//
//  PlaylistCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import <UIKit/UIKit.h>

@interface PlaylistCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UIImageView
*coverImageView;

@end