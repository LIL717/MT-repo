//
//  NotesViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
#import <AVFoundation/AVFoundation.h>
@class UserDataForMediaItem;


@interface NotesViewController : UIViewController <NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate, NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext  *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic)  UserDataForMediaItem *userDataForMediaItem;
@property (strong, nonatomic) IBOutlet UILabel      *bpm;
@property (strong, nonatomic) IBOutlet UITextField  *userClassification;
@property (strong, nonatomic) IBOutlet UITextView   *userNotes;
@property (strong, nonatomic) IBOutlet UILabel      *lastPlayedDate;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceToTop;

@end
