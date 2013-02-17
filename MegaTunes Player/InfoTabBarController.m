//
//  InfoTabBarController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "InfoTabBarController.h"
#import "Appdelegate.h"
#import "MainViewController.h"
#import "SongViewController.h"
#import "AlbumInfoViewController.h"
#import "ITunesInfoViewController.h"
#import "ITunesCommentsViewController.h"
#import "UserInfoViewController.h"


@interface InfoTabBarController ()

@end

@implementation InfoTabBarController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize albumInfoViewController;
@synthesize iTunesInfoViewController;
@synthesize iTunesCommentsViewController;
@synthesize userInfoViewController;
@synthesize infoDelegate;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize viewingNowPlaying;
@synthesize mediaItemForInfo;


- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    //    self.delegate = self;
    
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.albumInfoViewController = [[self viewControllers] objectAtIndex:0];
    self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    
    //    NSLog (@" in NotesTabBar  self.songInfo.songName = %@", self.songInfo.songName);
    //    NSLog (@" in NotesTabBar  self.songInfo.album = %@", self.songInfo.album);
    //    NSLog (@" in NotesTabBar  self.songInfo.artist = %@", self.songInfo.artist);
    //    self.title = @"Info";
    //    self.navigationItem.titleView = [self customizeTitleView];
    //    [self.songInfoViewController.navigationController.navigationItem setTitle:@"Info"];
    
    self.iTunesInfoViewController = [[self viewControllers] objectAtIndex:1];
    self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    self.iTunesInfoViewController.managedObjectContext = self.managedObjectContext;
    
    self.iTunesCommentsViewController = [[self viewControllers] objectAtIndex:2];
    self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
