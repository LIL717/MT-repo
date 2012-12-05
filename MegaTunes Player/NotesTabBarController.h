//
//  NotesTabBarController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
@class SongInfo;
@class SongInfoViewController;
@class NotesViewController;

@interface NotesTabBarController : UITabBarController <MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;

}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;
@property (nonatomic, strong)   SongInfoViewController *songInfoViewController;
@property (nonatomic, strong)   NotesViewController *notesViewController;

@end