//
//  IntialTableViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "IntialTableViewController.h"
#import "MediaGroupsViewController.h"
#import "AppDelegate.h"
#import "MediaGroup.h"
#import "MediaGroupCell.h"

@interface IntialTableViewController ()

@end

@implementation IntialTableViewController

@synthesize collection;
@synthesize groupingData;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andGroupingType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andGroupingType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andGroupingType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Albums" andGroupingType: [MPMediaQuery albumsQuery]];

    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Compilations" andGroupingType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Composers" andGroupingType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Genres" andGroupingType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Podcasts" andGroupingType: [MPMediaQuery podcastsQuery]];

    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7, nil];
    
    return;
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadGroupingData];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.groupingData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	MediaGroupCell *cell = (MediaGroupCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"MediaGroupCell"];
    MediaGroup *group = [self.groupingData objectAtIndex:indexPath.row];
    cell.nameLabel.text = group.name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogMethod();
	if ([segue.identifier isEqualToString:@"SelectGroup"])
	{
		MediaGroupsViewController *mediaGroupsViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        MediaGroup *group = [self.groupingData objectAtIndex:indexPath.row];

        MPMediaQuery *myCollectionQuery = group.groupingType;
        
        self.collection = [myCollectionQuery collections];
		mediaGroupsViewController.collection = self.collection;
        
        mediaGroupsViewController.title = group.name;
	}
}

@end

