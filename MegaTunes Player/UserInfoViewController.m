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
//140216 1.2 iOS 7 begin
#import "TagItem.h"
//140216 1.2 iOS 7 end
#import "TagData.h"
#import "KSLabel.h"
#import "UserTagCell.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize userDataForMediaItem;
@synthesize userInfoTagTable;
@synthesize comments;

@synthesize verticalSpaceTopToTableViewConstraint;
@synthesize keyboardHeight;
@synthesize verticalSpaceTopToCommentsConstraint;

@synthesize placeholderLabel;
@synthesize editingUserInfo;

@synthesize userInfoTagArray;
@synthesize showCheckMarkButton;

//140216 1.2 iOS 7 begin
BOOL itemHasTag;
//140216 1.2 iOS 7 end

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
//    [TestFlight passCheckpoint:@"UserInfoViewController"];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
//140206 1.2 iOS 7 begin
    // cause separator line to stretch to right side of view
    [self.userInfoTagTable setSeparatorInset:UIEdgeInsetsZero];
//140206 1.2 iOS 7 end
    [self loadDataForView];
    
    [self setEditingUserInfo: NO];
    // save to NSUserDefaults so that the MainViewController can check before popping out if state changes to stopped
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.editingUserInfo forKey:@"userIsEditing"];
    
    [self setShowCheckMarkButton: NO];

    [self updateLayoutForNewOrientation: self.interfaceOrientation];

}

- (void) loadDataForView {
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
//    [mediaItemUserData listAll];
    
    self.userDataForMediaItem = [mediaItemUserData containsItem: [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID]];
    TagData *tagData = self.userDataForMediaItem.tagData;
//140216 1.2 iOS 7 begin
    TagItem *tagItem = [TagItem alloc];
    if (tagData) {
        itemHasTag = YES;
        tagItem.tagName = tagData.tagName;
        tagItem.tagColorRed = tagData.tagColorRed;
        tagItem.tagColorBlue = tagData.tagColorBlue;
        tagItem.tagColorGreen = tagData.tagColorGreen;
        tagItem.tagColorAlpha = tagData.tagColorAlpha;
//        self.userInfoTagArray = [NSArray arrayWithObjects: tagItem, nil];
    } else {
        itemHasTag = NO;
        tagItem.tagName = @"Assign Tag";
    }
    self.userInfoTagArray = [NSArray arrayWithObjects: tagItem, nil];
//140216 1.2 iOS 7 begin

    self.comments.delegate = self;
    
    if ([self.userDataForMediaItem.comments length] > 0) {
        self.comments.text = self.userDataForMediaItem.comments;
        [self.comments setContentOffset:CGPointMake(0, 0) animated:YES];

        [self.placeholderLabel setHidden:YES];
    } else {
        self.comments.text = @"";
        [self.placeholderLabel setHidden:NO];
        self.placeholderLabel.text = NSLocalizedString(@"Add Notes", nil);
    }
    

}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //executes this method on initial load and the one in InfoTabBarController after that, so they need to stay in synch with each other and with the constaint set in interface builder
//140216 1.2 iOS 7 begin
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 3;
    self.verticalSpaceTopToTableViewConstraint.constant = navBarAdjustment;
    self.verticalSpaceTopToCommentsConstraint.constant = 55 + navBarAdjustment;
//131216 1.2 iOS 7 end
    [self loadDataForView];
    [self.userInfoTagTable reloadData];

}

#pragma mark textView Delegate Methods________________________________

- (void) textViewDidBeginEditing: (UITextView *) textView {
//    LogMethod();

    [self setEditingUserInfo: YES];
    // save to NSUserDefaults so that the MainViewController can check before popping out if state changes to stopped
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.editingUserInfo forKey:@"userIsEditing"];

    [self setShowCheckMarkButton: YES];

    
    [self registerForKeyboardNotifications];

//131203 1.2 iOS 7 begin
    
    textView.backgroundColor = [UIColor darkGrayColor];
    
