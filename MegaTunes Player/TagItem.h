//
//  UserTaggItem.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/10/13.
//
//

@interface TagItem : NSObject

@property (nonatomic, retain) NSString *tagName;
@property (nonatomic, retain) NSNumber *tagColorRed;
@property (nonatomic, retain) NSNumber *tagColorGreen;
@property (nonatomic, retain) NSNumber *tagColorBlue;
@property (nonatomic, retain) NSNumber *tagColorAlpha;
@property (nonatomic, retain) NSNumber *sortOrder;

@end
