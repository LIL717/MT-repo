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

@synthesize verticalSpaceToTop;
@synthesize verticalSpaceToTop28;

@synthesize placeholderLabel;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
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
    
    // initialize placeholder text
//    self.placeholderText = NSLocalizedString(@"Enter Notes", nil);
    self.comments.delegate = self;
    if (self.userDataForMediaItem.comments) {
        self.comments.text = self.userDataForMediaItem.comments;
        [self.placeholderLabel setHidden:YES];
//    } else {
//        self.comments.text = self.placeholderText;
//        self.isPlaceholder = YES;
//        self.comments.textColor = [UIColor lightGrayColor];
//        [self.comments setSelectedRange:NSMakeRange(0, 0)];
    }


    [self updateLayoutForNewOrientation: self.interfaceOrientation];

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

- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}
#pragma mark textField Delegate Methods________________________________

- (void) textFieldDidBeginEditing: (UITextField *) textField {
    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor darkGrayColor]];
    [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
}


- (void) textFieldDidEndEditing: (UITextField *) textField {
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
    
}
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark textView Delegate Methods________________________________

- (void) textViewDidBeginEditing: (UITextView *) textView {
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
////- (void)scrollRangeToVisible:(NSRange)range
- (void) textViewDidEndEditing: (UITextView *) textView {
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end