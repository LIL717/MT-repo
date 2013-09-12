//
//  StoreViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/12/13.
//
//

#import "StoreViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController
@synthesize webView;
@synthesize urlObject;
@synthesize musicPlayer;
@synthesize iPodLibraryChanged;

#pragma mark - Initial Display methods


- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    //set up grouped table view to look like plain (so that section headers won't stick to top)
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    //make the back arrow for left bar button item
    
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
    
    NSAssert(self.webView, @"Unconnected IBOutlet 'webView'");
    
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
//    self.webView.scrollView.bounces = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.urlObject]];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    LogMethod();
    // hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //    LogMethod();
    
    // starting the load, show the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    LogMethod();
    
    // finished loading, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //    LogMethod();
    
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    // -999 == "Operation could not be completed", note -999 occurs when the user clicks away before
    // the page has completely loaded, if we find cases where we want this to result in dialog failure
    // (usually this just means quick-user), then we should add something more robust here to account
    // for differences in application needs
    
    if (!(([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -999) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        // report the error inside the webview
        NSString* errorString = [NSString stringWithFormat:
                                 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
                                 error.localizedDescription];
        [self.webView loadHTMLString:errorString baseURL:nil];
    }
}

- (IBAction)goBackClick
{
    //remove the swipe gesture from the nav bar  (doesn't work to wait until dealloc)
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void) registerForMediaPlayerNotifications {
    //    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}

- (void) handle_iPodLibraryChanged: (id) changeNotification {
    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}

- (void)dealloc {
    //    LogMethod();
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];
    
}
@end

