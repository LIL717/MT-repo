//
//  Playlists.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/21/12.
//
//

#import <Foundation/Foundation.h>

@interface Songlist : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic, copy) UIImage *artwork;

@end
