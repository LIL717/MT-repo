//
//  InfoTabBarController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
#import <QuartzCore/CALayer.h>

@class InfoTabBarController;
@class AlbumInfoViewController;
//@class ITunesInfoViewController;
@class ITunesCommentsViewController;
@class UserInfoViewController;

@protocol InfoTabBarControllerDelegate <NSObject>

- (void)infoTabBarControllerDidCancel: (InfoTabBarController *)controller;

@end

@interface InfoTabBarController : UITabBarController <MPMediaPickerControllerDelegate, UITabBarControllerDelegate> {
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, weak) id <InfoTabBarControllerDelegate> infoDelegate;

@property (nonatomic, retain)   NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;

@property (nonatomic, strong)   AlbumInfoViewController  *albumInfoViewController;
//@property (nonatomic, strong)   ITunesInfoViewController *iTunesInfoViewController;
@property (nonatomic, strong)   ITunesCommentsViewController *iTunesCommentsViewController;
@property (nonatomic, strong)   UserInfoViewController *userInfoViewController;

@property (readwrite)           BOOL                    iPodLibraryChanged;
@property (readwrite)           BOOL                    viewingNowPlaying;
@property (nonatomic, strong)   MPMediaItem             *mediaItemForInfo;
@property (nonatomic, strong)   UIBarButtonItem         *playBarButton;
@property (strong, nonatomic)   UIBarButtonItem         *checkMarkButton;

@property (readwrite)           BOOL                    showPlayButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem  *rightBarButton;

@property (nonatomic, retain)   NSTimer *playbackTimer;
@property (readwrite)           BOOL                    showTimeLabels;
@property (nonatomic, retain)   UIBarButtonItem         *elapsedTimeButton;
@property (nonatomic, retain)   UIBarButtonItem         *remainingTimeButton;
@property (nonatomic, retain)   NSString                *saveTitle;
@property (readwrite)           BOOL                    mainViewIsSender;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftRight;






- (UILabel *) customizeTitleView;
- (void) saveTextViewData;



@end
