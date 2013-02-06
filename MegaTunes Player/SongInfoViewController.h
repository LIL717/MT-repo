//
//  SongInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
@class SongInfo;

@interface SongInfoViewController : UIViewController  < UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
    
}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;

@property (strong, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@property (nonatomic, strong)   NSArray *songInfoData;



@end
