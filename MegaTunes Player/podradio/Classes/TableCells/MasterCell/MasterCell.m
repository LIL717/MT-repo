//
//  MasterCell.m
//  podradio
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterCell.h"

@implementation MasterCell

@synthesize trackLabel, artistLabel, albumImageView, trackLengthLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
       
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
