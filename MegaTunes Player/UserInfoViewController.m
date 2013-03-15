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

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize userDataForMediaItem;
@synthesize userGrouping;
@synthesize comments;

@synthesize verticalSpaceTopToGroupingConstraint;
@synthesize keyboardHeight;
@synthesize verticalSpaceTopToCommentsConstraint;

@synthesize placeholderLabel;
@synthesize editingUserInfo;

@synthesize landscapeOffset;


- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"UserInfoViewController"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    landscapeOffset = 10.0;
    
    [self loadDataForView];
    
    [self setEditingUserInfo: NO];

    [self updateLayoutForNewOrientation: self.interfaceOrientation];

}

- (void) loadDataForView {
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem = [mediaItemUserData containsItem: [mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID]];
    
    if (self.userDataForMediaItem.userGrouping) {
        self.userGrouping.text = self.userDataForMediaItem.userGrouping;
        self.userGrouping.textColor = [UIColor whiteColor];

    } else {
        self.userGrouping.text = @"";
    }
    
    self.userGrouping.delegate = self;
    [self.userGrouping addTarget:self
                          action:@selector(textFieldFinished:)
                forControlEvents:UIControlEventEditingDidEndOnExit];
    
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

        self.verticalSpaceTopToGroupingConstraint.constant = 12;
        self.verticalSpaceTopToCommentsConstraint.constant = 66;
        
    } else {
//        NSLog (@"landscape");
        self.verticalSpaceTopToGroupingConstraint.constant += landscapeOffset;
        self.verticalSpaceTopToCommentsConstraint.constant += landscapeOffset;
    }
}

#pragma mark textField Delegate Methods________________________________

- (void) textFieldDidBeginEditing: (UITextField *) textField {
//    LogMethod();
    [self setEditingUserInfo: YES];
    
    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor darkGrayColor]];
    [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];

}

- (void) textFieldDidEndEditing: (UITextField *) textField {
//    LogMethod();

    [textField setBackgroundColor: [UIColor clearColor]];
    
    //update or add object to Core Data
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
    self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
    self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
    self.userDataForMediaItem.userGrouping = self.userGrouping.text;
    
    [mediaItemUserData updateUserGroupingForItem: self.userDataForMediaItem];
    [self setEditingUserInfo: NO];

    
}
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

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
    
    //pull the field up to the top (over the userGrouping field while editing)
    
    self.verticalSpaceTopToCommentsConstraint.constant -= (self.userGrouping.frame.size.height);
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
    
    self.verticalSpaceTopToCommentsConstraint.constant += self.userGrouping.frame.size.height;

    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
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