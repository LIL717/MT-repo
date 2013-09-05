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
#import "TaggedSongViewController.h"
#import "AlbumInfoViewController.h"
//#import "ITunesInfoViewController.h"
#import "ITunesCommentsViewController.h"
#import "UserInfoViewController.h"


@interface InfoTabBarController ()

@end

@implementation InfoTabBarController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize musicPlayer;
@synthesize albumInfoViewController;
//@synthesize iTunesInfoViewController;
@synthesize iTunesCommentsViewController;
@synthesize userInfoViewController;
@synthesize infoDelegate;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize viewingNowPlaying;
@synthesize mediaItemForInfo;
@synthesize playBarButton;
@synthesize checkMarkButton;

@synthesize showPlayButton;
@synthesize rightBarButton;

@synthesize playbackTimer;
@synthesize showTimeLabels;
@synthesize swipeLeftRight;

@synthesize elapsedTimeButton;
@synthesize remainingTimeButton;
@synthesize saveTitle;
@synthesize mainViewIsSender;

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    //    LogMethod();
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
    
    [self.navigationItem.leftBarButtonItem setIsAccessibilityElement:YES];
    [self.navigationItem.leftBarButtonItem setAccessibilityLabel: NSLocalizedString(@"Back", nil)];
    [self.navigationItem.leftBarButtonItem setAccessibilityTraits: UIAccessibilityTraitButton];
    
    self.playBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(viewNowPlaying)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.playBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.playBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [self.playBarButton setIsAccessibilityElement:YES];
    [self.playBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.playBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    self.checkMarkButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(saveTextViewData)];
    
    menuBarImageDefault = [[UIImage imageNamed:@"checkMark57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    menuBarImageLandscape = [[UIImage imageNamed:@"checkMark68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.checkMarkButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.checkMarkButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [self.checkMarkButton setIsAccessibilityElement:YES];
    [self.checkMarkButton setAccessibilityLabel: NSLocalizedString(@"Done", nil)];
    [self.checkMarkButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    self.elapsedTimeButton = [[UIBarButtonItem alloc] initWithTitle: @"0:00"
                                                              style: UIBarButtonItemStyleBordered
                                                             target: self
                                                             action: nil];
    [self.elapsedTimeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:44], UITextAttributeFont,nil] forState:UIControlStateNormal];
    [self.elapsedTimeButton setBackgroundImage:[UIImage imageNamed:@"rightButtonBackground.png"] forState: UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    const CGFloat TextOffset = 10.0f;
    [self.elapsedTimeButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 5.0f) forBarMetrics: UIBarMetricsDefault];
    [self.elapsedTimeButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 9.0f) forBarMetrics: UIBarMetricsLandscapePhone];
    
    self.remainingTimeButton = [[UIBarButtonItem alloc] initWithTitle: @"-0:00"
                                                                style: UIBarButtonItemStyleBordered
                                                               target: self
                                                               action: nil];
    [self.remainingTimeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:44], UITextAttributeFont,nil] forState:UIControlStateNormal];
    [self.remainingTimeButton setBackgroundImage:[UIImage imageNamed:@"rightButtonBackground.png"] forState: UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.remainingTimeButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 5.0f) forBarMetrics: UIBarMetricsDefault];
    [self.remainingTimeButton setTitlePositionAdjustment: UIOffsetMake(TextOffset, 9.0f) forBarMetrics: UIBarMetricsLandscapePhone];
    
    self.saveTitle = self.title;
    
    self.albumInfoViewController = [[self viewControllers] objectAtIndex:0];
    self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    
    //    NSLog (@" in NotesTabBar  self.songInfo.songName = %@", self.songInfo.songName);
    //    NSLog (@" in NotesTabBar  self.songInfo.album = %@", self.songInfo.album);
    //    NSLog (@" in NotesTabBar  self.songInfo.artist = %@", self.songInfo.artist);
    //    self.title = @"Info";
    //    self.navigationItem.titleView = [self customizeTitleView];
    //    [self.songInfoViewController.navigationController.navigationItem setTitle:@"Info"];
    
    //    self.iTunesInfoViewController = [[self viewControllers] objectAtIndex:1];
    //    self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    //    self.iTunesInfoViewController.managedObjectContext = self.managedObjectContext;
    
    self.iTunesCommentsViewController = [[self viewControllers] objectAtIndex:1];
    self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
    //    self.iTunesCommentsViewController.managedObjectContext = self.managedObjectContext;
    
    
    self.userInfoViewController = [[self viewControllers] objectAtIndex:2];
    self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    self.userInfoViewController.managedObjectContext = self.managedObjectContext;
    
    self.showTimeLabels = NO;
    self.showTimeLabels = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTimeLabels"];
    
    self.swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTimeLabelsAndTitle:)];
    [self.swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    
    [self setViewingNowPlaying: NO];
    [self setShowPlayButton: YES];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    //    NSLog (@"playing Item is *%@*, songInfo.SongName is *%@*", playingItem, self.songInfo.songName);
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    //if the player is stopped (but we are still here because of editing, set playingItem to nil so nowPlaying button won't show)
    
    if (playbackState == MPMusicPlaybackStateStopped) {
        playingItem = nil;
        [self setShowPlayButton: NO];
        
    }
    if (playingItem) {
        //don't display right bar button if playing item is song info item
        if ([playingItem isEqualToString: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]]) {
            [self setViewingNowPlaying: YES];
            [self setShowPlayButton: NO];
            if (mainViewIsSender) {
                [self.navigationController.navigationBar addGestureRecognizer:self.swipeLeftRight];
            } else {
                self.showTimeLabels = NO;
            }
            
        }
    }
    
    [self registerForMediaPlayerNotifications];
    
    //    self.title = @"Notes";
    //    self.navigationItem.titleView = [self customizeTitleView];
    //    [self.notesViewController.navigationController.navigationItem setTitle:@"Notes"];
    
}
- (void) updateTime {
    MainViewController *mainViewController =( MainViewController *) self.infoDelegate;
    
    [mainViewController updateTime];
    
    self.elapsedTimeButton.title = mainViewController.elapsedTimeLabel.text;
    self.remainingTimeButton.title = mainViewController.remainingTimeLabel.text;
    
    [self buildRightNavBarArray];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];
    if (self.viewingNowPlaying && self.mainViewIsSender) {
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateTime)
                                                            userInfo:nil
                                                             repeats:YES];
    }
    //    self.navigationItem.titleView = [self customizeTitleView];
    
    [self buildRightNavBarArray];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    
    //    NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
    //
    //    if (playingItem) {
    //        //don't display right bar button if playing item is song info item
    //        if ([playingItem isEqualToString: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]]) {
    //            [self setViewingNowPlaying: YES];
    //            self.navigationItem.rightBarButtonItem = nil;
    //        } else {
    //            //initWithTitle cannot be nil, must be @""
    //            self.navigationItem.rightBarButtonItem = self.rightBarButton;
    //        }
    //    } else {
    //        self.navigationItem.rightBarButtonItem= nil;
    //    }
    
    return;
}
-(void) buildRightNavBarArray {
    
    //    [self setViewingNowPlaying: NO];
    //    [self setShowPlayButton: YES];
    //
    //    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    //    //    NSLog (@"playing Item is *%@*, songInfo.SongName is *%@*", playingItem, self.songInfo.songName);
    //
    //	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    //
    //    //if the player is stopped (but we are still here because of editing, set playingItem to nil so nowPlaying button won't show)
    //
    //    if (playbackState == MPMusicPlaybackStateStopped) {
    //        playingItem = nil;
    //        [self setShowPlayButton: NO];
    //
    //    }
    //    if (playingItem) {
    //        //don't display right bar button if playing item is song info item
    //        if ([playingItem isEqualToString: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]]) {
    //            [self setViewingNowPlaying: YES];
    //            [self setShowPlayButton: NO];
    //
    //        }
    //    }
    self.title = self.saveTitle;
    self.navigationItem.titleView = [self customizeTitleView];
    
    if (self.userInfoViewController.showCheckMarkButton) {
        //initWithTitle cannot be nil, must be @""
        //        self.navigationItem.rightBarButtonItem = self.playBarButton;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.checkMarkButton, nil] animated: YES];
        //        self.title = nil;
    } else if (showPlayButton) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.playBarButton, nil] animated: YES];
        //        self.title = NSLocalizedString(self.songViewTitle, nil);
    } else {
        if (showTimeLabels) {
            self.saveTitle = self.title;
            self.title = nil;
            self.navigationItem.titleView = nil;
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.remainingTimeButton, self.elapsedTimeButton, nil] animated: YES];
        } else {
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nil] animated: YES];
            //                    self.title = self.saveTitle;
            //                    self.navigationItem.titleView = [self customizeTitleView];
            
        }
        //                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nil] animated: YES];
        //        self.title = nil;
        //        self.title = NSLocalizedString(self.songViewTitle, nil);
    }
}

