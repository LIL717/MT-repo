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
@synthesize queryType;

-(id)initWithName:(NSString*)theName
    andQueryType:(MPMediaQuery*)theQueryType

{
    
    self = [super init];
    
    if (self)
    {
        self.name = theName;
        self.queryType = theQueryType;
    }
    
    return self;
}

@end
