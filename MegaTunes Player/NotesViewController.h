//
//  NotesViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
@class SongInfo;

@interface NotesViewController : UIViewController <NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext  *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;


@property (strong, nonatomic) IBOutlet UILabel *bpm;
@property (strong, nonatomic) IBOutlet UILabel *userClassification;
@property (strong, nonatomic) IBOutlet UITextView *userNotes;


@end
