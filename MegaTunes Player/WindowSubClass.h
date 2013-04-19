//
//  WindowSubClass.h
//  MegaTunes Player
//
//  Created by Lori Hill on 4/2/13.
//
//

#import <UIKit/UIKit.h>

@interface WindowSubClass : UIWindow

@property (nonatomic, strong) NSMutableSet *beganTouches;
@property (nonatomic, strong) NSMutableSet *endTouches;
@property (nonatomic, strong) NSMutableSet *cancelTouches;
@property (nonatomic, strong) NSMutableSet *moveTouches;
@property (nonatomic, strong) UIResponder *touchesObserver;
@end
