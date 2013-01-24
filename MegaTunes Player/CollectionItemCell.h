//
//  CollectionItemCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class InCellScrollView;

@interface CollectionItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet InCellScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;


@end
