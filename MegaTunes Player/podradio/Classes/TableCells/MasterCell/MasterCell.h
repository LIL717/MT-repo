//
//  MasterCell.h
//  podradio
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@end
