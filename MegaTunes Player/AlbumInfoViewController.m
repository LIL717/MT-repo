//
//  AlbumInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "AlbumInfoViewController.h"
#import "AppDelegate.h"
#import "SongInfoCell.h"
#import "UIImage+AdditionalFunctionalities.h"


@interface AlbumInfoViewController ()

@end

@implementation AlbumInfoViewController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize infoTableView;
@synthesize albumImageView;
@synthesize songInfoData;
@synthesize songName;
@synthesize album;
@synthesize artist;
@synthesize albumImage;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    UIImage *unselectedImage0 = [UIImage imageNamed:@"unselectedTabAlbumButton.png"];
    UIImage *selectedImage0 = [UIImage imageNamed:@"selectedTabAlbumButton.png"];
    
    UIImage *unselectedImage1 = [UIImage imageNamed:@"unselectedTabInfoButton.png"];
    UIImage *selectedImage1 = [UIImage imageNamed:@"selectedTabInfoButton.png"];
    
    UIImage *unselectedImage2 = [UIImage imageNamed:@"unselectedTabCommentsButton.png"];
    UIImage *selectedImage2 = [UIImage imageNamed:@"selectedTabCommentsButton.png"];
    
    UIImage *unselectedImage3 = [UIImage imageNamed:@"unselectedTabUserButton.png"];
    UIImage *selectedImage3 = [UIImage imageNamed:@"selectedTabUserButton.png"];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];

    [self loadArrayForTable];

//    [self registerForMediaPlayerNotifications];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) loadArrayForTable {
    //get the specific info from the
    
    self.songName = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyTitle];
    self.album = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyAlbumTitle];
    self.artist = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [self.mediaItemForInfo valueForProperty:MPMediaItemPropertyArtwork];
    self.albumImage = [artWork imageWithSize:CGSizeMake(200, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 320)];
    if (!self.albumImage) {
        [imageView setImage:[UIImage imageNamed:@"noAlbumImage320.png"]];
    } else {
        [imageView setImage:self.albumImage];
    }
    [self.albumImageView addSubview:imageView];
    
    if (!self.artist) {
        self.artist = @"Unknown";
    }
    if (!self.songName) {
        self.songName = @"Unknown";
    }
    if (!self.album) {
        self.album = @"Unknown";
    }
    
    self.songInfoData = [NSArray arrayWithObjects: self.artist, self.songName, self.album, nil];
}
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
//- (UILabel *) customizeTitleView
//{
//    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    UIFont *font = [UIFont systemFontOfSize:12];
//    UIFont *newFont = [font fontWithSize:44];
//    label.font = newFont;
//    label.textColor = [UIColor yellowColor];
//    label.text = self.title;
//    
//    return label;
//}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

        
    } else {
        NSLog (@"landscape");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

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

//- (void) registerForMediaPlayerNotifications {
//    //    LogMethod();
//    
//	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    
//    [notificationCenter addObserver: self
//						   selector: @selector (handle_NowPlayingItemChanged:)
//							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//							 object: musicPlayer];
//    
//    [musicPlayer beginGeneratingPlaybackNotifications];
//    
//}
//
//// If displaying now-playing item when it changes, update mediaItemForInfo and show info for currently playing song
//- (void) handle_NowPlayingItemChanged: (id) notification {
//    LogMethod();
//    //the rightBarButtonItem is nil when the info is for the currently playing song
//    if (!self.navigationItem.rightBarButtonItem) {
//        self.mediaItemForInfo = [musicPlayer nowPlayingItem];
//        NSLog (@"newTitle is %@", [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]);
//        
////        self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        [self loadArrayForTable];
////        [self.infoTableView reloadData];
////        [self.albumImageView setNeedsDisplay];
//        
////        [self.albumInfoViewController.view setNeedsDisplay];
////        [self.iTunesInfoViewController.view setNeedsDisplay];
////        [self.iTunesCommentsViewController.view setNeedsDisplay];
////        [self.userInfoViewController.view setNeedsDisplay];
//        
//    }
//}
//
//- (void)dealloc {
//    //    LogMethod();
//    [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//												  object: musicPlayer];
//    
//    [musicPlayer endGeneratingPlaybackNotifications];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end