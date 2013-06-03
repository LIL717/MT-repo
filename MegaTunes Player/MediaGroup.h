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
@property (nonatomic, copy) UIImage *collectionImage;
@property (nonatomic, copy) MPMediaQuery *queryType;

-(id)initWithName:(NSString*)theName andImage:(UIImage*)theImage andQueryType:(MPMediaQuery*)theQueryType;

@end
