//
//  MediaGroupCarouselViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 5/31/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "MediaGroup.h"
#import "MediaGroupViewController.h"
#import "MediaGroupCarouselViewController.h"
@class AppDelegate;

@protocol MediaGroupCarouselViewControllerDelegate <NSObject>

- (void) viewController:(MediaGroupCarouselViewController *)controller didFinishLoadingSongArray:(NSArray *) array;

@end

@interface MediaGroupCarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, MPMediaPickerControllerDelegate, MediaGroupViewControllerDelegate> {
    
    NSManagedObjectContext  *managedObjectContext_;
}

@property (nonatomic, weak) id <MediaGroupCarouselViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong)   NSArray  *collection;
@property (nonatomic, strong)   NSArray *groupingData;  //+NSMutableArray *mediaGroupItems;
@property (nonatomic, strong)   MediaGroup *selectedGroup;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;
@property (nonatomic, strong)   AppDelegate *appDelegate;
@property (nonatomic, strong)   NSArray *songArray;
@property (nonatomic, strong)   NSMutableArray *tinySongMutableArray;
@property (nonatomic, strong)   NSArray *tinySongArray;


@property (nonatomic, strong)   NSNumber *playlistDuration;
@property (nonatomic, strong)   NSArray *sortedTaggedArray;
@property (nonatomic, strong)   NSNumber *taggedPlaylistDuration;
@property (readwrite)           BOOL collectionContainsICloudItem;
@property (readwrite)           BOOL songArrayLoaded;
@property (readwrite)           BOOL taggedSongArrayLoaded;
@property (readwrite)           BOOL tinySongArrayLoaded;
@property (nonatomic, strong)   UIAlertView *loadingAlert;



@property (nonatomic, strong)   UIImage *initialLandscapeImage;
@property (nonatomic, strong)   MediaGroupViewController *mediaGroupViewController;

- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingSongArray:(NSArray *) array;
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTinySongArray:(NSArray *) array;
- (void) viewController:(MediaGroupViewController *)controller didFinishLoadingTaggedSongArray:(NSArray *) array;

@end