//
//  DetailThemeiPadController.h
//  podradio
//
//  Created by Tope on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"

@interface DetailThemeiPadController : UIViewController<UIPopoverControllerDelegate, MasterViewControllerDelegate>


@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, weak) IBOutlet UIToolbar *toolbarBottom;

@property (nonatomic, weak) IBOutlet UILabel *trackLabel;

@property (nonatomic, weak) IBOutlet UILabel *artistLabel;

@property (nonatomic, weak) IBOutlet UILabel *genreLabel;

@property (nonatomic, weak) IBOutlet UIImageView *albumImageView;

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

-(void)loadDataIntoView:(Track*)track;
@end
