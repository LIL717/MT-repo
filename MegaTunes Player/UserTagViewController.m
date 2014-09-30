//
//  UserTagViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//

#import "UserTagViewController.h"
#import "UserDataForMediaItem.h"
#import "UserTagCell.h"
#import "TagItem.h"
#import "TagData.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "MediaItemUserData.h"
#import "AddTagViewController.h"
#import "KSLabel.h"                  //black outline around text
#import "FMMoveTableView.h"


@interface UserTagViewController ()

@end

@implementation UserTagViewController

@synthesize userTagTableView;

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

//@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize userDataForMediaItem;
@synthesize userTagViewControllerDelegate;
@synthesize rightBarButton;

NSIndexPath *selectedIndexPath;
CGFloat constraintConstant;
UIImage *backgroundImage;
UIButton *infoButton;
BOOL scrollToTag;
int indexOfCurrentTag;
BOOL newTagInserted;
NSIndexPath *savedIndexPath;
int tapCount;
NSString *actionType;

#pragma mark - Initial Display methods


- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
//140206 1.2 iOS 7 begin
    // cause separator line to stretch to right side of view
    [self.userTagTableView setSeparatorInset:UIEdgeInsetsZero];
//140206 1.2 iOS 7 end
    [self listenForChanges];
    
    [self setupFetchedResultsController];
    
    NSError *error = nil;
    NSArray *allFetchedObjects = [self.managedObjectContext executeFetchRequest:[self fetchRequest] error:&error];
    for (TagData *tagData in allFetchedObjects) {
        NSLog (@"tagData.tagName is %@", tagData.tagName);
        NSLog (@"tagData.sortOrder is %d", [tagData.sortOrder intValue]);
    }
    
    //
    //
    //    //if the tag of the current mediaItem is already in the table, scroll that item to the top on first view
    //    scrollToTag = NO;
    //    NSString *tagOfCurrentItem = self.userDataForMediaItem.tagName;
    //
    //    for (int i = 0 ; i < [self.tagItemArray count ] ; i++)
    //    {
    //        TagItem *tagItem= [self.tagItemArray objectAtIndex: i];
    //        if ([tagItem.tagName isEqualToString: tagOfCurrentItem]) {
    //
    //            indexOfCurrentTag = i;
    //            scrollToTag = YES;
    //        }
    //    }
    
    self.title = NSLocalizedString(@"Tags", nil);
    
//140127 1.2 iOS 7 begin
    
    self.navigationController.navigationBar.topItem.title = @"";
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    UIButton *tempAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempAddButton addTarget:self action:@selector(addNewTag) forControlEvents:UIControlEventTouchUpInside];
    [tempAddButton setImage:[UIImage imageNamed:@"addImage.png"] forState:UIControlStateNormal];
    [tempAddButton setShowsTouchWhenHighlighted:NO];
    [tempAddButton sizeToFit];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempAddButton];
//140127 1.2 iOS 7 end

    [self.rightBarButton setIsAccessibilityElement:YES];
    [self.rightBarButton setAccessibilityLabel: NSLocalizedString(@"Add", nil)];
    [self.rightBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
}
- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TagData"];
    NSSortDescriptor *sortBySortOrder = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortBySortOrder]];
    return fetchRequest;
}

