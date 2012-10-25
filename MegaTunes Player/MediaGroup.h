//
//  MediaGroup.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import <Foundation/Foundation.h>


@interface MediaGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) MPMediaQuery *queryType;

-(id)initWithName:(NSString*)theName
    andQueryType:(MPMediaQuery*)theQueryType;

@end
