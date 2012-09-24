//
//  Playlists.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/21/12.
//
//

#import <Foundation/Foundation.h>

@interface Playlist : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) UIImage *cover;

@end
