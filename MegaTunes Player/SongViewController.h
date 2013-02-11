//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
#import "NotesTabBarController.h"


@interface SongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NotesTabBarControllerDelegate,MPMediaPickerControllerDelegate> {
  
    NSManagedObjectContext *managedObjectContext;

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   MPMediaItem *mediaItemForInfo;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;
@property (readwrite)           BOOL iPodLibraryChanged;

- (void) notesTabBarControllerDidCancel:(NotesTabBarController *)controller;


@end