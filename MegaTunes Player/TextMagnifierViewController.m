//
//  MagnifierViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "TextMagnifierViewController.h"
#import "AppDelegate.h"
#import "MainViewcontroller.h"

@interface TextMagnifierViewController ()

@end

@implementation TextMagnifierViewController

@synthesize musicPlayer;
@synthesize mainViewController;
@synthesize scrollView;
@synthesize textToMagnify;
@synthesize magnifiedLabel;
@synthesize textType;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync


@synthesize delegate;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];

    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    // Display text
    [self displayMagnifiedText];
}
- (void) displayMagnifiedText
{
    LogMethod();

    self.magnifiedLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 320, 460)];
    self.magnifiedLabel.textColor = [UIColor whiteColor];
    self.magnifiedLabel.backgroundColor = [UIColor clearColor];
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:144];
    self.magnifiedLabel.font = newFont;
    self.magnifiedLabel.text = self.textToMagnify;

    //calculate the label size to fit the text with the font size
//    NSLog (@"size of magnifiedLabel is %f", self.magnifiedLabel.frame.size.width);
    CGSize labelSize = [self.magnifiedLabel.text sizeWithFont:self.magnifiedLabel.font
                                    constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
                                           lineBreakMode:NSLineBreakByClipping];
    
    //set the UIOutlet label's frame to the new sized frame
    CGRect frame = self.magnifiedLabel.frame;
    frame.size = labelSize;
    self.magnifiedLabel.frame = frame;
    
    [self.scrollView addSubview:self.magnifiedLabel];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.magnifiedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView,magnifiedLabel);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[magnifiedLabel]|" options: 0 metrics: 0 views:viewsDictionary]];
//    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[magnifiedLabel]-|" options: NSLayoutAttributeCenterY metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[magnifiedLabel]-|" options: NSLayoutFormatAlignAllCenterY metrics: 0 views:viewsDictionary]];
    // Center the label vertically in the window
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:magnifiedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

}


//    Tap to cancel
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    
    [self exitGracefully];
}

- (void) exitGracefully {
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        MPMusicPlaybackState playbackState = [musicPlayer playbackState];
        if (playbackState == MPMusicPlaybackStateStopped) {
//            //pop back to songviewcontroller
//            NSArray *array = [self.navigationController viewControllers];
//            [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
#pragma mark TODO            //need to set up this delegate
            [self.delegate textMagnifierViewControllerDidCancel:self];
        } else {
//            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate textMagnifierViewControllerDidCancel:self];

        }
    }
    
}

- (IBAction)swipeDownDetected:(UISwipeGestureRecognizer *)sender {
//    self.magnifiedLabel.text= @"Swipe Down";
//    NSLog (@"size of magnifiedLabel is %f, %f", self.magnifiedLabel.frame.size.width, self.magnifiedLabel.frame.size.height);
//    NSLog (@"size of scrollView is %f, %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
//    self.magnifiedLabel.textAlignment = NSTextAlignmentLeft;
}

- (IBAction)swipeUpDetected:(UISwipeGestureRecognizer *)sender {
//    self.magnifiedLabel.text= @"Swipe Up";
//    NSLog (@"size of magnifiedLabel is %f, %f", self.magnifiedLabel.frame.size.width, self.magnifiedLabel.frame.size.height);
//    NSLog (@"size of scrollView is %f, %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
//    self.magnifiedLabel.textAlignment = NSTextAlignmentLeft;
}

//- (IBAction)pinchDetected:(UIGestureRecognizer *)sender {
//    
//    CGFloat scale =
//    [(UIPinchGestureRecognizer *)sender scale];
//    CGFloat velocity =
//    [(UIPinchGestureRecognizer *)sender velocity];
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"Pinch - scale = %f, velocity = %f",
//                              scale, velocity];
//    self.label.text = resultString;
//}

//- (IBAction)rotationDetected:(UIGestureRecognizer *)sender {
//    CGFloat radians =
//    [(UIRotationGestureRecognizer *)sender rotation];
//    CGFloat velocity =
//    [(UIRotationGestureRecognizer *)sender velocity];
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"Rotation - Radians = %f, velocity = %f",
//                              radians, velocity];
//    self.label.text = resultString;
//}

//- (IBAction)longPressDetected:(UIGestureRecognizer *)sender {
//    self.label.text = @"Long Press";
//}
//- (void)viewDidUnload {
//
//    [self setScrollView:nil];
//    [self setMagnifiedLabel:nil];
////    [self setLabelWidth:nil];
//    [super viewDidUnload];
//}

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
    if ([self.textType isEqualToString: @"MagnifyNowPlaying"]) {
            self.textToMagnify = self.mainViewController.nowPlayingLabel.text;
    } else {
        self.textToMagnify = self.mainViewController.nextSongLabel.text;
    }
    //pop out of here if there isn't any text to display
    if ([self.textToMagnify isEqualToString: @""]) {
        [self exitGracefully];
    } else {
        //remove the previous magnified label before creating anonther
        [self.magnifiedLabel removeFromSuperview];
        [self displayMagnifiedText];
    }
    
}
- (void) handle_iPodLibraryChanged: (id) changeNotification {
    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}
// When the playback state changes
- (void) handle_PlaybackStateChanged: (id) notification {
    LogMethod();
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    if (playbackState == MPMusicPlaybackStateStopped) {        
        //if the currently playing song is the last one in the queue, exit
        [self exitGracefully];

    }
}

- (void)dealloc {
    LogMethod();
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
    LogMethod();
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
