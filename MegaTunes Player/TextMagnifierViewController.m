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

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    // Display text
    self.magnifiedLabel = [[UILabel alloc] initWithFrame: self.scrollView.frame];

    self.magnifiedLabel.textColor = [UIColor whiteColor];
    self.magnifiedLabel.backgroundColor = [UIColor clearColor];

    self.magnifiedLabel.font = [UIFont systemFontOfSize:144];
    self.magnifiedLabel.text = self.textToMagnify;

    //calculate the label size to fit the text with the font size

//131210 1.2 iOS 7 begin
    
//    CGSize labelSize = [self.magnifiedLabel.text sizeWithFont:self.magnifiedLabel.font
//                                            constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
//                                                lineBreakMode:NSLineBreakByClipping];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:self.magnifiedLabel.text
                                                                        attributes:@{NSFontAttributeName: self.magnifiedLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize labelSize = rect.size;
    
//131210 1.2 iOS 7 end

    //set the UIOutlet label's frame to the new sized frame
    CGRect frame = self.magnifiedLabel.frame;
    frame.size = labelSize;

    self.magnifiedLabel.frame = frame;
    
    [self.scrollView addSubview:self.magnifiedLabel];
    
    self.magnifiedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(magnifiedLabel);

    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[magnifiedLabel]|" options: 0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[magnifiedLabel]-|" options: NSLayoutFormatAlignAllCenterY metrics: 0 views:viewsDictionary]];
    // Center the label vertically in the window
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:magnifiedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
}
//    Tap to cancel
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.delegate textMagnifierViewControllerDidCancel:self];

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

- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
    //don't need handle_PlaybackStateChanged because that will only happen here is NowPlayingItemChanged and responding to both does not work

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
    if ((!self.textToMagnify) || ([self.textToMagnify isEqualToString: @""])) {
        [self.delegate textMagnifierViewControllerDidCancel:self];

    } else {
        self.magnifiedLabel.text = self.textToMagnify;

        //calculate the label size to fit the text with the font size
        //    NSLog (@"size of magnifiedLabel is %f", self.magnifiedLabel.frame.size.width);
        
//131210 1.2 iOS 7 begin
        
//        CGSize labelSize = [self.magnifiedLabel.text sizeWithFont:self.magnifiedLabel.font
//                                                constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
//                                                    lineBreakMode:NSLineBreakByClipping];
        
        NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:self.magnifiedLabel.text
                                                                            attributes:@{NSFontAttributeName: self.magnifiedLabel.font}];
        
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        
//131210 1.2 iOS 7 end
        
        //set the UIOutlet label's frame to the new sized frame
        CGRect frame = self.magnifiedLabel.frame;
        frame.size.width = labelSize.width;
        self.magnifiedLabel.frame = frame;
        
        //scroll to the beginning of the title
        [self.scrollView setContentOffset:CGPointMake(0,0) animated: NO];
    }
    
}

- (void)dealloc {
    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
    
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
- (void)didReceiveMemoryWarning
{
    LogMethod();
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
