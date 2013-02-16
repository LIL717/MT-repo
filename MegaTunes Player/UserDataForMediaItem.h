//
//  SongInfo.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

@interface UserDataForMediaItem : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userGrouping;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSNumber * bpm;

@end
