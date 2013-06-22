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
#import "FMMoveTableView.h"
#import "AddTagViewController.h"

@protocol UserTagViewControllerDelegate <NSObject>

- (void)userTagViewControllerDidCancel: (UserTagViewController *)controller;

@end



//@interface UserTagViewController : UIViewController < UISearchBarDelegate, AddTagViewControllerDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, FMMoveTableViewDataSource, FMMoveTableViewDelegate> {
@interface UserTagViewController : UIViewController <AddTagViewControllerDelegate, NSFetchedResultsControllerDelegate, FMMoveTableViewDataSource, FMMoveTableViewDelegate> {

    NSManagedObjectContext *managedObjectContext_;
    
}

@property (strong, nonatomic) IBOutlet FMMoveTableView *userTagTableView;
//@property (strong, nonatomic)   IBOutlet UIView *searchView;
//@property (strong, nonatomic)   IBOutlet MTSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap1GestureRecognizer;



@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <UserTagViewControllerDelegate> userTagViewControllerDelegate;
//@property(nonatomic, assign) id<UIGestureRecognizerDelegate> gestureRecognizerDelegate;

//@property (readwrite)           BOOL iPodLibraryChanged;
//@property (readwrite)           BOOL isSearching;
//@property (nonatomic, strong)   NSArray *searchResults;

@property (nonatomic, strong)   UserDataForMediaItem *userDataForMediaItem;

- (void)addTagViewControllerDidCancel:(AddTagViewController *)controller;
//- (IBAction)editTagCell:(UITapGestureRecognizer *)gestureRecognizer;
//- (IBAction)selectTagCell:(UITapGestureRecognizer *)gestureRecognizer;

@end
