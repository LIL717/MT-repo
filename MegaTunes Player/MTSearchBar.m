//
//  MTSearchBar.m
//  MegaTunes Player
//
//  Created by Lori Hill on 4/28/13.
//
//  Created by orta therox on 18/04/2012.
//  Released under The MIT License
//  http://www.opensource.org/licenses/mit-license.php
//
//  Created by orta therox on 18/04/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//
#import "MTSearchBar.h"
#import "UIImage+AdditionalFunctionalities.h"


CGFloat ViewHeight = 50;
CGFloat ViewMargin = 2;
CGFloat TextfieldLeftMargin = 35;

CGFloat CancelAnimationDistance = 80;

@interface MTSearchBar (){
    UITextField *searchTextField;
    UIButton *overlayCancelButton;
}

@end

@implementation MTSearchBar

- (void)dealloc {
//        LogMethod();

//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
//        LogMethod();

    [super awakeFromNib];
    
    // find textfield in subviews
    for (int i = (int)[self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];
        if ([subview.class isSubclassOfClass:[UITextField class]]) {
            searchTextField = (UITextField *)subview;
        }
    }
    // set the search Icon to a larger magifying glass
    UIImage *image = [UIImage imageNamed: @"searchIcon.png"];
    UIImageView *iView = [[UIImageView alloc] initWithImage:image];
    searchTextField.leftView = iView;
    
    //set font size to 44
    searchTextField.font = [UIFont systemFontOfSize:44];

//    [self stylizeSearchTextField];
//    [self createButton];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalCancel) name:UITextFieldTextDidBeginEditingNotification object:foundSearchTextField];
}

- (void)setFrame:(CGRect)frame {
//        LogMethod();

    frame.size.height = ViewHeight + (ViewMargin * 2) + 4;    [super setFrame:frame];
}

- (void)layoutSubviews {
//        LogMethod();

    [super layoutSubviews];
    
    // resize textfield
    CGRect frame = searchTextField.frame;
    frame.size.height = ViewHeight;
    frame.origin.y = ViewMargin;
    frame.origin.x = ViewMargin;
    frame.size.width -= ViewMargin / 2;
    searchTextField.frame = frame;
}
- (void) addSubview:(UIView *)view {
    [super addSubview:view];
    
    if ([view isKindOfClass:UIButton.class]) {
        UIButton *cancelButton = (UIButton *)view;
        
//        CGRect contentRect = [cancelButton contentRectForBounds: cancelButton.frame];
//        CGRect imageRect = [cancelButton backgroundRectForBounds: contentRect];
//        NSLog (@"contentRect is %f x %f", contentRect.size.width, contentRect.size.height);
//        NSLog (@"imageRect is %f x %f", imageRect.size.width, imageRect.size.height);
        //48 x 30
        //center frame of new cancel button
        cancelButton.contentEdgeInsets = UIEdgeInsetsMake(-9, -6, -9, 6);
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(-9, -6, -9, 6);

        [cancelButton setImage: [UIImage imageNamed: @"cancel_white.png"] forState:UIControlStateNormal];
        
        UIImage *coloredImage = [[UIImage imageNamed: @"cancel_white.png"] imageWithTint:[UIColor darkGrayColor]];
        [cancelButton setImage: coloredImage forState:UIControlStateHighlighted];
        [cancelButton setTitle: @"" forState: UIControlStateNormal];
        [cancelButton setBackgroundImage: nil forState: UIControlStateNormal];
        [cancelButton setBackgroundImage: nil forState: UIControlStateHighlighted];

    }
}

@end
