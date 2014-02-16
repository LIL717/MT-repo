//
//  SongInfoCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/17/12.
//
//
@class InCellScrollView;

@interface SongInfoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
//130909 1.1 add iTunesStoreButton begin
@property (strong, nonatomic) IBOutlet InCellScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *iTunesStoreButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewToCellConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXAlignmentConstraint;
//130909 1.1 add iTunesStoreButton end


@end
