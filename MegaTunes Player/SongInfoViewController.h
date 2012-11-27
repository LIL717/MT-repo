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
    IBOutlet UIScrollView *scrollView;
    
}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;

@property (nonatomic, retain) UIView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *infoTableView;

@property (nonatomic, strong)   NSArray *songInfoData;
//@property (nonatomic, weak)   CGFloat tableWidth;



@end
