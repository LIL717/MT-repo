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
//#import "bass.h"

@implementation SongViewController

@synthesize itemCollection;
@synthesize collectionItem;
@synthesize musicPlayer;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    LogMethod();
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
//    NSLog (@" nowPlayingItem is ****   %@", playingItem);
    
    if (playingItem) {
        NSString *nowPlayingLabel = @"Now Playing";
        
        UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:nowPlayingLabel style:UIBarButtonItemStyleBordered target:self action: @selector(viewNowPlaying)];
        
        self.navigationItem.rightBarButtonItem= nowPlayingButton;
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    [self.tableView reloadData];

    return;
}
- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];
    


//    self.currentQueue = self.mainViewController.userMediaItemCollection;
    
//    NSArray *returnedQueue = [self.currentQueue items];
//    
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }

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
    //    LogMethod();
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog (@"song count %d", [[self.currentQueue items] count]);
    
    return [[self.itemCollection items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SongCell *cell = (SongCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"SongCell"];
    
    MPMediaItem *song = [[self.itemCollection items] objectAtIndex:indexPath.row];

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
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        NotesViewController *notesViewController = segue.destinationViewController;
        notesViewController.managedObjectContext = self.managedObjectContext;

        
        MPMediaItem *song = [[self.itemCollection items] objectAtIndex:indexPath.row];
        
        NSString *notesTitle = [NSString stringWithFormat: @"%@ - Notes",[song valueForProperty:  MPMediaItemPropertyTitle]];
        notesViewController.title = notesTitle;
//        long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];

	}
    	if ([segue.identifier isEqualToString:@"PlaySong"])
	{
        MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        mainViewController.userMediaItemCollection = self.itemCollection;
        mainViewController.collectionItem = self.collectionItem;        
        mainViewController.playNew = YES;
        mainViewController.itemToPlay = [[self.itemCollection items] objectAtIndex:indexPath.row];
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
- (void)viewDidUnload {

    [super viewDidUnload];
}

@end
