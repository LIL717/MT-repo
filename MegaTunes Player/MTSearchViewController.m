//
//  MTSearchViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 4/28/13.
//
//
//  Created by orta therox on 18/04/2012.
//  Released under The MIT License
//  http://www.opensource.org/licenses/mit-license.php
//
#import "MTSearchViewController.h"
#import "MTSearchBar.h"

@implementation MTSearchViewController

@synthesize searchBar;

//Our custom search view needs to know when to show / hide the cancel button
//- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//    LogMethod();
//
//    [self.searchBar showCancelButton:YES];
//    [UIView animateWithDuration:0.2 animations:^{
//        //commented out til I can figure out what it does
////        searchPlaceholderLabel.alpha = 0;
//    }];
//}
//
//- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    LogMethod();
//
//    [self.searchBar showCancelButton:NO];
//    [UIView animateWithDuration:0.2 animations:^{
//        //commented out til I can figure out what it does
////        searchPlaceholderLabel.alpha = 1;
//    }];
//}

@end
