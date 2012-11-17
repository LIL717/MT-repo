//
//  SongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
#import "MainViewController.h"
#import "NotesViewController.h"
#import "SongViewController.h"
#import "SongCell.h"
#import "CollectionItem.h"
#import "AppDelegate.h"
#import "ItemCollection.h"
//#import "bass.h"

@implementation SongViewController

@synthesize songTableView;
@synthesize collectionItem;
@synthesize musicPlayer;
@synthesize managedObjectContext;

- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewDidLoad];
    
    self.navigationItem.titleView = [self customizeTitleView];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
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
    [self.songTableView reloadData];

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

- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];

    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    

//    self.currentQueue = self.mainViewController.userMediaItemCollection;
    
//    NSArray *returnedQueue = [self.currentQueue items];
//    
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.songTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.songTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.songTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    LogMethod();
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [[self.collectionItem.collection items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SongCell *cell = (SongCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"SongCell"];
    
    MPMediaItem *song = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];

    cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
    
    if ([musicPlayer nowPlayingItem] == song) {
        cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
    } else {
        cell.playingIndicator.image = nil;
    }
        
    //can't get this to work
//    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing. To be called before BASS_Init.
//    
//    if (HIWORD(BASS_GetVersion()) != BASSVERSION) {
//        NSLog(@"An incorrect version of BASS was loaded");
//    }
//    
//    // Initialize default device.
//    if (!BASS_Init(-1, 44100, 0, NULL, NULL)) {
//        NSLog(@"Can't initialize device");
//        
//    }
//    
//    //NSArray *array = [NSArray arrayWithObject:@""
//    
//    NSString *respath = cell.nameLabel.text;
//    
//    DWORD chan1;
//    if(!(chan1=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
//        NSLog(@"Can't load stream!");
//        
//    }
//    
//    HSTREAM mainStream=BASS_StreamCreateFile(FALSE, [respath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
//    
//    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
//    NSLog(@"Play back duration is %f",playBackDuration);
//    HSTREAM bpmStream=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
//    //BASS_ChannelPlay(bpmStream,FALSE);
//    float BpmValue= BASS_FX_BPM_DecodeGet(bpmStream,0.0,
//                                    playBackDuration,
//                                    MAKELONG(45,256),
//                                    BASS_FX_BPM_MULT2,
//                                    NULL);
//    NSLog(@"BPM is %f",BpmValue);
    
    //this is always null
//    cell.BPM.text = [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute] stringValue];
//    NSLog (@"%d", [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue]);
    
    long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
    int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
    int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
    int playbackSeconds = (playbackDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];

//    MPMediaItemArtwork *artWork = [song valueForProperty:MPMediaItemPropertyArtwork];    
//    cell.imageView.image = [artWork imageWithSize:CGSizeMake(30, 30)];
    
//    NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//    NSNumber *duration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
//    NSLog (@"\t\t%@,%@", songTitle,duration);
    
    return cell;
}
#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    //set the "nowPlaying indicator" as the view disappears (already selected play indicator is still there too :(
    SongCell *cell = (SongCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
    
	if ([segue.identifier isEqualToString:@"ViewNotes"])
	{
        NSIndexPath *indexPath = [self.songTableView indexPathForCell:sender];

        NotesViewController *notesViewController = segue.destinationViewController;
        notesViewController.managedObjectContext = self.managedObjectContext;

        
        MPMediaItem *song = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
        
        NSString *notesTitle = [NSString stringWithFormat: @"%@ - Notes",[song valueForProperty:  MPMediaItemPropertyTitle]];
        notesViewController.title = notesTitle;
	}
    	if ([segue.identifier isEqualToString:@"PlaySong"])
	{
        MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.songTableView indexPathForCell:sender];

        mainViewController.userMediaItemCollection = self.collectionItem.collection;
        mainViewController.playNew = YES;
        mainViewController.itemToPlay = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
        
        //save collection in Core Data
        ItemCollection *itemCollection = [ItemCollection alloc];
        itemCollection.managedObjectContext = self.managedObjectContext;
        
        [itemCollection addCollectionToCoreData: self.collectionItem];

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
- (void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {

    [self setSongTableView:nil];
    [super viewDidUnload];
}

@end
