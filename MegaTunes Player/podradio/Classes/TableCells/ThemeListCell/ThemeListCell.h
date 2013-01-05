//
//  ThemeListCell.h
//  PodRadio
//
//  Created by Tope on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;


@end
