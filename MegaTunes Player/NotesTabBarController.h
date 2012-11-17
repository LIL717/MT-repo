//
//  NotesTabBarController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
@class SongInfo;

@interface NotesTabBarController : UITabBarController <MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;

}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;

@end
