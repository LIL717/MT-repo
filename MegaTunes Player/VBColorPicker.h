//
//  VBColorPicker.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/18/14.
//
//

#import <UIKit/UIKit.h>

@interface VBColorPicker : UIImageView

@property BOOL hideAfterSelection; // default YES
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly, retain) UIColor* lastSelectedColor;


- (void) showPicker;
- (void) hidePicker;
- (void) showPickerWithDuration:(float)duration;
- (void) hidePickerWithDuration:(float)duration;
- (void) animateColorWheelToShow:(BOOL)show duration:(float)duration;

@end


@protocol VBColorPickerDelegate <NSObject>

- (void) pickedColor:(UIColor *)color;


@end
