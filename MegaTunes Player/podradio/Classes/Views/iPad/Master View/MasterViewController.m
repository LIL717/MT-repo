//
//  MasterViewController.m
//  podradio
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "MasterCell.h"
#import "DataLoader.h"
#import "AppDelegate.h"


@implementation MasterViewController

@synthesize tracksTableView, toolbar, toolbarBottom, tracks, delegate;

#pragma mark - View lifecycle

- (void)viewDidLoad { 
    self.tracks = [DataLoader loadSampleData];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImage* navBg = [appDelegate.colorSwitcher processImageWithName:@"ipad-menubar-left.png"];
    
    [self.navigationController.navigationBar setBackgroundImage:navBg forBarMetrics:UIBarMetricsDefault];
    
    UIImage* toolbarBgBottom = [appDelegate.colorSwitcher processImageWithName:@"ipad-tabbar-left.png"];
    [toolbarBottom setBackgroundImage:toolbarBgBottom forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
        
    tracksTableView.delegate = self;
    tracksTableView.dataSource = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; 
    self.navigationItem.titleView = label;
    
    label.text = @"Albums";
    [label sizeToFit];
    
    UIImage* bgImage = [appDelegate.colorSwitcher processImageWithName:@"ipad-background.png"];
    UIColor* bgColor = [UIColor colorWithPatternImage:bgImage];
    
    [self.view setBackgroundColor:bgColor];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MasterCell"; 
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Track* track = [tracks objectAtIndex:indexPath.row];
    
    [cell.trackLabel setText:track.trackName];
    [cell.artistLabel setText:track.artistName];
    [cell.albumImageView setImage:track.albumImage];
    [cell.trackLengthLabel setText:track.length];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    [cell.trackLabel setTextColor:[appDelegate.colorSwitcher tintColor]];
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Track* track = [tracks objectAtIndex:indexPath.row];
    [delegate loadDataIntoView:track];
    
}

@end
