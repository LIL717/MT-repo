//
//  GenreViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/31/13.
//
//

@class CollectionItem;

@interface GenreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *collectionTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   NSArray *collection;
@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   NSIndexPath* saveIndexPath;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   NSMutableArray *collectionDataArray;
@property (nonatomic, strong)   NSArray *albumCollection;


- (NSNumber *) calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue;

@end
