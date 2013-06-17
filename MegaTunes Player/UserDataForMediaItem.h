//
//  UserDataForMediaItem.h
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
#import "TagItem.h"
#import "TagData.h"

@interface UserDataForMediaItem : NSObject

@property (nonatomic, retain) NSString * title;
//@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) TagData * tagData;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSNumber * bpm;

@end