- (void)setupFetchedResultsController {
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"ERROR: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Couldn't fetch entries :("
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    
//131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
//131216 1.2 iOS 7 end
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    [super viewWillAppear: animated];
    
    return;
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    tapCount = 0;
    
    if (newTagInserted) {
        [self.userTagTableView reloadData];
        
        NSInteger lastSectionIndex = [self.userTagTableView numberOfSections] - 1;
        
        // Then grab the number of rows in the last section
        NSInteger lastRowIndex = [self.userTagTableView numberOfRowsInSection:lastSectionIndex] - 1;
        
        NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
        [self.userTagTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
        newTagInserted = NO;
        
    }
    [super viewDidAppear:(BOOL)animated];
}
- (UILabel *) customizeTitleView
{
//131205 1.2 iOS 7 begin
    
    //    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44]}].width, 48);
    
//131205 1.2 iOS 7 end
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44];
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //    LogMethod();
//140216 1.2 iOS 7 begin
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat navBarAdjustment = isPortrait ? 0 : 7;
    
    [self.userTagTableView setContentOffset:CGPointMake(0, navBarAdjustment)];
    [self.userTagTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    
//140216 1.2 iOS 7 end
}

- (void) viewWillLayoutSubviews {
    //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.userTagTableView.contentSize = CGSizeMake(self.userTagTableView.frame.size.width, self.userTagTableView.contentSize.height);
    
    [super viewWillLayoutSubviews];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    LogMethod();
    
    return [[self.fetchedResultsController sections] count];
    
    //    }
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    LogMethod();
    // Return the number of rows in the section.
    
    id sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    
//    /******************************** NOTE ********************************
//	 * Implement this check in your table view data source to ensure correct access to the data source
//	 *
//	 * The data source is in a dirty state when moving a row and is only being updated after the user
//	 * releases the moving row
//	 **********************************************************************/
//	
//	// 1. A row is in a moving state
//	// 2. The moving row is not in it's initial section
//
//	if ([tableView movingIndexPath] && [[tableView movingIndexPath] section] != [[tableView initialIndexPathForMovingRow] section])
//	{
//		if (section == [[tableView movingIndexPath] section]) {
//			numberOfRows++;
//		}
//		else if (section == [[tableView initialIndexPathForMovingRow] section]) {
//			numberOfRows--;
//		}
//	}
    return numberOfRows;
    //        //---section 0 is the search button---
    //    }
}


- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    LogMethod();
    
	UserTagCell *cell = (UserTagCell *)[tableView dequeueReusableCellWithIdentifier:@"UserTagCell"];
    
//    
//    /******************************** NOTE ********************************
//     * Implement this check in your table view data source to ensure that the moving
//     * row's content is being reseted
//     **********************************************************************/
//    if ([tableView indexPathIsMovingIndexPath:indexPath]) {
//        [cell prepareForMove];
//    } else {
//		/******************************** NOTE ********************************
//		 * Implement this check in your table view data source to ensure correct access to the data source
//		 *
//		 * The data source is in a dirty state when moving a row and is only being updated after the user
//		 * releases the moving row
//		 **********************************************************************/
//        if ([tableView movingIndexPath]) {
//            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
//        }

        TagData *tagData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [cell.tagLabel removeFromSuperview];
        
        cell.tagLabel = [[KSLabel alloc] initWithFrame:CGRectMake(6, 0, self.userTagTableView.frame.size.width - 6, 55)];
        
        cell.tagLabel.textColor = [UIColor whiteColor];
        [cell.tagLabel setDrawOutline:YES];
        [cell.tagLabel setOutlineColor:[UIColor blackColor]];
        
        [cell.tagLabel setDrawGradient:NO];
        
        cell.tagLabel.font = [UIFont systemFontOfSize:44];
        cell.tagLabel.text = tagData.tagName;
        [cell addSubview:cell.tagLabel];
        
        int red = [tagData.tagColorRed intValue];
        int green = [tagData.tagColorGreen intValue];
        int blue = [tagData.tagColorBlue intValue];
        int alpha = [tagData.tagColorAlpha intValue];
        
        UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];

//131203 1.2 iOS 7 begin
        cell.backgroundColor = tagColor;
//131203 1.2 iOS 7 end

//    }

    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.userTagTableView setEditing:editing animated:YES];
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    //- (void) tapOnTableView: (UITableView *) tableView atIndexPath: (NSIndexPath *) indexPath {
    
    tapCount++;
    switch (tapCount)
    {
        case 1: //single tap
            [self performSelector:@selector(singleTap:) withObject: indexPath afterDelay: 0.4];
            break;
        case 2: //double tap
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap:) object:indexPath];
            [self performSelector:@selector(doubleTap:) withObject: indexPath];
            break;
        default:
            break;
    }
    if (tapCount>2) {
        tapCount=0;
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}


- (void)singleTap:(NSIndexPath *)indexPath {
    
    NSLog (@"Single Tap");
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];

    TagData *tagData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //update or add object to Core Data
    
    self.userDataForMediaItem.tagData = tagData;
    [mediaItemUserData updateTagForItem: self.userDataForMediaItem];
    
    //    NSLog (@"add tag to mediaItemUserData");
    //    [mediaItemUserData listAll];
    //    [tagData listAll];
//140217 1.2 iOS 7 begin
    [self.navigationController popViewControllerAnimated:YES];
//140217 1.2 iOS 7 end
}

