//
//  Track.m
//  podradio
//
//  Created by Tope on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Track.h"

@implementation Track

@synthesize trackName, artistName, albumImage, length, albumImageLarge, genre;


-(id)initWithName:(NSString*)theName 
    andArtistName:(NSString*)theArtist 
         andImage:(UIImage*)theImage 
    andLargeImage:(UIImage*)theLargeImage 
        andLength:(NSString*)theLength
         andGenre:(NSString*)theGenre
{
    
    self = [super init];
    
    if(self)
    {
        self.trackName = theName;
        self.artistName = theArtist;
        self.albumImage = theImage;
        self.length = theLength;
        self.albumImageLarge = theLargeImage;
        self.genre = theGenre;
    }
    
    return self;
}
@end
