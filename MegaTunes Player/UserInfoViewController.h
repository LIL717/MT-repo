//
//  UserInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/14/13.
//
//

@class UserDataForMediaItem;

@interface UserInfoViewController : UIViewController <MPMediaPickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate> {
    
    NSManagedObjectContext  *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic)  UserDataForMediaItem *userDataForMediaItem;
@property (strong, nonatomic) IBOutlet UITextField  *userGrouping;
@property (strong, nonatomic) IBOutlet UITextView   *comments;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceToTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceToTop28;

@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;

- (void) loadDataForView;
@end