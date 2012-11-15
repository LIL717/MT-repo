//
//  MegaNavigationBar.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/1/12.
//
//

#import "MegaNavigationBar.h"
#import <objc/runtime.h>
//#import "ColorSwitcher.h"


//@implementation MegaNavigationBar
//
//- (void) didMoveToSuperview {
//    if( [self respondsToSelector: @selector(setBackgroundImage:forBarMetrics:)]) {
//        //iOS5.0 and above has a system defined method -> use it
//        [self setBackgroundImage: [UIImage imageNamed: @"megaMenu-bar"]
//                   forBarMetrics: UIBarMetricsDefault];
//    }
//    else {
//        //iOS4.0 requires us to override drawRect:. BUT!!
//        //If you override drawRect: on iOS5.0 the system default will break,
//        //so we dynamically add this method if required
//        IMP implementation = class_getMethodImplementation([self class], @selector(iOS4drawRect:));
//        class_addMethod([self class], @selector(drawRect:), implementation, "v@:{name=CGRect}");
//    }
//}
//
//- (void)iOS4drawRect: (CGRect) rect {
//    UIImage* bg = [UIImage imageNamed:@"megaMenu-bar"];
//    [bg drawInRect: rect];
//}
//
//@end
//
@implementation MegaNavigationBar
@synthesize backgroundImage = _backgroundImage;

-(void) setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImage != backgroundImage)
    {
        _backgroundImage = backgroundImage;
        [self setNeedsDisplay];
    }
}

-(void) drawRect:(CGRect)rect
{
    // This is how the custom BG image is actually drawn
    [self.backgroundImage drawInRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    // This is how you set the custom size of your UINavigationBar
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGSize newSize = CGSizeMake(frame.size.width , self.backgroundImage.size.height);
    return newSize;
}
//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize newSize = CGSizeMake(self.bounds.size.width, kNavigationBarHeight);
//    return newSize;
//}
@end


