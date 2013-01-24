//
//  SongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
#import "MainViewController.h"
#import "SongInfoViewController.h"
#import "SongViewController.h"
#import "SongCell.h"
#import "inCellScrollView.h"
#import "CollectionItem.h"
#import "AppDelegate.h"
#import "ItemCollection.h"
#import "SongInfo.h"
#import "UIImage+AdditionalFunctionalities.h"

//#import "bass.h"

@implementation SongViewController

@synthesize songTableView;
@synthesize collectionItem;
@synthesize musicPlayer;
@synthesize managedObjectContext;
@synthesize songInfo;
//@synthesize saveIndexPath;
@synthesize itemToPlay;

- (void) viewWillAppear:(BOOL)animated
{
//    LogMethod();
    [super viewDidLoad];
    
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    //ipod or app player

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate useiPodPlayer]) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    } else {
        musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    
    //if there is a currently playing item, add a right button to the nav bar
    
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(viewNowPlaying)];
        
        UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    
    //can't remember why we do this...
    [self.songTableView reloadData];

    return;
}
//- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
//{
//    NSLog(@"touch cell in view controller");
//    // If not dragging, send event to next responder
//    [super touchesEnded: touches withEvent: event];
//}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
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
    
    //set the backround image for the view
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];

    //make the back arrow for left bar button item
    
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
    

    
    //make the accessory view into a custom info button
    
    UIImage *image = [UIImage imageNamed: @"infoLightButtonImage.png"];
    UIImage *backgroundImage = [UIImage imageNamed: @"infoSelectedButtonImage.png"];

//    UIImage *coloredImage = [image imageWithTint:[UIColor blueColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button setBackgroundImage:coloredImage forState:UIControlStateHighlighted];
    [button setBackgroundImage: backgroundImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(infoButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    //this would need some work - crashes with auto layout issues
//    [cell.infoBackground addSubview: button];
//    
//    cell.infoBackground.translatesAutoresizingMaskIntoConstraints = NO;
//    button.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(cell.infoBackground, button);
//    
//    [cell.infoBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|" options:0 metrics: 0 views:viewsDictionary]];
//    [cell.infoBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics: 0 views:viewsDictionary]];
    

        
/*****************************    //BPM   can't get this to work
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing. To be called before BASS_Init.
    
    if (HIWORD(BASS_GetVersion()) != BASSVERSION) {
        NSLog(@"An incorrect version of BASS was loaded");
    }
    
    // Initialize default device.
    if (!BASS_Init(-1, 44100, 0, NULL, NULL)) {
        NSLog(@"Can't initialize device");
        
    }
    
    //NSArray *array = [NSArray arrayWithObject:@""
    
    NSString *respath = cell.nameLabel.text;
    
    DWORD chan1;
    if(!(chan1=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
        NSLog(@"Can't load stream!");
        
    }
    
    HSTREAM mainStream=BASS_StreamCreateFile(FALSE, [respath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
    
    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
    NSLog(@"Play back duration is %f",playBackDuration);
    HSTREAM bpmStream=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
    //BASS_ChannelPlay(bpmStream,FALSE);
    float BpmValue= BASS_FX_BPM_DecodeGet(bpmStream,0.0,
                                    playBackDuration,
                                    MAKELONG(45,256),
                                    BASS_FX_BPM_MULT2,
                                    NULL);
    NSLog(@"BPM is %f",BpmValue);

    //this is always null
    cell.BPM.text = [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute] stringValue];
    NSLog (@"%d", [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue]);
*********************************************/
    //playback duration of the song
    
    long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
    int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
    int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
    int playbackSeconds = (playbackDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];
    
//    NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//    NSNumber *duration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
//    NSLog (@"\t\t%@,%@", songTitle,duration);
    
    //set the red arrow on the row if this is the currently playing song
    if ([musicPlayer nowPlayingItem] == song) {
        cell.playingIndicator.image = [UIImage imageNamed:@"playing"];
    } else {
        cell.playingIndicator.image = [UIImage imageNamed:@"notPlaying"];
    }
    // Display text

    cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];

    //calculate the label size to fit the text with the font size
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX, tableView.rowHeight)
                                           lineBreakMode:NSLineBreakByClipping];

    //calculate the width of the actual scrollview
    //cell.playingIndicator is 20
    //durationLabelSize.width is 98
    //cell.accessoryView.frame.size.width is 42
    // so scrollViewWidth should be 480-24-98-42 = 316   or 320-28-42= 250
    NSUInteger scrollViewWidth;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        scrollViewWidth = (tableView.frame.size.width - 28 - cell.accessoryView.frame.size.width);
    } else {
        scrollViewWidth = (tableView.frame.size.width - 24 - 98 - cell.accessoryView.frame.size.width);
    }

    if (labelSize.width>scrollViewWidth) {

        cell.scrollView.scrollEnabled = YES;
        //        NSLog (@"scrollEnabled");
    }
    else {
        cell.scrollView.scrollEnabled = NO;
        //        NSLog (@"scrollDisabled");
    }
    return cell;
}

