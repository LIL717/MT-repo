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
@class ITunesInfoViewController;
@class ITunesCommentsViewController;
@class UserInfoViewController;

@protocol InfoTabBarControllerDelegate <NSObject>

- (void)infoTabBarControllerDidCancel: (InfoTabBarController *)controller;

@end

@interface InfoTabBarController : UITabBarController <MPMediaPickerControllerDelegate, UITabBarControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, weak) id <InfoTabBarControllerDelegate> infoDelegate;

@property (nonatomic, retain)   NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;

@property (nonatomic, strong)   AlbumInfoViewController  *albumInfoViewController;
@property (nonatomic, strong)   ITunesInfoViewController *iTunesInfoViewController;
@property (nonatomic, strong)   ITunesCommentsViewController *iTunesCommentsViewController;
@property (nonatomic, strong)   UserInfoViewController *userInfoViewController;

@property (readwrite)           BOOL                    iPodLibraryChanged;
@property (readwrite)           BOOL                    viewingNowPlaying;
@property (nonatomic, strong)   MPMediaItem             *mediaItemForInfo;

- (UILabel *) customizeTitleView;


@end
