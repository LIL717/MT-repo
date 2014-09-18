//
//  UINavigationController+MaskAll.h
//  MegaTunes Player
//
//  Created by Lori Hill on 3/14/13.
//
//
//need this category to allow rotation to upside down in ios 6

@interface UINavigationController (MaskAll)

-(NSUInteger)supportedInterfaceOrientations;
//-(BOOL)shouldAutorotate;


@end