//    self.iTunesCommentsViewController.managedObjectContext = self.managedObjectContext;

    
    self.userInfoViewController = [[self viewControllers] objectAtIndex:3];
    self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    self.userInfoViewController.managedObjectContext = self.managedObjectContext;
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    //    self.title = @"Notes";
    //    self.navigationItem.titleView = [self customizeTitleView];
    //    [self.notesViewController.navigationController.navigationItem setTitle:@"Notes"];
        
}
- (void) viewWillAppear:(BOOL)animated
{
    LogMethod();
    [super viewWillAppear: animated];

//    UIImage* infoImage = [UIImage imageNamed:@"infoLightButtonImage.png"];
//    UIImage* notesImage = [UIImage imageNamed:@"notesLightButtonImage.png"];

//    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
//    [[self.navigationController.viewControllers objectAtIndex:0] setSelectionIndicatorImage:infoImage];
//    [[self.navigationController.viewControllers objectAtIndex:1] setSelectionIndicatorImage:notesImage];

    
//    [[self.navigationController.viewControllers objectAtIndex:1] setTitle:@"Blah"];
//
    self.navigationItem.titleView = [self customizeTitleView];
    
//    NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);

    [self setViewingNowPlaying: NO];
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
//    NSLog (@"playing Item is *%@*, songInfo.SongName is *%@*", playingItem, self.songInfo.songName);
    if (playingItem) {
        //don't display right bar button is playing item is song info item
        if ([playingItem isEqualToString: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]]) {
            [self setViewingNowPlaying: YES];
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            //initWithTitle cannot be nil, must be @""
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                      style:UIBarButtonItemStyleBordered
                                                                                     target:self
                                                                                     action:@selector(viewNowPlaying)];
            
            UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            
            [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        }
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
//    UIImage* emptyImage = [UIImage imageNamed:@"infoLightButtonImage.png"];
//    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
    return;
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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.albumInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        [self.albumInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        [self.iTunesInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        [self.iTunesInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.iTunesInfoViewController.lastPlayedDateTitle = @"Played:";
        self.iTunesInfoViewController.userGroupingTitle = @"Grouping:";
        [self.iTunesInfoViewController loadTableData];
        [self.iTunesInfoViewController.infoTableView reloadData];
        
        [self.iTunesCommentsViewController.comments setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.iTunesCommentsViewController.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

        [self.userInfoViewController.view removeConstraint:self.userInfoViewController.verticalSpaceToTop28];
        [self.userInfoViewController.view addConstraint:self.userInfoViewController.verticalSpaceToTop];

    } else {
        NSLog (@"landscape");
        [self.albumInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.albumInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        [self.iTunesInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.iTunesInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.iTunesInfoViewController.lastPlayedDateTitle = @"Last Played:";
        self.iTunesInfoViewController.userGroupingTitle = @"iTunes Grouping:";
        [self.iTunesInfoViewController loadTableData];
        [self.iTunesInfoViewController.infoTableView reloadData];
        
        [self.iTunesCommentsViewController.comments setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.iTunesCommentsViewController.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        // Set top row spacing to superview top

        [self.userInfoViewController.view removeConstraint:self.userInfoViewController.verticalSpaceToTop];
        
        self.userInfoViewController.verticalSpaceToTop28 =
        [NSLayoutConstraint constraintWithItem:self.userInfoViewController.userGrouping
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.userInfoViewController.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:28];
        [self.userInfoViewController.view addConstraint: self.userInfoViewController.verticalSpaceToTop28];
    }
}
//#pragma mark UITabBarController Delegate Method
//this works to "flip" horizontally between views, but there is a little jump on the 2nd screen, probably because the views are not the same size,  need to put the smaller one in a container view?
//
//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    NSArray *tabViewControllers = tabBarController.viewControllers;
//    UIView * fromView = tabBarController.selectedViewController.view;
//    UIView * toView = viewController.view;
//
//    if (fromView != toView) {
//
//        NSUInteger fromIndex = [tabViewControllers indexOfObject:tabBarController.selectedViewController];
//        NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
//        
//        [UIView transitionFromView:fromView
//                            toView:toView
//                          duration:0.5
//                           options: toIndex > fromIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
////                           options: toIndex > fromIndex ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown
//                        completion:^(BOOL finished) {
//                            if (finished) {
//                                tabBarController.selectedIndex = toIndex;
//                            }
//                        }];
//
//    }
//
//    return NO;
//
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();

    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        mainViewController.playNew = NO;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;
//        if (iPodLibraryChanged) {
//            mainViewController.iPodLibraryChanged = YES;
//        }
    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];

}

- (void)goBackClick
{
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
        if (playbackState == MPMusicPlaybackStateStopped) {
            //pop back to songviewcontroller
            NSArray *array = [self.navigationController viewControllers];
            [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
            [self.infoDelegate infoTabBarControllerDidCancel:self];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            [self.infoDelegate infoTabBarControllerDidCancel:self];
        }
    }
}

- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}
// If displaying now-playing item when it changes, update mediaItemForInfo and show info for currently playing song
- (void) handle_NowPlayingItemChanged: (id) notification {
    LogMethod();
    if (self.viewingNowPlaying) {
        //if the user is in the middle of editing we won't change the mediaItem (until they return to previous view)
        if (!self.userInfoViewController.editingUserInfo) {
            self.mediaItemForInfo = [musicPlayer nowPlayingItem];
            
            self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.albumInfoViewController loadArrayForTable];
            [self.albumInfoViewController.infoTableView reloadData];
            [self.albumInfoViewController.albumImageView setNeedsDisplay];
            
            self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.iTunesInfoViewController loadTableData];
            [self.iTunesInfoViewController.infoTableView reloadData];
            
            self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.iTunesCommentsViewController loadDataForView];
            [self.iTunesCommentsViewController.comments setNeedsDisplay];
            
            self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.userInfoViewController loadDataForView];
            [self.userInfoViewController.userGrouping setNeedsDisplay];
            [self.userInfoViewController.comments setNeedsDisplay];
            
            self.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
            self.navigationItem.titleView = [self customizeTitleView];
        }
        
    }
}
- (void) handle_iPodLibraryChanged: (id) changeNotification {
    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}
// When the playback state changes, if stopped remove nowplaying button
- (void) handle_PlaybackStateChanged: (id) notification {
    LogMethod();
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    if (playbackState == MPMusicPlaybackStateStopped) {
        self.navigationItem.rightBarButtonItem= nil;
	}
    
}

- (void)dealloc {
    //    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end