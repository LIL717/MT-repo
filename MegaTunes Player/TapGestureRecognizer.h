//
//  TapGestureRecognizer.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/19/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface TapGestureRecognizer : UITapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action;


@end
