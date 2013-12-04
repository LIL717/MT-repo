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
    
//131203 1.2 iOS 7 begin
    
    //    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
//131203 1.2 iOS 7 end
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self loadDataForView];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) loadDataForView {
    
    //check to see if there is user data for this media item
    if ([self.mediaItemForInfo valueForProperty: MPMediaItemPropertyComments]) {
        //display Comments and later save this value in userDataForMediaItem in Core Data
        self.comments.text= [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyComments];
    } else {
        self.comments.text = @"No iTunes Comments";
    }
    
}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        
        [self.comments setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        //        [self.view removeConstraint:self.verticalSpaceToTop28];
        //        [self.view addConstraint:self.verticalSpaceToTop];
        //        // Set top row spacing to superview top
        //
    } else {
        NSLog (@"landscape");
        [self.comments setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.comments scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        //        [self.view removeConstraint:self.verticalSpaceToTop];
        //
        //        // Set top row spacing to superview top
        //        self.verticalSpaceToTop28 = [NSLayoutConstraint constraintWithItem:self.comments attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:28];
        //        [self.view addConstraint: self.verticalSpaceToTop28];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end