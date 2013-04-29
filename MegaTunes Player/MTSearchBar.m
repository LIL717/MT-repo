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


CGFloat ViewHeight = 55;
CGFloat ViewMargin = -5;
CGFloat TextfieldLeftMargin = 35;

CGFloat CancelAnimationDistance = 80;

@interface MTSearchBar (){
    UITextField *foundSearchTextField;
    UIButton *overlayCancelButton;
}

@end

@implementation MTSearchBar

- (void)dealloc {
        LogMethod();

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
        LogMethod();

    [super awakeFromNib];
    
    UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 7, 32, 32)];
    [searchIconView setImage: [UIImage imageNamed:@"searchIcon.png"]];
    [self addSubview: searchIconView];
    
    // find textfield in subviews
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];
        if ([subview.class isSubclassOfClass:[UITextField class]]) {
            foundSearchTextField = (UITextField *)subview;
        }
    }
    
    [self stylizeSearchTextField];
//    [self createButton];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalCancel) name:UITextFieldTextDidBeginEditingNotification object:foundSearchTextField];
}

- (void)setFrame:(CGRect)frame {
        LogMethod();

    frame.size.height = ViewHeight + (ViewMargin * 2) + 4;    [super setFrame:frame];
}

- (void)layoutSubviews {
        LogMethod();

    [super layoutSubviews];
    
    // resize textfield
    CGRect frame = foundSearchTextField.frame;
    frame.size.height = ViewHeight;
    frame.origin.y = ViewMargin;
    frame.origin.x = ViewMargin;
    frame.size.width -= ViewMargin / 2;
    foundSearchTextField.frame = frame;
}

- (void)stylizeSearchTextField {
        LogMethod();

    // Sets the background to a static black, and remove round edges
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];
        
        // This is the gradient behind the textfield
        if ([subview.description hasPrefix:@"<UISearchBarBackground"]) {
            [subview removeFromSuperview];
        }
    }
    
    // now change the search
    foundSearchTextField.borderStyle = UITextBorderStyleRoundedRect;
    foundSearchTextField.backgroundColor = [UIColor redColor];
    foundSearchTextField.background = nil;
    foundSearchTextField.text = @"";
    foundSearchTextField.clearButtonMode = UITextFieldViewModeNever;
    foundSearchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TextfieldLeftMargin, 0)];
    foundSearchTextField.placeholder = @"";
    UIFont *font = [UIFont systemFontOfSize:44];
    foundSearchTextField.font = font;
//    foundSearchTextField.textColor = [UIColor whiteColor];
}

//- (void)createButton {
//    LogMethod();
//
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
////    UIFont *font = [UIFont systemFontOfSize:14];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:44];
//    cancelButton.titleLabel.textColor = [UIColor darkGrayColor];
//    
//    
//    NSString *title = [@"X" uppercaseString];
//    [cancelButton setTitle:title forState:UIControlStateNormal];
//    [cancelButton setTitle:title forState:UIControlStateHighlighted];
//    
//    CGRect buttonFrame = cancelButton.frame;
//    buttonFrame.origin.y = ViewMargin - 1;
//    buttonFrame.size.height = ViewHeight;
//    buttonFrame.size.width = 66;
//    buttonFrame.origin.x = self.frame.size.width - buttonFrame.size.width - ViewMargin + CancelAnimationDistance;
//    cancelButton.frame = buttonFrame;
//    [cancelButton addTarget:self action:@selector(cancelSearchField) forControlEvents:UIControlEventTouchUpInside];
//    
//    overlayCancelButton = cancelButton;
//    [self addSubview:overlayCancelButton];
//    [self bringSubviewToFront:overlayCancelButton];
//}
//
//#pragma mark deal with the cancel button
//
//- (void)showCancelButton:(BOOL)show {
//    LogMethod();
//
//    CGFloat distance = show? -CancelAnimationDistance : CancelAnimationDistance;
//    [UIView animateWithDuration:0.25 animations:^{
//        overlayCancelButton.frame = CGRectOffset(overlayCancelButton.frame, distance, 0);
//    }];
//}
//
//- (void)removeOriginalCancel {
//    LogMethod();
//
//    // remove the original button
//    for (int i = [self.subviews count] - 1; i >= 0; i--) {
//        UIView *subview = [self.subviews objectAtIndex:i];
//        if ([subview.class isSubclassOfClass:[UIButton class]]) {
//            if (subview.frame.size.height != ViewHeight) {
//                subview.hidden = YES;
//            }
//        }
//    }
//}
//
//- (void)cancelSearchField {
//    LogMethod();
//
//    // tap the original button!
//    for (int i = [self.subviews count] - 1; i >= 0; i--) {
//        UIView *subview = [self.subviews objectAtIndex:i];
//        if ([subview.class isSubclassOfClass:[UIButton class]]) {
//            if (subview.frame.size.height != ViewHeight) {
//                UIButton *realCancel = (UIButton *)subview;
//                [realCancel sendActionsForControlEvents: UIControlEventTouchUpInside];
//            }
//        }
//    }
//}

@end
