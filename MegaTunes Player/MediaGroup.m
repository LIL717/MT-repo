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
@synthesize groupingType;

-(id)initWithName:(NSString*)theName
    andGroupingType:(MPMediaQuery*)theGroupingType

{
    
    self = [super init];
    
    if (self)
    {
        self.name = theName;
        self.groupingType = theGroupingType;
    }
    
    return self;
}

@end
