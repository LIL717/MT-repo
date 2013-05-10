//
//  MediaGroupTableViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroup.h"

@interface MediaGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate> {

    NSManagedObjectContext  *managedObjectContext;
}

@property (strong, nonatomic)   IBOutlet UITableView *groupTableView;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong)   NSArray  *collection;
@property (nonatomic, strong)   NSArray *groupingData;
@property (nonatomic, strong)   MediaGroup *selectedGroup;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL iPodLibraryChanged;
@property (nonatomic, strong)   UIBarButtonItem *rightBarButton;




@end


