//
//  NotesViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

@interface NotesViewController : UIViewController <NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext  *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;


@end
