//
//  UINavigationController+MaskAll.m
//  MegaTunes Player
//
//  Created by Lori Hill on 3/14/13.
//
//
//need this category to allow rotation to upside down in ios 6

#import "UINavigationController+MaskAll.h"

@implementation UINavigationController (MaskAll)

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//need to override this method to allow selective locking to prevent autorotation in a particular view
//-(BOOL)shouldAutorotate {
//    UIViewController *top = self.topViewController;
//    return [top shouldAutorotate];
//}
@end