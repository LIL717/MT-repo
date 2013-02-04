//
//  SongInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "SongInfoViewController.h"
#import "AppDelegate.h"
#import "SongInfo.h"
#import "SongInfoCell.h"
#import "UIImage+AdditionalFunctionalities.h"


@interface SongInfoViewController ()

@end

@implementation SongInfoViewController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize songInfo;

@synthesize infoTableView;
@synthesize albumImageView;
@synthesize songInfoData;
//@synthesize navItem;

- (void) viewWillAppear:(BOOL)animated
{
    LogMethod();
    [super viewWillAppear: animated];

//    if (self.tabBarController.selectedIndex = 0) {
//        self.title = @"Info";
////        self.navigationItem.titleView = [self customizeTitleView];
//    self.navItem.titleView = [self customizeTitleView];
//
//        NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
//    } else {
//        self.title = @"Notes";
//        self.navigationItem.titleView = [self customizeTitleView];
//        NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
//    }
}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
//    UIImage* emptyImage = [UIImage imageNamed:@"infoLightButtonImage.png"];
//    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];

	// Do any additional setup after loading the view, typically from a nib.

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 320)];
    if (!self.songInfo.albumImage) {
        [imageView setImage:[UIImage imageNamed:@"noAlbumImage320.png"]];
    } else {
        [imageView setImage:self.songInfo.albumImage];
    }
    [self.albumImageView addSubview:imageView];
    
//    NSLog (@" in SongInfo  self.songInfo.songName = %@", self.songInfo.songName);
//    NSLog (@" in SongInfo  self.songInfo.album = %@", self.songInfo.album);
//    NSLog (@" in SongInfo  self.songInfo.artist = %@", self.songInfo.artist);
    
    if (!self.songInfo.artist) {
        self.songInfo.artist = @"Unknown";
    }
    if (!self.songInfo.songName) {
        self.songInfo.songName = @"Unknown";
    }
    if (!self.songInfo.album) {
        self.songInfo.album = @"Unknown";
    }
    
    self.songInfoData = [NSArray arrayWithObjects: self.songInfo.artist, self.songInfo.songName, self.songInfo.album, nil];
    
    UIImage *unselectedImage0 = [UIImage imageNamed:@"unselectedTabInfoButton.png"];
    UIImage *selectedImage0 = [UIImage imageNamed:@"selectedTabInfoButton.png"];
    
//    UIImage *unselectedImage1 = [UIImage imageNamed:@"notesLightButtonImageWhite.png"];
//    UIImage *unselectedImage1 = [UIImage imageNamed:@"tabButtonBlack.png"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"unselectedTabNotesButton.png"];
    UIImage *selectedImage1 = [UIImage imageNamed:@"selectedTabNotes2Button.png"];

//    UIImage *selectedImage1 = [unselectedImage1 imageWithTint:[UIColor blueColor]];

    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];

    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//        self.infoTableView.contentSize = CGSizeMake(self.infoTableView.frame.size.width, 55 + 55 + 55 + 320);

        
    } else {
        NSLog (@"landscape");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//        self.infoTableView.contentSize = CGSizeMake(self.infoTableView.frame.size.width, 55 + 55 + 55 + 320);

    }
}

#pragma mark Table view methods________________________
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
//    NSLog (@"self.songInfoData count is %d", [self.songInfoData count]);
    return [self.songInfoData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    SongInfoCell *cell = (SongInfoCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"SongInfoCell"];
        
    cell.nameLabel.text = [self.songInfoData objectAtIndex:indexPath.row];
//    NSLog (@"cell.nameLabel.frame.size.width is %f", CGRectGetWidth(cell.scrollView.bounds));


    //calculate the label size to fit the text with the font size
    //    NSLog (@"size of nextSongLabel is %f", self.nextSongLabel.frame.size.width);
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                           constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(cell.nameLabel.bounds))
                                               lineBreakMode:NSLineBreakByClipping];
    
    //build a new label that will hold all the text
    UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
    CGRect frame = newLabel.frame;
    frame.size.height = CGRectGetHeight(cell.nameLabel.bounds);
    frame.size.width = labelSize.width + 1;
    newLabel.frame = frame;
    
//    NSLog (@"size of newLabel is %f", frame.size.width);

    //calculate the size (w x h) for the scrollview content
    CGSize size;
    size.width = CGRectGetWidth(newLabel.bounds);
    size.height = CGRectGetHeight(newLabel.bounds);
    cell.scrollView.contentSize = size;
    cell.scrollView.contentOffset = CGPointZero;
    
    //set the UIOutlet label's frame to the new sized frame
    cell.nameLabel.frame = newLabel.frame;
    
//    NSLog (@"cell.scrollView.contentSize.width is %f", cell.scrollView.contentSize.width);
//    NSLog (@"cell.scrollView.frame.size.width is %f", cell.scrollView.frame.size.width);
    //enable scroll if the content will not fit within the scrollView
    if (cell.scrollView.contentSize.width>cell.scrollView.frame.size.width) {
        cell.scrollView.scrollEnabled = YES;
//        NSLog (@"scrollEnabled");
    }
    else {
        cell.scrollView.scrollEnabled = NO;
//        NSLog (@"scrollDisabled");
        
    }
    
    if (indexPath.row == 1) {
        cell.nameLabel.font = [UIFont boldSystemFontOfSize: 44];
        
    }
    return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [self setInfoTableView:nil];

    [super viewDidUnload];
}
@end
