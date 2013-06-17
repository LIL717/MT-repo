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
@property (nonatomic, strong)   NSArray *songInfoData;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) UIImage *albumImage;

- (void) loadArrayForTable;

@end
