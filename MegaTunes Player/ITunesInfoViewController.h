//
//  ITunesInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
#import <AVFoundation/AVFoundation.h>
@class UserDataForMediaItem;

@interface ITunesInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {
    
    NSManagedObjectContext  *managedObjectContext_;
}

@property (nonatomic, retain)   NSManagedObjectContext      *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic) IBOutlet UITableView *infoTableView;
@property (nonatomic, strong)   NSArray *songInfoData;

@property (strong, nonatomic) IBOutlet NSString *lastPlayedDate;
@property (strong, nonatomic) NSString *lastPlayedDateTitle;
@property (strong, nonatomic) IBOutlet NSString *bpm;
@property (strong, nonatomic) IBOutlet NSString *userGrouping;
@property (strong, nonatomic) NSString *userGroupingTitle;
@property (strong, nonatomic) NSNumber *saveBPM;

- (void) loadTableData;

@end
