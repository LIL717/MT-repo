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

@synthesize landscapeOffset;
@synthesize userInfoTagArray;
@synthesize tagButton;
@synthesize showCheckMarkButton;

#pragma mark - Initial Display methods

- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"UserInfoViewController"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    [self.userInfoTagTable setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    landscapeOffset = 12.0;
    
    [self loadDataForView];
    
    [self setEditingUserInfo: NO];
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
    
    [self.tagButton removeFromSuperview];
    
    if (tagData) {
        self.userInfoTagArray = [NSArray arrayWithObjects: tagData, nil];
    } else {
        self.userInfoTagArray = [NSArray arrayWithObjects: nil];
        
        self.tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.tagButton addTarget:self
                   action:@selector(selectNewTag)
         forControlEvents:UIControlEventTouchDown];
        [self.tagButton setTitle:NSLocalizedString(@"Assign Tag", nil) forState:UIControlStateNormal];
        BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

        CGFloat tagButtonY = 11.0;

        if (isPortrait) {
            tagButtonY = 11.0;
        } else {
            tagButtonY = 23.0;
        }
        
        self.tagButton.frame = CGRectMake(0.0, tagButtonY, self.view.bounds.size.width, 54.0);


        UIImage *labelBackgroundImage = [UIImage imageNamed: @"list-background.png"];
        UIImage *coloredImage = [labelBackgroundImage imageWithTint: [UIColor darkGrayColor]];
        [self.tagButton setBackgroundImage: coloredImage forState: UIControlStateNormal];
        [self.tagButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        self.tagButton.titleLabel.font = [UIFont systemFontOfSize:44];
//        self.tagButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.tagButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //adjust the content left inset otherwise the text will touch the left border:
        self.tagButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                
        UIView *superview = self.view;
        
        [self.tagButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [superview addSubview:self.tagButton];
        
        NSLayoutConstraint *myConstraint = [NSLayoutConstraint
                                            constraintWithItem:self.tagButton
                                            attribute:NSLayoutAttributeTrailing
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:superview
                                            attribute:NSLayoutAttributeTrailing
                                            multiplier:1.0
                                            constant:0];
        
        [superview addConstraint:myConstraint];
        
        myConstraint = [NSLayoutConstraint
                        constraintWithItem:self.tagButton
                        attribute:NSLayoutAttributeLeading
                        relatedBy:NSLayoutRelationEqual
                        toItem:superview
                        attribute:NSLayoutAttributeLeading
                        multiplier:1.0
                        constant:0];
        
        [superview addConstraint:myConstraint];
        
        myConstraint = [NSLayoutConstraint
                        constraintWithItem:self.tagButton
                        attribute:NSLayoutAttributeTop
                        relatedBy:NSLayoutRelationEqual
                        toItem:superview
                        attribute:NSLayoutAttributeTop
                        multiplier:1.0
                        constant:tagButtonY];
        
        [superview addConstraint:myConstraint];
        
        myConstraint = [NSLayoutConstraint
                        constraintWithItem:self.tagButton
                        attribute:NSLayoutAttributeHeight
                        relatedBy:NSLayoutRelationEqual
                        toItem:nil
                        attribute:NSLayoutAttributeNotAnAttribute
                        multiplier:1.0
                        constant:54];
        
        [superview addConstraint:myConstraint];
    }

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
    if (UIInterfaceOrientationIsPortrait(orientation)) {
//        NSLog (@"portrait");

        self.verticalSpaceTopToTableViewConstraint.constant = 11;
        self.verticalSpaceTopToCommentsConstraint.constant = 66;
        
    } else {
//        NSLog (@"landscape");
        self.verticalSpaceTopToTableViewConstraint.constant = 23;
        self.verticalSpaceTopToCommentsConstraint.constant = 78;
    }
    [self loadDataForView];
    [self.userInfoTagTable reloadData];

}

#pragma mark textView Delegate Methods________________________________

- (void) textViewDidBeginEditing: (UITextView *) textView {
//    LogMethod();

    [self setEditingUserInfo: YES];
    [self setShowCheckMarkButton: YES];

    
    [self registerForKeyboardNotifications];

    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"background.png"] imageWithTint:[UIColor darkGrayColor]];
    [textView setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    
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

    [textView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
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
        [self.tagButton removeFromSuperview];
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
    //don't use UserTagCell for searchResultsCell won't respond to touches to scroll anyway and terrible performance on GoBackClick when autoRotated
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *searchResultsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	UserTagCell *cell = (UserTagCell *)[tableView dequeueReusableCellWithIdentifier:@"UserTagCell"];
    
    [cell.tagLabel removeFromSuperview];
    
    cell.tagLabel = [[KSLabel alloc] initWithFrame:CGRectMake(8, 0, cell.frame.size.width - 8, 55)];
    
    cell.tagLabel.textColor = [UIColor whiteColor];
    [cell.tagLabel setDrawOutline:YES];
    [cell.tagLabel setOutlineColor:[UIColor blackColor]];
    
    [cell.tagLabel setDrawGradient:NO];
    //        CGFloat colors [] = {
    //            255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0,
    //            0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 1.0
    //        };
    //        [cell.tagLabel setGradientColors:colors];
    
    cell.tagLabel.font = [UIFont systemFontOfSize:44];

    TagData *tagData = [self.userInfoTagArray objectAtIndex:indexPath.row];
        cell.tagLabel.text = tagData.tagName;
        
        int red = [tagData.tagColorRed intValue];
        int green = [tagData.tagColorGreen intValue];
        int blue = [tagData.tagColorBlue intValue];
        int alpha = [tagData.tagColorAlpha intValue];
        
    UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
//    }
    [cell addSubview:cell.tagLabel];
    UIImage *cellBackgroundImage = [UIImage imageNamed: @"list-background.png"];
    UIImage *coloredImage = [cellBackgroundImage imageWithTint: tagColor];
    
    [cell.cellBackgroundImageView  setImage: coloredImage];
    //        cell.tagLabel.backgroundColor = tagColor;
    
    return cell;
    //    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.userInfoTagTable setEditing:editing animated:YES];
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
    
//    TagData *tagData = [self.userInfoTagArray objectAtIndex:indexPath.row];
    self.userDataForMediaItem.tagData = nil;
    [mediaItemUserData updateTagForItem: self.userDataForMediaItem];
    
    self.userInfoTagArray = [NSArray arrayWithObjects: nil];
    [self loadDataForView];
    
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    TagData *tagData = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    [self.managedObjectContext deleteObject:tagData];
//    
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Couldn't delete entry: %@", error);
//        [[[UIAlertView alloc] initWithTitle:@"ERROR"
//                                    message:@"Couldn't delete entry"
//                                   delegate:nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil] show];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataChanged" object:nil];
//    
//}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}



//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.userTagTableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            [self.userTagTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            //set a flag so that table can be scrolled after the updates happen other wise crashes with out of bounds index
//            newTagInserted = YES;
//            //            savedIndexPath = newIndexPath;
//            //            [self.userTagTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.userTagTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self.userTagTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.userTagTableView endUpdates];
//    
//}


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

- (IBAction) selectNewTag {

    [self performSegueWithIdentifier: @"SelectTag" sender: self];
}

- (void)userTagViewControllerDidCancel:(UserTagViewController *)controller
{
    //need to reload on return so that selected tag is shown
    [self setEditingUserInfo: NO];
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