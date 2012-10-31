//
//  MediaItemUserData.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

@interface MediaItemUserData : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *playbackDuration;
@property (nonatomic, retain) NSString *userClassification;
@property (nonatomic, retain) NSString *userNotes;

@end