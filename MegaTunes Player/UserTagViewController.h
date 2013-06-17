//
//  UserTagViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//
@class MTSearchBar;
@class UserDataForMediaItem;
@class UserTagViewController;
#import "AddTagViewController.h"

@protocol UserTagViewControllerDelegate <NSObject>

- (void)userTagViewControllerDidCancel: (UserTagViewController *)controller;

@end

@interface UserTagViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddTagViewControllerDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
    
}

@property (strong, nonatomic) IBOutlet UITableView *userTagTableView;
@property (strong, nonatomic)   IBOutlet UIView *searchView;
@property (strong, nonatomic)   IBOutlet MTSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <UserTagViewControllerDelegate> userTagViewControllerDelegate;

//@property (readwrite)           BOOL iPodLibraryChanged;
@property (readwrite)           BOOL isSearching;
@property (nonatomic, strong)   NSArray *searchResults;
@property (nonatomic, strong)   UserDataForMediaItem *userDataForMediaItem;

- (void)addTagViewControllerDidCancel:(AddTagViewController *)controller;

@end