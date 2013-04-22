//
//  WindowSubClass.h
//  MegaTunes Player
//
//  Created by Lori Hill on 4/2/13.
//
//

@protocol WindowSubClassDelegate
- (void)userTouchBegan:(id)tapPoint onView:(UIView*)aView;
- (void)userTouchMoved:(id)tapPoint onView:(UIView*)aView;
- (void)userTouchEnded:(id)tapPoint onView:(UIView*)aView;
@end

@interface WindowSubClass : UIWindow
@property (nonatomic, retain) UIView *viewToObserve;
@property (nonatomic, assign) id <WindowSubClassDelegate> controllerThatObserves;
@property (nonatomic, assign) CGPoint tapPoint;
@property (nonatomic, assign) NSValue *pointValue;
@end
