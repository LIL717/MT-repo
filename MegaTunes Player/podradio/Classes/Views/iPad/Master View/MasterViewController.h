//
//  MasterViewController.h
//  podradio
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"

@protocol MasterViewControllerDelegate;

@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tracksTableView;

@property (nonatomic, weak) IBOutlet UIToolbar* toolbar;

@property (nonatomic, weak) IBOutlet UIToolbar* toolbarBottom;

@property (nonatomic, strong) NSArray* tracks;

@property (nonatomic, assign) id<MasterViewControllerDelegate> delegate;

@end


@protocol MasterViewControllerDelegate <NSObject>

-(void)loadDataIntoView:(Track*)track;

@end