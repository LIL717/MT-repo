//
//  SongInfo.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

@interface SongInfo : NSObject

@property (nonatomic, strong) IBOutlet UILabel *songName;
@property (nonatomic, strong) IBOutlet UILabel *album;
@property (nonatomic, strong) IBOutlet UILabel *artist;
@property (nonatomic, strong) IBOutlet UIImageView *albumImage;

//@property (nonatomic, strong) IBOutlet UILabel *duration;
//@property (strong, nonatomic) IBOutlet UILabel *BPM;

@end