//131203 1.2 iOS 7 end

    if([textView isEqual:self.comments]){
        [self.placeholderLabel setHidden:YES];
    }
}
//- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if([text isEqualToString:@"\n"]){
//        [textView resignFirstResponder];
//        return NO;
//    }else{
//        return YES;
//    }
//}
- (void) textViewDidEndEditing: (UITextView *) textView {
    LogMethod();

//131203 1.2 iOS 7 begin
    
    textView.backgroundColor = [UIColor blackColor];
    
//131203 1.2 iOS 7 end
    //update or add object to Core Data
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
    self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
    self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
    self.userDataForMediaItem.comments = self.comments.text;
    
    [mediaItemUserData updateCommentsForItem: self.userDataForMediaItem];
    
    //this will re-setup the button
    if (!self.userDataForMediaItem.tagData) {
        [self loadDataForView];
    }
    [self unregisterForKeyboardNotifications];
    [self setEditingUserInfo: NO];
    // save to NSUserDefaults so that the MainViewController can check before popping out if state changes to stopped
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.editingUserInfo forKey:@"userIsEditing"];
    [self setShowCheckMarkButton: NO];


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
    
    //if there is no tagData need to remove the button temporarily
    if (!self.userDataForMediaItem.tagData) {
    }
//    self.verticalSpaceTopToCommentsConstraint.constant -= (self.userTagButton.frame.size.height);
    self.verticalSpaceTopToCommentsConstraint.constant -= (self.userInfoTagTable.frame.size.height);

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
    
//    self.verticalSpaceTopToCommentsConstraint.constant += self.userTagButton.frame.size.height;
    self.verticalSpaceTopToCommentsConstraint.constant += self.userInfoTagTable.frame.size.height;

    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    LogMethod();
    return 1;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    LogMethod();
    return [self.userInfoTagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    LogMethod();
    
	UserTagCell *cell = (UserTagCell *)[tableView dequeueReusableCellWithIdentifier:@"UserTagCell"];
    
    [cell.tagLabel removeFromSuperview];
    
    cell.tagLabel = [[KSLabel alloc] initWithFrame:CGRectMake(8, 0, cell.frame.size.width - 8, 55)];
    
    cell.tagLabel.textColor = [UIColor whiteColor];
    [cell.tagLabel setDrawOutline:YES];
    [cell.tagLabel setOutlineColor:[UIColor blackColor]];
    
    [cell.tagLabel setDrawGradient:NO];
    
    cell.tagLabel.font = [UIFont systemFontOfSize:44];
//131203 1.2 iOS 7 begin
    TagItem *tagItem = [self.userInfoTagArray objectAtIndex:indexPath.row];
    cell.tagLabel.text = tagItem.tagName;
    
    if ([cell.tagLabel.text isEqualToString: @"Assign Tag"]) {
        cell.contentView.backgroundColor = [UIColor darkGrayColor];
    } else {
        int red = [tagItem.tagColorRed intValue];
        int green = [tagItem.tagColorGreen intValue];
        int blue = [tagItem.tagColorBlue intValue];
        int alpha = [tagItem.tagColorAlpha intValue];
        
        UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        cell.contentView.backgroundColor = tagColor;
    }
    [cell addSubview:cell.tagLabel];

//131203 1.2 iOS 7 end
    
    return cell;
    //    }
}

#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {    
   
    [self performSegueWithIdentifier: @"SelectTag" sender: self];

    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem.tagData = nil;
    [mediaItemUserData updateTagForItem: self.userDataForMediaItem];
    
    self.userInfoTagArray = [NSArray arrayWithObjects: nil];
//140216 1.2 iOS 7 begin
    itemHasTag = NO;
    [self loadDataForView];
    [tableView reloadData];
    [tableView setEditing:NO animated:NO];
//140216 1.2 iOS 7 end
    
//    NSLog (@"Deleted tag from mediaItemUserData");
//    [mediaItemUserData listAll];
//    TagData *tagData = [TagData alloc];
//    tagData.managedObjectContext = self.managedObjectContext;
//    [tagData listAll];
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//140216 1.2 iOS 7 bein
    if (itemHasTag) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
//140216 1.2 iOS 7 end
}

#pragma mark Prepare for Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
        
	if ([segue.identifier isEqualToString:@"SelectTag"])
    {
        [self setEditingUserInfo: YES];
        // save to NSUserDefaults so that the MainViewController can check before popping out if state changes to stopped
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setBool:self.editingUserInfo forKey:@"userIsEditing"];

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
    
}

- (IBAction) selectNewTag {

    [self performSegueWithIdentifier: @"SelectTag" sender: self];
}

- (void)userTagViewControllerDidCancel:(UserTagViewController *)controller
{
    //need to reload on return so that selected tag is shown
    [self setEditingUserInfo: NO];
    // save to NSUserDefaults so that the MainViewController can check before popping out if state changes to stopped
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:self.editingUserInfo forKey:@"userIsEditing"];
//    [self.tagLabel removeFromSuperview];
//    self.userTagButton.titleLabel.text = @"";

    self.userInfoTagArray = [NSArray arrayWithObjects: nil];
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