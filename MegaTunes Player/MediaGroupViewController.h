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

@interface MediaGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UINavigationControllerDelegate> {

    NSManagedObjectContext  *managedObjectContext_;
}

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

@property (nonatomic, strong)   UIImage *initialPortraitImage;
@property (nonatomic, strong)   UIImage *initialLandscapeImage;




@end


