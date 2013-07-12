//
//  MediaGroupTableViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroup.h"
@class MediaGroupCarouselViewController;
@class AppDelegate;
@class MediaGroupViewController;

@protocol MediaGroupViewControllerDelegate <NSObject>
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingArray:(NSMutableArray *) array;
@end

@interface MediaGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UINavigationControllerDelegate> {

    NSManagedObjectContext  *managedObjectContext_;
}
@property (nonatomic, weak) id <MediaGroupViewControllerDelegate> delegate;

@property (strong, nonatomic)   IBOutlet UITableView *groupTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong)   NSArray  *collection;
@property (nonatomic, strong)   NSArray *groupingData;
@property (nonatomic, strong)   MediaGroup *selectedGroup;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (readwrite)           BOOL isShowingLandscapeView;
@property (readwrite)           BOOL initialView;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
@property (nonatomic, strong)   MediaGroupCarouselViewController *mediaGroupCarouselViewController;
@property (nonatomic, strong)   UIImageView *pView;
@property (nonatomic, strong)   UIImageView *lView;
@property (nonatomic, strong)   AppDelegate *appDelegate;
@property (nonatomic, strong)   NSMutableArray *songMutableArray;
@property (nonatomic, strong)   NSMutableArray *tinySongMutableArray;

@property (nonatomic, strong)   NSNumber *playlistDuration;
@property (nonatomic, strong)   NSMutableArray *taggedSongArray;
@property (nonatomic, strong)   NSNumber *taggedPlaylistDuration;
@property (readwrite)           BOOL collectionContainsICloudItem;

@property (nonatomic, strong)   UIImage *initialPortraitImage;
@property (nonatomic, strong)   UIImage *initialLandscapeImage;


- (void)hideActivityIndicator;


@end


