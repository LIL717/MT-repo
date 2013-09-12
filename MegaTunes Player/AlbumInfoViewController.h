//
//  AlbumInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

@interface AlbumInfoViewController : UIViewController  < UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
    
}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   MPMediaItem *mediaItemForInfo;


@property (strong, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@property (nonatomic, strong)   NSMutableArray *songInfoData;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) UIImage *albumImage;

@property (strong, nonatomic) IBOutlet NSString *lastPlayedDate;
@property (strong, nonatomic) NSString *lastPlayedDateTitle;
@property (strong, nonatomic) IBOutlet NSString *bpm;
@property (strong, nonatomic) IBOutlet NSString *userGrouping;
@property (strong, nonatomic) NSString *userGroupingTitle;
@property (strong, nonatomic) NSNumber *saveBPM;

@property (strong, nonatomic) UITextView *comments;

//130909 1.1 add iTunesStoreButton begin
@property (strong, nonatomic) NSString *iTunesStoreSelector;
@property (strong, nonatomic) NSString *artistLinkUrl;
@property (strong, nonatomic) NSString *albumLinkUrl;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *artistNameFormatted;
@property (strong, nonatomic) NSString *iTunesLinkUrl;

//130909 1.1 add iTunesStoreButton end

- (void) loadTableData;

@end
