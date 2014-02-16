//
//  ITunesCommentsViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/14/13.
//
//

#import "ITunesCommentsViewController.h"
#import "MediaItemUserData.h"

@interface ITunesCommentsViewController ()

@end

@implementation ITunesCommentsViewController

@synthesize musicPlayer;
@synthesize mediaItemForInfo;


@synthesize comments;

//@synthesize verticalSpaceToTop;
//@synthesize verticalSpaceToTop28;

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self loadDataForView];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) loadDataForView {
    
    //check to see if there is user data for this media item
//140204 1.2 iOS 7 begin
    self.comments.text = @"No iTunes Comments";
    
    NSString *cmmnts = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyComments];
    if (cmmnts) {
        if (![cmmnts isEqualToString: @""]) {
        //display Comments and later save this value in userDataForMediaItem in Core Data
            self.comments.text= [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyComments];
        }
    }
    
}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 3;
    
    [self.comments setContentOffset:CGPointMake(0, navBarAdjustment)];
    
    //this line of code does not appear to be working here, moved to viewWillAppear
    [self.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];
    
    //131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

    return;
}
//131216 1.2 iOS 7 end

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end