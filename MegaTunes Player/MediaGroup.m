//
//  MediaGroup.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroup.h"

@implementation MediaGroup

@synthesize name;
@synthesize collectionImage;
@synthesize queryType;

-(id)initWithName:(NSString*)theName andImage: (UIImage*) theCollectionImage
     andQueryType:(MPMediaQuery*)theQueryType

{
    
    self = [super init];
    
    if (self)
    {
        self.name = theName;
        self.collectionImage = theCollectionImage;
        self.queryType = theQueryType;
    }
    
    return self;
}

@end
