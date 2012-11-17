//
//  SongInfoViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
@class SongInfo;

@interface SongInfoViewController : UIViewController  <MPMediaPickerControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
    
}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   SongInfo *songInfo;

@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) IBOutlet UILabel *album;
@property (strong, nonatomic) IBOutlet UIImageView *albumImage;


@end
