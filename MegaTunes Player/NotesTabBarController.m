//
//  NotesTabBarController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "NotesTabBarController.h"
#import "Appdelegate.h"
#import "MainViewController.h"
#import "SongInfo.h"
#import "SongInfoViewController.h"
#import "NotesViewController.h"


@interface NotesTabBarController ()

@end

@implementation NotesTabBarController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize songInfo;
@synthesize songInfoViewController;
@synthesize notesViewController;

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    LogMethod();
//    
//    if ((self = [super initWithCoder:aDecoder]))
//    {
//    }
//    return self;
//}

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

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
//    NSLog (@"playing Item is *%@*, songInfo.SongName is *%@*", playingItem, self.songInfo.songName);
    if (playingItem) {
        //don't display right bar button is playing item is song info item
        if ([playingItem isEqualToString: self.songInfo.songName]) {
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

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    self.delegate = self;

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
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
    
    self.songInfoViewController = [[self viewControllers] objectAtIndex:0];
    self.songInfoViewController.songInfo = self.songInfo;
    
//    NSLog (@" in NotesTabBar  self.songInfo.songName = %@", self.songInfo.songName);
//    NSLog (@" in NotesTabBar  self.songInfo.album = %@", self.songInfo.album);
//    NSLog (@" in NotesTabBar  self.songInfo.artist = %@", self.songInfo.artist);
//    self.title = @"Info";
//    self.navigationItem.titleView = [self customizeTitleView];
//    [self.songInfoViewController.navigationController.navigationItem setTitle:@"Info"];
    
    self.notesViewController = [[self viewControllers] objectAtIndex:1];
    self.notesViewController.songInfo = self.songInfo;
    
//    self.title = @"Notes";
//    self.navigationItem.titleView = [self customizeTitleView];
//    [self.notesViewController.navigationController.navigationItem setTitle:@"Notes"];
    
//    [self updateLayoutForNewOrientation: self.interfaceOrientation];


    
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.songInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        [self.songInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    } else {
        NSLog (@"landscape");
        [self.songInfoViewController.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.songInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

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
    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}
- (void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
