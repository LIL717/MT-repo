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
@class MediaGroupViewController;
@class AppDelegate;



@interface MediaGroupCarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, MPMediaPickerControllerDelegate> {
    
    NSManagedObjectContext  *managedObjectContext_;
}

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


@property (nonatomic, strong)   UIImage *initialLandscapeImage;
@property (nonatomic, strong)   MediaGroupViewController *mediaGroupViewController;

@end