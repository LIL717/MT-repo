//
//  Track.h
//  podradio
//
//  Created by Tope on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject


@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *length;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) UIImage *albumImageLarge;


-(id)initWithName:(NSString*)theName 
    andArtistName:(NSString*)theArtist 
         andImage:(UIImage*)theImage 
    andLargeImage:(UIImage*)theLargeImage 
        andLength:(NSString*)theLength 
         andGenre:(NSString*)genre;
@end
