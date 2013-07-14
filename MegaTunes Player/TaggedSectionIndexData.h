//
//  TaggedSectionIndexData.h
//  MegaTunes Player
//
//  Created by Lori Hill on 7/14/13.
//
//

#import <Foundation/Foundation.h>

@interface TaggedSectionIndexData : NSObject

@property (nonatomic, strong) NSString *sectionIndexTitle;
@property (nonatomic) NSRange sectionRange;
@property (nonatomic) NSUInteger sectionIndexTitleIndex;

@end
