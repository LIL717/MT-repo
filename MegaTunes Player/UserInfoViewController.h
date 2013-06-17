//
//  UserInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/14/13.
//
//

@class UserDataForMediaItem;
@class KSLabel;
#import "UserTagViewController.h"

@interface UserInfoViewController : UIViewController <MPMediaPickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UserTagViewControllerDelegate, NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext  *managedObjectContext_;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic)  UserDataForMediaItem *userDataForMediaItem;
@property (strong, nonatomic) IBOutlet UIButton *userTagButton;
@property (strong, nonatomic) IBOutlet UITextView   *comments;
@property (strong, nonatomic) IBOutlet KSLabel *tagLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToTagConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToCommentsConstraint;

@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (readwrite)         BOOL             editingUserInfo;

@property (readwrite)                  CGFloat landscapeOffset;

- (void) loadDataForView;
- (void) userTagViewControllerDidCancel:(UserTagViewController *)controller;
@end