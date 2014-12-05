//
//  UserTagViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//
@class UserDataForMediaItem;
@class UserTagViewController;
#import "FMMoveTableView.h"
#import "AddTagViewController.h"

@protocol UserTagViewControllerDelegate <NSObject>

- (void)userTagViewControllerDidCancel: (UserTagViewController *)controller;

@end

@interface UserTagViewController : UIViewController <AddTagViewControllerDelegate, NSFetchedResultsControllerDelegate, FMMoveTableViewDataSource, FMMoveTableViewDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
    
}

@property (strong, nonatomic) IBOutlet FMMoveTableView *userTagTableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <UserTagViewControllerDelegate> userTagViewControllerDelegate;
@property (nonatomic, strong)   UserDataForMediaItem *userDataForMediaItem;

- (void)addTagViewControllerDidCancel:(AddTagViewController *)controller;


@end
