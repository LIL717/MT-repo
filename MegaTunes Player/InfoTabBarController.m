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
//140221 1.2 iOS 7 begin
@synthesize tempPlayButton;
//140221 1.2 iOS 7 end

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
    //    self.delegate = self;
    
//131203 1.2 iOS 7 begin

    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.titleView = [self customizeTitleView];

    self.tempPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.tempPlayButton addTarget:self action:@selector(viewNowPlaying) forControlEvents:UIControlEventTouchUpInside];
    [self.tempPlayButton setImage:[UIImage imageNamed:@"redWhitePlayImage.png"] forState:UIControlStateNormal];
    [self.tempPlayButton setShowsTouchWhenHighlighted:NO];
    [self.tempPlayButton sizeToFit];
    
//140127 1.2 iOS 7 end
    
    [self.playBarButton setIsAccessibilityElement:YES];
    [self.playBarButton setAccessibilityLabel: NSLocalizedString(@"Now Playing", nil)];
    [self.playBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    //131203 1.2 iOS 7 begin
    
    UIButton *tempCheckMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempCheckMarkButton addTarget:self action:@selector(saveTextViewData) forControlEvents:UIControlEventTouchUpInside];
    [tempCheckMarkButton setImage:[UIImage imageNamed:@"checkMarkImage.png"] forState:UIControlStateNormal];
    [tempCheckMarkButton setShowsTouchWhenHighlighted:NO];
    [tempCheckMarkButton sizeToFit];
    
    self.checkMarkButton = [[UIBarButtonItem alloc] initWithCustomView:tempCheckMarkButton];
    //140127 1.2 iOS 7 end
    
    [self.checkMarkButton setIsAccessibilityElement:YES];
    [self.checkMarkButton setAccessibilityLabel: NSLocalizedString(@"Done", nil)];
    [self.checkMarkButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    self.saveTitle = self.title;
    
    self.albumInfoViewController = [[self viewControllers] objectAtIndex:0];
    self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
    
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
    
    musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
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
    
}
- (void) updateTime {
    MainViewController *mainViewController =( MainViewController *) self.infoDelegate;
    
    [mainViewController updateTime];
    
//140128 1.2 iOS 7 begin
    UIButton *tempElapsedTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempElapsedTimeButton setTitle: mainViewController.elapsedTimeLabel.text forState: UIControlStateNormal];
    [tempElapsedTimeButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [tempElapsedTimeButton setShowsTouchWhenHighlighted:NO];
    tempElapsedTimeButton.titleLabel.font            = [UIFont systemFontOfSize: 44];
    [tempElapsedTimeButton sizeToFit];
    
    self.elapsedTimeButton = [[UIBarButtonItem alloc] initWithCustomView:tempElapsedTimeButton];

    UIButton *tempRemainingTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempRemainingTimeButton setTitle: mainViewController.remainingTimeLabel.text forState: UIControlStateNormal];
    [tempRemainingTimeButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [tempRemainingTimeButton setShowsTouchWhenHighlighted:NO];
    tempRemainingTimeButton.titleLabel.font            = [UIFont systemFontOfSize: 44];
    [tempRemainingTimeButton sizeToFit];
    
    self.remainingTimeButton = [[UIBarButtonItem alloc] initWithCustomView:tempRemainingTimeButton];
//140128 1.2 iOS 7 end
    
    [self buildRightNavBarArray];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];

    //131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //131216 1.2 iOS 7 end
    
    if (self.viewingNowPlaying && self.mainViewIsSender) {
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateTime)
                                                            userInfo:nil
                                                             repeats:YES];
    }
    //    self.navigationItem.titleView = [self customizeTitleView];
    
    
    [self updateLayoutForNewOrientation];
    
    
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
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: self.remainingTimeButton, self.elapsedTimeButton, nil] animated: NO];
        } else {
			[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nil] animated: YES];
			self.title = self.saveTitle;
			self.navigationItem.titleView = [self customizeTitleView];

        }
        //                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nil] animated: YES];
        //        self.title = nil;
        //        self.title = NSLocalizedString(self.songViewTitle, nil);
    }
}

