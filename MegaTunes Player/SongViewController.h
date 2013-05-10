//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
#import "InfoTabBarController.h"


@interface SongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InfoTabBarControllerDelegate, MPMediaPickerControllerDelegate> {
  
    NSManagedObjectContext *managedObjectContext;

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)   MPMediaItemCollection *collectionOfOne;

@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   MPMediaItem *mediaItemForInfo;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;



- (void) infoTabBarControllerDidCancel:(InfoTabBarController *)controller;


@end