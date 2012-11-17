//
//  MediaGroupViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroupViewController.h"
#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "MediaGroup.h"
#import "MediaGroupCell.h"
#import "SongViewController.h"
#import "CollectionItem.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"

@interface MediaGroupViewController ()

@end

@implementation MediaGroupViewController

@synthesize groupTableView;
//@synthesize delegate;
@synthesize collection;
@synthesize groupingData;
@synthesize selectedGroup;
@synthesize musicPlayer;
//@synthesize fetchedResultsController;
@synthesize managedObjectContext;

-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Albums" andQueryType: [MPMediaQuery albumsQuery]];

    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Compilations" andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Composers" andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Genres" andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Podcasts" andQueryType: [MPMediaQuery podcastsQuery]];

    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7, nil];
    
    return;    
    
}
- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewDidLoad];


    self.title = @"Choose Music";
    self.navigationItem.titleView = [self customizeTitleView];

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        NSLog (@"iPod");
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        NSLog (@"app");
    }

    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];

    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(viewNowPlaying)];
        
        UIImage *menuBarImage40 = [[UIImage imageNamed:@"Music-App-Icon40.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, -7)];
        UIImage *menuBarImage54 = [[UIImage imageNamed:@"Music-App-Icon54.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, -3)];
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImage40 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImage54 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    return;
}
- (UILabel *) customizeTitleView
   {
       CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
       UILabel *label = [[UILabel alloc] initWithFrame:frame];
       label.backgroundColor = [UIColor clearColor];
       label.textAlignment = UITextAlignmentCenter;
       UIFont *font = [UIFont systemFontOfSize:12];
       UIFont *newFont = [font fontWithSize:44];
       label.font = newFont;
       label.textColor = [UIColor yellowColor];
       label.text = self.title;
       
       return label;
   }

//- (UIView *)customizeTitleView:(NSString *) title {
//
////    UIBarMetrics metrics = (self.view.frame.size.height > 40.0) ? UIBarMetricsDefault : UIBarMetricsLandscapePhone;
////    UIImage *navImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:metrics];
////    CGSize imageSize = navImage.size;
////    CGFloat navBarWidth = imageSize.width;
////    CGFloat navBarHeight = imageSize.height;
////    NSLog (@"width x height %f x %f", navBarWidth, navBarHeight);
////    
////    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, navBarWidth, navBarHeight)];
//    UIView *containerView = [[UIView alloc] init];
//
//    
//    //make a titleLabel and set the font and text
//    UILabel *titleLabel = [[UILabel alloc] init];
//    
//    titleLabel.textColor = [UIColor yellowColor];
//    UIFont *font = [UIFont systemFontOfSize:12];
//    UIFont *newFont = [font fontWithSize:44];
//    titleLabel.font = newFont;
//    titleLabel.text = title;
//    titleLabel.backgroundColor = [UIColor clearColor];
////    
////    //calculate the label size with the font and text
////    CGSize labelSize = [titleLabel.text sizeWithFont:titleLabel.font
////                                   constrainedToSize:CGSizeMake(CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds))
////                                       lineBreakMode:NSLineBreakByTruncatingTail];
////    
////    //make a new label and set its size to exactly fit the text for height and width
////    UILabel *newLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, labelSize.width, labelSize.height)];
////    
////    //set the titleLabel frame to be the size that exactly fits the text
////    titleLabel.frame = newLabel.frame;
////    //    NSLog (@" navBarwidth is %f", navBarWidth);
////    NSLog (@" titleLabel.frame.size.width is %f", titleLabel.frame.size.width);
////    NSLog (@" titleLabel.origin.X is %f", titleLabel.frame.origin.x);
//    
//    //make the container view's frame the same size as the titleLabel's frame so that it will be centered
//    //    containerView.frame = titleLabel.frame;
//    
//    [containerView addSubview:titleLabel];
//    
//    return containerView;
//    
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadGroupingData];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];

}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.groupTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.groupTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// Configures the table view.

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
    
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
    
    return cell;
}

#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
//    LogMethod();

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    self.selectedGroup = [self.groupingData objectAtIndex:indexPath.row];
    if (selectedGroup.name == @"Songs") {
        [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
    } else
        if (selectedGroup.name == @"Compilations") {
            [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
        } else
        {
            [self performSegueWithIdentifier: @"ViewCollections" sender: self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
	if ([segue.identifier isEqualToString:@"ViewCollections"])
	{
		CollectionViewController *collectionViewController = segue.destinationViewController;
        collectionViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
		collectionViewController.collection = self.collection;
        collectionViewController.title = selectedGroup.name;



	}
    
    if ([segue.identifier isEqualToString:@"ViewSongCollection"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;

        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
        for (MPMediaPlaylist *mediaPlaylist in self.collection) {
            
            NSArray *songs = [mediaPlaylist items];

            for (MPMediaItem *song in songs) {
                [songMutableArray addObject: song];
                playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//                NSLog (@"\t\t%@", songTitle);
            }
        }
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedGroup.name;
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
        collectionItem.collection = [MPMediaItemCollection collectionWithItems: songMutableArray];

        songViewController.title = collectionItem.name;
        songViewController.collectionItem = collectionItem;
        
	}
   if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;

        mainViewController.playNew = NO;

    }

}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

@end

