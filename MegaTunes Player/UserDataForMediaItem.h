//
//  SongInfo.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

@interface UserDataForMediaItem : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userClassification;
@property (nonatomic, retain) NSString * userNotes;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSDate   * lastPlayedDate;
@property (nonatomic, retain) NSNumber * bpm;

@end
