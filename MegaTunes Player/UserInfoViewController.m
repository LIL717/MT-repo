//
//  UserInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/14/13.
//
//

#import "UserInfoViewController.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "UserTagViewController.h"
//#import "TagItem.h"
#import "TagData.h"
#import "KSLabel.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize userDataForMediaItem;
@synthesize userTagButton;
@synthesize tagLabel;
@synthesize comments;

@synthesize verticalSpaceTopToTagConstraint;
@synthesize keyboardHeight;
@synthesize verticalSpaceTopToCommentsConstraint;

@synthesize placeholderLabel;
@synthesize editingUserInfo;

@synthesize landscapeOffset;

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"UserInfoViewController"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    landscapeOffset = 12.0;
    
    [self loadDataForView];
    
    [self setEditingUserInfo: NO];

    [self updateLayoutForNewOrientation: self.interfaceOrientation];

}

- (void) loadDataForView {
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    [mediaItemUserData listAll];
    
    self.tagLabel.textColor = [UIColor whiteColor];
    [self.tagLabel setDrawOutline:YES];
    [self.tagLabel setOutlineColor:[UIColor blackColor]];
    [self.tagLabel setDrawGradient:NO];
    self.tagLabel.font = [UIFont systemFontOfSize:44];
    
    self.userDataForMediaItem = [mediaItemUserData containsItem: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID]];
    TagData *tagData = self.userDataForMediaItem.tagData;

    if (self.userDataForMediaItem.tagData.tagName) {
        
        int red = [tagData.tagColorRed intValue];
        int green = [tagData.tagColorGreen intValue];
        int blue = [tagData.tagColorBlue intValue];
        int alpha = [tagData.tagColorAlpha intValue];
        
        UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
        UIImage *labelBackgroundImage = [UIImage imageNamed: @"list-background.png"];
        UIImage *coloredImage = [labelBackgroundImage imageWithTint: tagColor];
        
        [self.userTagButton setBackgroundImage: coloredImage forState: UIControlStateNormal];
        
        self.tagLabel.text = tagData.tagName;

        NSLog (@" tagData.tagName = %@", tagData.tagName);

    } else {
        
        UIImage *labelBackgroundImage = [UIImage imageNamed: @"list-background.png"];
        [self.userTagButton setBackgroundImage: labelBackgroundImage forState: UIControlStateNormal];

        self.tagLabel.textColor = [UIColor lightGrayColor];
        self.tagLabel.text = NSLocalizedString(@"Select Tag", nil);
    }

    self.comments.delegate = self;
    
    if (self.userDataForMediaItem.comments) {
        self.comments.text = self.userDataForMediaItem.comments;
        [self.placeholderLabel setHidden:YES];
    } else {
        self.comments.text = @"";
        [self.placeholderLabel setHidden:NO];
    }

}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //executes this method on initial load and the one in InfoTabBarController after that, so they need to stay in synch with each other and with the constaint set in interface builder
    if (UIInterfaceOrientationIsPortrait(orientation)) {
//        NSLog (@"portrait");

        self.verticalSpaceTopToTagConstraint.constant = 10;
        self.verticalSpaceTopToCommentsConstraint.constant = 65;
        
    } else {
//        NSLog (@"landscape");
        self.verticalSpaceTopToTagConstraint.constant += landscapeOffset;
        self.verticalSpaceTopToCommentsConstraint.constant += landscapeOffset;
    }
}

#pragma mark textField Delegate Methods________________________________

//- (void) textFieldDidBeginEditing: (UITextField *) textField {
////    LogMethod();
//    [self setEditingUserInfo: YES];
//    
//    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor darkGrayColor]];
//    [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
//
//}
//
//- (void) textFieldDidEndEditing: (UITextField *) textField {
////    LogMethod();
//
//    [textField setBackgroundColor: [UIColor clearColor]];
//    
//    //update or add object to Core Data
//    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
//    mediaItemUserData.managedObjectContext = self.managedObjectContext;
//    
//    self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
//    self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
//    self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
//    self.userDataForMediaItem.tagItem.tagName = self.userTagButton.titleLabel;
//    
//    [mediaItemUserData updateTagForItem: self.userDataForMediaItem];
//    [self setEditingUserInfo: NO];
//
//    
//}
//- (IBAction)textFieldFinished:(id)sender
//{
//    [sender resignFirstResponder];
//}

#pragma mark textView Delegate Methods________________________________

- (void) textViewDidBeginEditing: (UITextView *) textView {
//    LogMethod();

    [self setEditingUserInfo: YES];

    [self registerForKeyboardNotifications];

    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"background.png"] imageWithTint:[UIColor darkGrayColor]];
    [textView setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    
    if([textView isEqual:self.comments]){
        [self.placeholderLabel setHidden:YES];
    }
}
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}
- (void) textViewDidEndEditing: (UITextView *) textView {
//    LogMethod();

    [textView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    //update or add object to Core Data
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
    self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
    self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
    self.userDataForMediaItem.comments = self.comments.text;
    
    [mediaItemUserData updateCommentsForItem: self.userDataForMediaItem];
    [self unregisterForKeyboardNotifications];
    [self setEditingUserInfo: NO];

}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
//    LogMethod();
    NSDictionary *info = [aNotification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //hmmm this is width 162 and height 480 for landscape

    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat kbHeight = isPortrait ? kbSize.height : kbSize.width;

    //since this view contains a tabBar, which is not visible when the keyboard is present, need to subtract the height of the tabBar from the keyboard height to get the right constraint since original constraint is to top of tabBar
    
    kbHeight -= self.tabBarController.tabBar.backgroundImage.size.height;
    
    NSLog(@"Updating constraints.");
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.keyboardHeight.constant = -kbHeight;
    
    //pull the field up to the top (over the tagItem field while editing)
    
    self.verticalSpaceTopToCommentsConstraint.constant -= (self.userTagButton.frame.size.height);
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//    LogMethod();
    NSDictionary *info = [aNotification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 0;
    
    self.verticalSpaceTopToCommentsConstraint.constant += self.userTagButton.frame.size.height;

    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark Prepare for Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
        
	if ([segue.identifier isEqualToString:@"SelectTag"])
    {
        [self setEditingUserInfo: YES];

        UserTagViewController *userTagViewController = segue.destinationViewController;
        userTagViewController.managedObjectContext = self.managedObjectContext;
        
        if (!self.userDataForMediaItem) {
            self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
            self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
            self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
        }
        
        userTagViewController.userDataForMediaItem = self.userDataForMediaItem;
        userTagViewController.userTagViewControllerDelegate = self;

        
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (void)userTagViewControllerDidCancel:(UserTagViewController *)controller
{
    //need to reload on return so that selected tag is shown
    [self setEditingUserInfo: NO];
//    [self.tagLabel removeFromSuperview];
//    self.userTagButton.titleLabel.text = @"";


    [self loadDataForView];
    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    //need to add back observer for playbackStatechanged because it was removed before going to info in case user edits

    
}
- (void)registerForKeyboardNotifications
{
//    LogMethod();

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
- (void)unregisterForKeyboardNotifications {
//    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
												  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIKeyboardWillHideNotification
												  object: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end