-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UIFont *newFont = [UIFont systemFontOfSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //executes the method in the individual view on initial load and the one here after that, so they need to stay in synch with each other and with the constaints set in interface builder
    CGFloat commentsHeight = self.albumInfoViewController.comments.frame.size.height;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        //        NSLog (@"portrait");
        [self.albumInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(11,0,commentsHeight,0)];
        [self.albumInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.albumInfoViewController.lastPlayedDateTitle = @"Played:";
        self.albumInfoViewController.userGroupingTitle = @"Grouping:";
        [self.albumInfoViewController loadTableData];
        [self.albumInfoViewController.infoTableView reloadData];
        
        //        [self.iTunesInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        //        [self.iTunesInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        //        self.iTunesInfoViewController.lastPlayedDateTitle = @"Played:";
        //        self.iTunesInfoViewController.userGroupingTitle = @"Grouping:";
        //        [self.iTunesInfoViewController loadTableData];
        //        [self.iTunesInfoViewController.infoTableView reloadData];
        
        [self.iTunesCommentsViewController.comments setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.iTunesCommentsViewController.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        //        [self.userInfoViewController.view removeConstraint:self.userInfoViewController.verticalSpaceToTop28];
        //        [self.userInfoViewController.view addConstraint:self.userInfoViewController.verticalSpaceToTop];
        self.userInfoViewController.verticalSpaceTopToTableViewConstraint.constant = 11;
        self.userInfoViewController.verticalSpaceTopToCommentsConstraint.constant = 66;
        //don't reload the userInfoData if it is being edited
        if (!userInfoViewController.editingUserInfo) {
            [self.userInfoViewController loadDataForView];
        }
        [self.userInfoViewController.userInfoTagTable reloadData];
        
        
    } else {
        //        NSLog (@"landscape");
        [self.albumInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(23,0,commentsHeight,0)];
        [self.albumInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.albumInfoViewController.lastPlayedDateTitle = @"Last Played:";
        self.albumInfoViewController.userGroupingTitle = @"iTunes Grouping:";
        [self.albumInfoViewController loadTableData];
        [self.albumInfoViewController.infoTableView reloadData];
        
        //        [self.iTunesInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        //        [self.iTunesInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        //        self.iTunesInfoViewController.lastPlayedDateTitle = @"Last Played:";
        //        self.iTunesInfoViewController.userGroupingTitle = @"iTunes Grouping:";
        //        [self.iTunesInfoViewController loadTableData];
        //        [self.iTunesInfoViewController.infoTableView reloadData];
        
        [self.iTunesCommentsViewController.comments setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.iTunesCommentsViewController.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        // Set top row spacing to superview top
        self.userInfoViewController.verticalSpaceTopToTableViewConstraint.constant = 23;
        self.userInfoViewController.verticalSpaceTopToCommentsConstraint.constant = 78;
        //don't reload the userInfoData if it is being edited
        if (!userInfoViewController.editingUserInfo) {
            [self.userInfoViewController loadDataForView];
        }
        [self.userInfoViewController.userInfoTagTable reloadData];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
    
}
- (void) saveTextViewData {
    
    [self.userInfoViewController.comments resignFirstResponder];
    
}
- (void)goBackClick
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
    
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
        NSLog (@" playbackState is %d", playbackState);
        if (playbackState == MPMusicPlaybackStateStopped) {
            //pop back to songviewcontroller
            
            UIViewController *popToVC = [[UIViewController alloc] init];
            
            for (UIViewController*vc in [self.navigationController viewControllers]) {
                if ([vc isKindOfClass: [SongViewController class]]){
                    popToVC = vc;
                }
                if ([vc isKindOfClass: [TaggedSongViewController class]]){
                    popToVC = vc;
                }
            }
            
            [self.navigationController popToViewController: popToVC animated:YES];
            [self.infoDelegate infoTabBarControllerDidCancel:self];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            [self.infoDelegate infoTabBarControllerDidCancel:self];
        }
    }
}

- (IBAction) toggleTimeLabelsAndTitle:(id)sender {
    
    BOOL userIsEditing = [[NSUserDefaults standardUserDefaults] boolForKey:@"userIsEditing"];
    
    if (showTimeLabels) {
        self.showTimeLabels = NO;
        [self buildRightNavBarArray];
        //title will only be displayed if tag Button is not
        //        self.title = NSLocalizedString(self.songViewTitle, nil);
        [UIView animateWithDuration:2.5 animations:^{
            //            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.titleView = [self customizeTitleView];
        }];
        NSLog (@"show Title ");
    } else {
        if (!userIsEditing) {
            self.showTimeLabels = YES;
            [self buildRightNavBarArray];
            [UIView animateWithDuration:0.25 animations:^{
                //            self.title = nil;
                self.navigationItem.titleView = nil;
            }];
            NSLog (@"show Time Labels");
        }
        
    }
    //showPlaylistRemaining must persist so save to NSUserDefaults
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.showTimeLabels forKey:@"showTimeLabels"];
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
    
    [notificationCenter addObserver:self
                           selector:@selector(buildRightNavBarArray)
                               name:UIKeyboardDidShowNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(buildRightNavBarArray)
                               name:UIKeyboardDidHideNotification
                             object:nil];
    
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
            [self.albumInfoViewController loadTableData];
            [self.albumInfoViewController.infoTableView reloadData];
            [self.albumInfoViewController.albumImageView setNeedsDisplay];
            [self.albumInfoViewController.comments setNeedsDisplay];
            
            //
            //            self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
            //            [self.iTunesInfoViewController loadTableData];
            //            [self.iTunesInfoViewController.infoTableView reloadData];
            
            self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.iTunesCommentsViewController loadDataForView];
            [self.iTunesCommentsViewController.comments setNeedsDisplay];
            
            self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
            [self.userInfoViewController loadDataForView];
            [self.userInfoViewController.userInfoTagTable reloadData];
            [self.userInfoViewController.comments setNeedsDisplay];
            
            //            self.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
            self.saveTitle = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
            
            //            self.navigationItem.titleView = [self customizeTitleView];
        }
        
    } else {
        
        [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
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
    
    BOOL userIsEditing = [[NSUserDefaults standardUserDefaults] boolForKey:@"userIsEditing"];
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    if (playbackState == MPMusicPlaybackStateStopped) {
        
        [self setShowPlayButton: NO];
        
        //if the user is editing, we don't want to pop, so call goBackClick in InfoTabBarDidCancel
        if (!userIsEditing) {
            self.navigationItem.rightBarButtonItem= nil;
            
            //if the currently playing song is the last one in the queue, force a goBack
            if (self.viewingNowPlaying) {
                [self goBackClick];
            }
            
        }
        
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    //    LogMethod();
    [super viewWillDisappear: animated];
    [self.playbackTimer invalidate];
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end