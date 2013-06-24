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

@interface UserInfoViewController : UIViewController < UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UserTagViewControllerDelegate, NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext  *managedObjectContext_;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic)  UserDataForMediaItem *userDataForMediaItem;
@property (strong, nonatomic) IBOutlet UITableView *userInfoTagTable;
@property (strong, nonatomic) IBOutlet UITextView   *comments;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToTagConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToCommentsConstraint;

@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (readwrite)         BOOL             editingUserInfo;

@property (readwrite)                  CGFloat landscapeOffset;
@property (nonatomic, strong)   NSArray *userInfoTagArray;
@property (nonatomic, strong)   UIButton *tagButton;


- (void) loadDataForView;
- (void) userTagViewControllerDidCancel:(UserTagViewController *)controller;
@end