- (UILabel *) customizeTitleView
{
//131205 1.2 iOS 7 begin
    
    //    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44]}].width, 48);
    
//131205 1.2 iOS 7 end
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UIFont *newFont = [UIFont systemFontOfSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
		//    LogMethod();
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[self updateLayoutForNewOrientation];

}
- (void) updateLayoutForNewOrientation {
		//    LogMethod();
	CGFloat navBarAdjustment = 0;
//	CGFloat navBarAdjustment = isPortrait ? 0 : 9;


	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) { //portrait

        //        NSLog (@"portrait");
        
        [self.tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        self.playBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.tempPlayButton];
        
        self.albumInfoViewController.lastPlayedDateTitle = @"Played:";
        self.albumInfoViewController.userGroupingTitle = @"Grouping:";

    } else {
        //        NSLog (@"landscape");
        
        [self.tempPlayButton setContentEdgeInsets: UIEdgeInsetsMake(5.0, 0.0, -5.0, 0.0)];
        self.playBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.tempPlayButton];
        
        self.albumInfoViewController.lastPlayedDateTitle = @"Last Played:";
        self.albumInfoViewController.userGroupingTitle = @"iTunes Grouping:";

    }
    [self.albumInfoViewController.infoTableView setContentOffset:CGPointMake(0, navBarAdjustment)];
    [self.albumInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.albumInfoViewController loadTableData];
    [self.albumInfoViewController.infoTableView reloadData];
    
    //these weren't doing anything 
//    [self.iTunesCommentsViewController.comments setContentOffset:CGPointMake(0, navBarAdjustment)];
//    [self.iTunesCommentsViewController.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    self.userInfoViewController.verticalSpaceTopToTableViewConstraint.constant = navBarAdjustment;
    self.userInfoViewController.verticalSpaceTopToCommentsConstraint.constant = 55 + navBarAdjustment;
    
    [self.userInfoViewController.userInfoTagTable reloadData];
    //don't reload the userInfoData if it is being edited
    if (!userInfoViewController.editingUserInfo) {
        [self.userInfoViewController loadDataForView];
    }

    [self buildRightNavBarArray];

//140215 1.2 iOS 7 end
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
    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
    
}
- (void) saveTextViewData {
    
    [self.userInfoViewController.comments resignFirstResponder];
    
}
//140217 1.2 iOS 7 begin
//intercept back Button pressed
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        //don't use goBackClick because it needs to decide where to pop back to if the music player stops, back button assumes music player has not stopped so can just pop back to previous view
        [self.navigationController.navigationBar removeGestureRecognizer:self.swipeLeftRight];
        [self.infoDelegate infoTabBarControllerDidCancel:self];
    }
}
- (void)goBackClick
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    NSLog (@" playbackState is %ld", playbackState);
    if (playbackState == MPMusicPlaybackStateStopped) {
        //pop back to songviewcontroller
        
        UIViewController *popToVC = [[UIViewController alloc] init];
        BOOL vCFound = NO;
        
        for (UIViewController*vc in [self.navigationController viewControllers]) {
            if ([vc isKindOfClass: [SongViewController class]]){
                popToVC = vc;
                vCFound = YES;
            }
            if ([vc isKindOfClass: [TaggedSongViewController class]]){
                popToVC = vc;
                vCFound = YES;
            }
        }
        if (vCFound) {
            [self.navigationController popToViewController: popToVC animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//140217 1.2 iOS 7 end

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
    
//    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
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
//140218 1.2 iOS 7 begin
    // this method is being called even when iPod Library has not changed, so its not really useful
    [self setIPodLibraryChanged: YES];
//140218 1.2 iOS 7 end
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
    
//    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end