//unused code but not ready to delete it altogether yet :)
//    //need to have scrollView object and label object independent of SongCell to add
//    
//    inCellScrollView* myScrollView = [[inCellScrollView alloc] initWithFrame:cell.scrollView.frame];
//    myScrollView.contentSize = cell.scrollView.contentSize;
//    
//    UILabel *myLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
//    myLabel.textColor = [UIColor whiteColor];
//    myLabel.backgroundColor = [UIColor clearColor];
////    UIFont *font = [UIFont systemFontOfSize:12];
////    UIFont *newFont = [font fontWithSize:44];
//    myLabel.font = newFont;
//    myLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
//    
//    [cell addSubview:myScrollView];
//    [myScrollView addSubview:myLabel];
//    
//    //format cell using VB autolayout
//    
//    //Prevent from trying to layout subviews by converting autoresize masks into constraints
//    [myScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [myLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//    
//    //Convenience function to create viewsDictionary
//    NSDictionary *views = NSDictionaryOfVariableBindings(myScrollView, myLabel);
//    
//    //Create our NSNumber variables for our metrics dictionary.
//
//    NSNumber *sVW = [NSNumber numberWithInt:scrollViewWidth];
//    NSNumber *tSpace = [NSNumber numberWithInt:trailingSpace];
//                    
//    //Create our metrics dictionary using our NSNumbers and strings
//    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys: sVW, @"sVW", tSpace, @"tSpace", nil];
//    
//    //Layout the horizontal scrollView
////    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-18-[scrollView(==312@500)]-55-|" options:0 metrics:metrics views:views]];
//    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-18-[myScrollView(==sVW)]-tSpace-|" options:0 metrics:metrics views:views]];
//    //layout the vertical scrollView
//    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[myScrollView]|" options:0 metrics:metrics views:views]];
//    
//    
//    
//    
    
    
    //the gesture recognizers for tap in the scrollview was somehow lost, so add it again to whole cell
    // add tap gesture to whole cell
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(tapDetected:)];
//    
//    [cell addGestureRecognizer:tap];
//
//    UIButton *touchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.scrollView.frame.size.width, cell.scrollView.frame.size.height)];
//    [touchBtn addTarget:self action:@selector(tapDetected: event:) forControlEvents:UIControlEventTouchUpInside];
////    touchBtn.showsTouchWhenHighlighted = YES;
//    [cell.scrollView addSubview: touchBtn];
    

// need to handle the tap manually because scrollview lost recognition of tap when sized

//-(void)tapDetected:(UITapGestureRecognizer*)tapGesture
//- (void) tapDetected:(id) sender {
//- (void)tapDetected:(id)sender event:(id)event {
//    
//    //    if (tapGesture.state == UIGestureRecognizerStateEnded)
//    //    {
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.songTableView];
//    self.saveIndexPath = [self.songTableView indexPathForRowAtPoint: currentTouchPosition];
//    
//    UITableView* tableView = (UITableView*)self.view;
//    //        CGPoint touchPoint = [sender locationInView:self.view];
//    //        self.saveIndexPath = [tableView indexPathForRowAtPoint:touchPoint];
//    if (self.saveIndexPath != nil) {
//        
//        SongCell *cell = (SongCell *)[tableView cellForRowAtIndexPath:self.saveIndexPath];
//        cell.nameLabel.highlighted = YES;
//        cell.durationLabel.highlighted = YES;
//        //this didn't do anything
//            cell.nameLabel.textColor = [UIColor blueColor];
//            cell.durationLabel.textColor = [UIColor blueColor];
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                cell.nameLabel.highlighted = NO;
//                cell.nameLabel.textColor = [UIColor whiteColor];
//                cell.durationLabel.highlighted = NO;
//                cell.durationLabel.textColor = [UIColor whiteColor];
//            });
//        self.itemToPlay = [[self.collectionItem.collection items] objectAtIndex:saveIndexPath.row];
//        
//        [self performSegueWithIdentifier: @"PlaySong" sender: self];
//    }
//    //    }
//}

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
    
	if ([segue.identifier isEqualToString:@"ViewInfo"])
	{
       SongInfoViewController *songInfoViewController = segue.destinationViewController;
        songInfoViewController.managedObjectContext = self.managedObjectContext;
        songInfoViewController.title = @"Info";
        songInfoViewController.songInfo = songInfo;
        
	}
    	if ([segue.identifier isEqualToString:@"PlaySong"])
	{
        MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;
        //these two lines if no method directly calls prepareForSegue
        NSIndexPath *indexPath = [self.songTableView indexPathForCell:sender];
        mainViewController.itemToPlay = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
//        //this line if another method is setting self.itemToPlay;
//        mainViewController.itemToPlay = self.itemToPlay;

        mainViewController.userMediaItemCollection = self.collectionItem.collection;
        mainViewController.playNew = YES;
        
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
- (IBAction)infoButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.songTableView];
    NSIndexPath *indexPath = [self.songTableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.songTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *song = [[self.collectionItem.collection items] objectAtIndex:indexPath.row];
    
    self.songInfo = [[SongInfo alloc] init];
    self.songInfo.songName = [song valueForProperty:  MPMediaItemPropertyTitle];
    self.songInfo.album = [song valueForProperty:  MPMediaItemPropertyAlbumTitle];
    self.songInfo.artist = [song valueForProperty:  MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [song valueForProperty:MPMediaItemPropertyArtwork];
    self.songInfo.albumImage = [artWork imageWithSize:CGSizeMake(200, 200)];
    
    [self performSegueWithIdentifier: @"ViewInfo" sender: self];
}

- (void)viewDidUnload {

    [self setSongTableView:nil];
    [super viewDidUnload];
}

@end
