//
//  NotesViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

@interface NotesViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext  *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
