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
@property (nonatomic, copy) MPMediaItemCollection *collection;



@end
