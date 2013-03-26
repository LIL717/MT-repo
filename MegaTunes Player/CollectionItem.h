//
//  CollectionItem.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/26/12.
//
//

#import <Foundation/Foundation.h>

@interface CollectionItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic, copy) NSDate *lastPlayedDate;
@property (nonatomic, copy) MPMediaItemCollection *collection;
//need to pass data in the collectionArray until it is certain that the array will not have 0 items, then data is copied into the MPMediaItemCollection   collection is saved in Core Data, collectionArray is not
@property (nonatomic, copy) NSMutableArray *collectionArray;
@end
