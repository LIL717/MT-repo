//
//  NotesTabBarController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
#import <QuartzCore/CALayer.h>

@class SongInfo;
@class SongInfoViewController;
@class NotesViewController;
@class NotesTabBarController;

@protocol NotesTabBarControllerDelegate <NSObject>

- (void)notesTabBarControllerDidCancel: (NotesTabBarController *)controller;

@end

@interface NotesTabBarController : UITabBarController <MPMediaPickerControllerDelegate, UITabBarControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, weak) id <NotesTabBarControllerDelegate> notesDelegate;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;
@property (nonatomic, strong)   SongInfoViewController *songInfoViewController;
@property (nonatomic, strong)   NotesViewController *notesViewController;
@property (readwrite)           BOOL                    iPodLibraryChanged;

- (UILabel *) customizeTitleView;

@end
