//
//  DataLoader.m
//  podradio
//
//  Created by Tope on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataLoader.h"
#import "Track.h"


@implementation DataLoader


+(NSArray*)loadSampleData
{
    Track* track = [[Track alloc] initWithName:@"Love the way you lie" andArtistName:@"Eminem feat. Rihanna" andImage:[UIImage tallImageNamed:@"album-small.jpg"] andLargeImage:[UIImage tallImageNamed:@"album-large.jpg"] andLength:@"3 mins 46 secs" andGenre:@"Hip Hop"];
                    

    Track* track2 = [[Track alloc] initWithName:@"The Fame" andArtistName:@"Lady Gaga" andImage:[UIImage tallImageNamed:@"ipad-album-small-1.png"] andLargeImage:[UIImage tallImageNamed:@"ipad-album-large-1.png"] andLength:@"4 mins 20 secs" andGenre:@"Dance"];
    
    Track* track3 = [[Track alloc] initWithName:@"Speed of Sound" andArtistName:@"Coldplay" andImage:[UIImage tallImageNamed:@"ipad-album-small-2.png"] andLargeImage:[UIImage tallImageNamed:@"ipad-album-large-2.png"] andLength:@"4 mins 20 secs" andGenre:@"Dance"];
    
    Track* track4 = [[Track alloc] initWithName:@"I am Sasha - Fierce" andArtistName:@"Beyonce" andImage:[UIImage tallImageNamed:@"ipad-album-small-3.png"] andLargeImage:[UIImage tallImageNamed:@"ipad-album-large-3.png"] andLength:@"3 mins 35 secs" andGenre:@"Dance"];
        
    NSArray* tracks = [NSArray arrayWithObjects:track, track2, track3, track4, nil];
    
    return tracks;

        
}



@end
