//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;
@class MTSearchBar;

#import "InfoTabBarController.h"


@interface SongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InfoTabBarControllerDelegate, MPMediaPickerControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
  
    NSManagedObjectContext *managedObjectContext;

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (strong, nonatomic)   IBOutlet UIView *shuffleView;
@property (strong, nonatomic)   IBOutlet UIButton *shuffleButton;
@property (strong, nonatomic)   IBOutlet MTSearchBar *searchBar;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)   MPMediaItemCollection *collectionOfOne;

@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   MPMediaItem *mediaItemForInfo;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (readwrite)           BOOL listIsAlphabetic;
@property (readwrite)           BOOL isSearching;
@property (nonatomic, retain)   MPMediaItemCollection *songCollection;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
//@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
//@property (nonatomic, strong)   MPMediaPropertyPredicate *collectionPredicate;
@property (nonatomic, strong)   NSArray *searchResults;
@property (nonatomic, strong)   CollectionItem *collectionItemToSave;




- (void) infoTabBarControllerDidCancel:(InfoTabBarController *)controller;
- (IBAction)playWithShuffle:(id)sender;


@end