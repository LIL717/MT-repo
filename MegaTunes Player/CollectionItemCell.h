//
//  CollectionItemCell.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

@interface CollectionItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;


@end
