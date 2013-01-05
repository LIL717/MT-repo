//
//  DetailThemeController.h
//  PodRadio
//
//  Created by Tope on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"

@interface DetailThemeController : UIViewController

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

@property (nonatomic, strong) Track *track;


@property (nonatomic, weak) IBOutlet UILabel *trackLabel;

@property (nonatomic, weak) IBOutlet UILabel *artistLabel;

@property (nonatomic, weak) IBOutlet UILabel *genreLabel;

@property (nonatomic, weak) IBOutlet UIImageView *albumImageView;

@end
