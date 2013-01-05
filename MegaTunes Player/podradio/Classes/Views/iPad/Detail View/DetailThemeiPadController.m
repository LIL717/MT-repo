//
//  DetailThemeiPadController.m
//  podradio
//
//  Created by Tope on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailThemeiPadController.h"
#import "AppDelegate.h"

@implementation DetailThemeiPadController {
    UIPopoverController *masterPopoverController;
}

@synthesize toolbar, toolbarBottom, trackLabel, artistLabel, genreLabel, albumImageView, bgImageView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIImage* navBg = [appDelegate.colorSwitcher processImageWithName:@"ipad-menubar-right.png"];
    [self.navigationController.navigationBar setBackgroundImage:[navBg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    
    UIImage* bottomToolBarBg = [appDelegate.colorSwitcher processImageWithName:@"ipad-tabbar-right.png"];
    
    [toolbarBottom setBackgroundImage:bottomToolBarBg forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    [bgImageView setImage:[appDelegate.colorSwitcher processImageWithName:@"ipad-background.png"]];
    
    [genreLabel setTextColor:[appDelegate.colorSwitcher tintColor]];
    
    [super viewDidLoad];
}


-(void)loadDataIntoView:(Track*)track {
    [artistLabel setText:track.artistName];
    [trackLabel setText:track.trackName];
    [genreLabel setText:track.genre];
    [albumImageView setImage:track.albumImageLarge];
    if (masterPopoverController) {
        [masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark - UISplitView delegate

- (void)splitViewController: (UISplitViewController *)splitViewController
     willHideViewController:(UIViewController *)viewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController: (UIPopoverController *)popoverController
{
    barButtonItem.title = @"Master";
    NSMutableArray *items = [self.navigationItem.rightBarButtonItems mutableCopy];
    if (!items) {
        items = [NSMutableArray array];
    }
    [items insertObject:barButtonItem atIndex:0];
    self.navigationItem.leftBarButtonItems = items;
    masterPopoverController = popoverController;
}


- (void)splitViewController:(UISplitViewController *)splitController 
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [self.navigationItem.rightBarButtonItems mutableCopy]; 
    [items removeObject:barButtonItem];
    self.navigationItem.leftBarButtonItems = items;
    masterPopoverController = nil;
}

@end
