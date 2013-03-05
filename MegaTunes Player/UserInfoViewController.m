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

@synthesize scrollView;
@synthesize verticalSpaceToTop;
@synthesize verticalSpaceToTop28;

@synthesize placeholderLabel;
@synthesize editingUserInfo;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
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
    }
    
    self.userGrouping.delegate = self;
    [self.userGrouping addTarget:self
                          action:@selector(textFieldFinished:)
                forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.comments.delegate = self;
    if (self.userDataForMediaItem.comments) {
        self.comments.text = self.userDataForMediaItem.comments;
        [self.placeholderLabel setHidden:YES];
    }

}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        
        [self.view removeConstraint:self.verticalSpaceToTop28];
        [self.view addConstraint:self.verticalSpaceToTop];
        
    } else {
        NSLog (@"landscape");
        [self.view removeConstraint:self.verticalSpaceToTop];
        
        // Set top row spacing to superview top
        self.verticalSpaceToTop28 = [NSLayoutConstraint constraintWithItem:self.userGrouping attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:28];
        [self.view addConstraint: self.verticalSpaceToTop28];
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
#pragma mark textField Delegate Methods________________________________

- (void) textFieldDidBeginEditing: (UITextField *) textField {
    LogMethod();
    [self setEditingUserInfo: YES];
    
    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor darkGrayColor]];
    [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];


}


- (void) textFieldDidEndEditing: (UITextField *) textField {
    LogMethod();


    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor blackColor]];
    [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    
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
    LogMethod();

    [self setEditingUserInfo: YES];

    [self registerForKeyboardNotifications];

    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"background.png"] imageWithTint:[UIColor redColor]];
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
    LogMethod();

    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"background.png"] imageWithTint:[UIColor blackColor]];
    [textView setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    
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
    LogMethod();
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    //hmmm this is width 162 and height 480
//    CGRect rotatedKbRect;
    if (UIInterfaceOrientationIsLandscape (self.interfaceOrientation)) {
//        [self.view removeConstraint:self.verticalSpaceToTop28];
//        rotatedKbRect = [self.view convertRect: kbRect fromView: self.view];
//        kbSize = rotatedKbRect.size;
        NSLog (@"landscape");
        CGSize flipSize = kbSize;
        flipSize.height = kbSize.width;
        flipSize.width = kbSize.height;
        kbSize = flipSize;
    }
    
    CGRect scrollRect = self.scrollView.frame;
    if (UIInterfaceOrientationIsLandscape (self.interfaceOrientation)) {
        scrollRect.origin.y = 0.0;
        scrollRect.size.height = self.scrollView.frame.size.height + 28;
        self.scrollView.frame = scrollRect;
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    NSLog (@"self.comments.frame.origin.X = %f", self.comments.frame.origin.x);
    NSLog (@"self.comments.frame.origin.Y = %f", self.comments.frame.origin.y);
    
    CGPoint textBottom = self.comments.frame.origin;
    textBottom.y = self.comments.frame.origin.y + 54;
   
    if (UIInterfaceOrientationIsLandscape (self.interfaceOrientation)) {

        if (!CGRectContainsPoint(aRect, textBottom)) {
            [self.view removeConstraint:self.verticalSpaceToTop28];

            CGPoint scrollPoint = CGPointMake(0.0, self.comments.frame.origin.y);
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
    } else {
        if (!CGRectContainsPoint(aRect, self.comments.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, self.comments.frame.origin.y-kbSize.height);
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    LogMethod();

    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    if (UIInterfaceOrientationIsLandscape (self.interfaceOrientation)) {
//        [self.view addConstraint: self.verticalSpaceToTop28];
    }
}

- (void)registerForKeyboardNotifications
{
    LogMethod();

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
    LogMethod();
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