- (void)doubleTap:(NSIndexPath *)indexPath {
    NSLog (@"Double Tap");
    savedIndexPath = indexPath;
    actionType = @"Edit";
    [self performSegueWithIdentifier: @"AddTagItem" sender: self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TagData *tagData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [tagData deleteTagDataFromCoreData: tagData];
    
    //    NSLog (@"Tag deleted from TagData");
    //    [tagData listAll];
    //
    //    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    //    [mediaItemUserData listAll];
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL) moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.row == 0) // Don't move the first row
    //        return NO;
    
    return YES;
}
- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray *tagDataArray = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    // Grab the item we're moving.
    TagData *tagData = [[self fetchedResultsController] objectAtIndexPath:sourceIndexPath];
    
    // Remove the object we're moving from the array.
    [tagDataArray removeObject:tagData];
    // Now re-insert it at the destination.
    [tagDataArray insertObject:tagData atIndex:[destinationIndexPath row]];
    
    // All of the objects are now in their correct order. Update each
    // object's sortOrder field by iterating through the array.
    int i = 0;
    for (TagData *td in tagDataArray)
    {
        [td setValue:[NSNumber numberWithInt:i++] forKey:@"sortOrder"];
    }
    
    tagDataArray = nil;
    NSError * error = nil;
    
    
    [self.managedObjectContext save:nil];
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TagDataChanged" object:nil];
    
    [self.userTagTableView reloadData];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.userTagTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.userTagTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //set a flag so that table can be scrolled after the updates happen other wise crashes with out of bounds index
            newTagInserted = YES;
            //            savedIndexPath = newIndexPath;
            //            [self.userTagTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.userTagTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.userTagTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
		default:
			break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.userTagTableView endUpdates];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    LogMethod();
    
    if ([segue.identifier isEqualToString:@"AddTagItem"])
	{
		AddTagViewController *addTagViewController = segue.destinationViewController;
        addTagViewController.managedObjectContext = self.managedObjectContext;
        addTagViewController.addTagViewControllerDelegate = self;
        addTagViewController.actionType = actionType;
        
        if ([actionType isEqualToString: @"Add"]) {
            NSArray *tagDataArray = [[self.fetchedResultsController fetchedObjects] copy];
            TagData *tagData = [tagDataArray lastObject];
            addTagViewController.lastObjectIndex = [tagData.sortOrder intValue];
            addTagViewController.title = NSLocalizedString(@"Add Tag", nil);
            addTagViewController.hasColor = NO;
            
            NSLog (@"lastObjectIndex = %d", addTagViewController.lastObjectIndex);
            //        addTagViewController.iPodLibraryChanged = self.iPodLibraryChanged;
            
        }
        if ([actionType isEqualToString: @"Edit"]) {
            
            TagData *tagData = [self.fetchedResultsController objectAtIndexPath:savedIndexPath];
            addTagViewController.nameToEdit = tagData.tagName;
            addTagViewController.sortOrder = tagData.sortOrder;
            
            NSLog (@"tagData.tagName is %@", tagData.tagName);
            
            CGFloat red = [tagData.tagColorRed intValue];
            CGFloat green = [tagData.tagColorGreen intValue];
            CGFloat blue = [tagData.tagColorBlue intValue];
            CGFloat alpha = [tagData.tagColorAlpha intValue];
            
            UIColor *tagColor = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
            addTagViewController.hasColor = YES;
            addTagViewController.pickedColor = tagColor;
            NSLog (@"tagColor is %f %f %f %f", red, green, blue, alpha);
            
            addTagViewController.title = NSLocalizedString(@"Edit Tag", nil);
            
            //        addTagViewController.iPodLibraryChanged = self.iPodLibraryChanged;
            
        }
    }
    
}
- (IBAction)addNewTag {
    
    actionType = @"Add";
    [self performSegueWithIdentifier: @"AddTagItem" sender: self];
}
//140217 1.2 iOS 7 begin
//intercept back Button pressed
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        [self.userTagViewControllerDelegate userTagViewControllerDidCancel:self];
    }
}
//140217 1.2 iOS 7 end
- (void)addTagViewControllerDidCancel:(AddTagViewController *)controller
{
    //    if (newTagInserted) {
    //        // First figure out how many sections there are
    //        NSInteger lastSectionIndex = [self.userTagTableView numberOfSections] - 1;
    //
    //        // Then grab the number of rows in the last section
    //        NSInteger lastRowIndex = [self.userTagTableView numberOfRowsInSection:lastSectionIndex] - 1;
    //
    //        NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    //        [self.userTagTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //        newTagInserted = NO;
    //
    ////        [self.userTagTableView reloadData];
    //
    //    }
    //    [self willAnimateRotationToInterfaceOrientation: self.interfaceOrientation duration: 1];
    
    
}

- (void)listenForChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

- (void)contextDidSave:(NSNotification *)notification {
    NSLog(@"Merging changes...");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}
- (void)dealloc {
    //    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end


