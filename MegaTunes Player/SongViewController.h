//
//  SongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
@class CollectionItem;

#import "InfoTabBarController.h"
#import "MediaGroupViewController.h"
#import "MediaGroupCarouselViewController.h"



@interface SongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InfoTabBarControllerDelegate, MPMediaPickerControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MediaGroupViewControllerDelegate, MediaGroupCarouselViewControllerDelegate> {
  
    NSManagedObjectContext *managedObjectContext_;

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;

@property (strong, nonatomic)   IBOutlet UIView *shuffleView;
@property (strong, nonatomic)   IBOutlet UIButton *shuffleButton;
@property (strong, nonatomic)   IBOutlet UISearchBar *searchBar;
//130912 1.1 add iTunesStoreButton begin
@property (strong, nonatomic)   IBOutlet UIButton *completeAlbumButton;
@property (strong, nonatomic)   NSString *collectionType;
//130912 1.1 add iTunesStoreButton end

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
@property (nonatomic, strong)   UIBarButtonItem *playBarButton;
@property (nonatomic, strong)   UIBarButtonItem *tagBarButton;
@property (nonatomic, strong)   UIBarButtonItem *colorTagBarButton;
@property (nonatomic, strong)   UIBarButtonItem *noColorTagBarButton;

//@property (nonatomic, strong)   NSString *collectionType;
@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
//@property (nonatomic, strong)   MPMediaPropertyPredicate *collectionPredicate;
@property (nonatomic, strong)   NSArray *searchResults;
@property (nonatomic, strong)   CollectionItem *collectionItemToSave;
@property (readwrite)           BOOL showTagButton;
@property (readwrite)           BOOL showTags;
@property (nonatomic, strong)   NSString *songViewTitle;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftRight;
//@property (nonatomic, retain) UIColor *sectionIndexColor;
@property (nonatomic)           BOOL collectionContainsICloudItem;
@property (readwrite)           BOOL cellScrolled;
@property (readwrite)           BOOL songShuffleButtonPressed;
@property (readwrite)           BOOL tinyArray;
@property (nonatomic, weak)     MediaGroupViewController *mediaGroupViewController;
@property (nonatomic, weak)     MediaGroupCarouselViewController *mediaGroupCarouselViewController;


//130909 1.1 add iTunesStoreButton begin
@property (strong, nonatomic) NSString *iTunesStoreSelector;
@property (strong, nonatomic) NSString *artistLinkUrl;
@property (strong, nonatomic) NSString *albumLinkUrl;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *albumNameFormatted;
@property (strong, nonatomic) NSString *artistNameFormatted;
@property (strong, nonatomic) NSString *songNameFormatted;
@property (strong, nonatomic) NSString *iTunesLinkUrl;

//130909 1.1 add iTunesStoreButton end





- (void) infoTabBarControllerDidCancel:(InfoTabBarController *)controller;
//- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingSongArray:(NSArray *) array;
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTinySongArray:(NSArray *) array;
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTaggedSongArray:(NSArray *) array;
- (void) viewController:(id) controller didFinishLoadingSongArray:(NSArray *)array;


- (IBAction)playWithShuffle:(id)sender;


@end