//
//  AlbumInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//
//130911 1.1 add iTunesStoreButton begin
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kBgQueue2 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//130911 1.1 add iTunesStoreButton end

#import "AlbumInfoViewController.h"
#import "AppDelegate.h"
#import "SongInfoCell.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "InCellScrollView.h"
//130911 1.1 add iTunesStoreButton begin
#import "StoreViewController.h"
//130911 1.1 add iTunesStoreButton end


@interface AlbumInfoViewController ()

@end

@implementation AlbumInfoViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize infoTableView;
@synthesize albumImageView;
@synthesize songInfoData;
@synthesize songName;
@synthesize album;
@synthesize artist;
@synthesize albumImage;

@synthesize lastPlayedDate;
@synthesize lastPlayedDateTitle;
@synthesize bpm;
@synthesize userGrouping;
@synthesize userGroupingTitle;

@synthesize saveBPM;

@synthesize comments;

BOOL iTunesComments;
//130909 1.1 add iTunesStoreButton begin
@synthesize iTunesStoreSelector;
@synthesize artistLinkUrl;
@synthesize albumLinkUrl;
@synthesize locale;
@synthesize countryCode;
@synthesize artistNameFormatted;
@synthesize albumNameFormatted;
@synthesize songNameFormatted;
@synthesize iTunesLinkUrl;

NSString *myAffiliateID;
//130909 1.1 add iTunesStoreButton end




#pragma mark - Initial Display methods

- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
//140203 1.2 iOS 7 begin
    UIImage *unselectedImage0 = [UIImage imageNamed:@"whiteInfoTabImage.png"];
    UIImage *selectedImage0 =   [UIImage imageNamed:@"blueInfoTabImage.png"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"whiteCommentsImage.png"];
    UIImage *selectedImage1 =   [UIImage imageNamed:@"blueCommentsImage.png"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"whiteTagImage.png"];
    UIImage *selectedImage2 =   [UIImage imageNamed:@"blueTagImage.png"];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
//    item0.title = NSLocalizedString(@"iTunes info", nil);
//    item1.title = NSLocalizedString(@"iTunes comments", nil);
//    item2.title = NSLocalizedString(@"Tag info", nil);
    
    item0.title = nil;
    item1.title = nil;
    item2.title = nil;
    
    item0.image = [unselectedImage0 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.selectedImage = [selectedImage0 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.image = [unselectedImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [selectedImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.image = [unselectedImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [selectedImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    UIImage* tabBarBackground = [UIImage imageNamed:@"transparentImage.png"];
//    [[UITabBar appearance] setShadowImage:tabBarBackground];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];

//140203 1.2 iOS 7 end
    
    [self loadTableData];
    
    //    [self registerForMediaPlayerNotifications];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) loadTableData {
    //get the specific info from the
    
    self.songInfoData = [[NSMutableArray alloc] initWithCapacity: 7];
    
    self.songName = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyTitle];
    self.album = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyAlbumTitle];
    self.artist = [self.mediaItemForInfo valueForProperty:  MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [self.mediaItemForInfo valueForProperty:MPMediaItemPropertyArtwork];
    self.albumImage = [artWork imageWithSize:CGSizeMake(200, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 320)];
    if (!self.albumImage) {
        [imageView setImage:[UIImage imageNamed:@"noAlbumImage320.png"]];
    } else {
        [imageView setImage:self.albumImage];
    }
    [self.albumImageView addSubview:imageView];
    
    if (!self.artist) {
        self.artist = NSLocalizedString(@"Unknown", nil);
    }
    [self.songInfoData addObject: self.artist];
    
    if (!self.songName) {
        self.songName = NSLocalizedString(@"Unknown", nil);
    }
    [self.songInfoData addObject: self.songName];
    
    if (!self.album) {
        self.album = NSLocalizedString(@"Unknown", nil);
    }
    [self.songInfoData addObject: self.album];
    
    [self loadiTunesInfoData];
    
    //130911 1.1 add iTunesStoreButton begin
    //fetch the iTunes link info in the background
    
    //get the affliate ID
    myAffiliateID = [[NSUserDefaults standardUserDefaults] stringForKey:@"affiliateID"];
    
    self.locale = [NSLocale currentLocale];
    self.countryCode = [self.locale objectForKey: NSLocaleCountryCode];
    
    //if artist is known, get itunes link
    if (![self.artist isEqualToString: @"Unknown"]) {
        
        self.artistNameFormatted = [self.artist stringByReplacingOccurrencesOfString:@" "
                                                                          withString:@"+"];
        self.albumNameFormatted = [self.album stringByReplacingOccurrencesOfString:@" "
                                                                          withString:@"+"];
        self.songNameFormatted = [self.songName stringByReplacingOccurrencesOfString:@" "
                                                                          withString:@"+"];
        
//        NSString *iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@&media=music&limit=1", self.countryCode, self.artistNameFormatted];
        NSString *iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@%%20%@&media=music&limit=50", self.countryCode, self.artistNameFormatted, self.songNameFormatted];
        NSURL *iTunesSearchURL = [NSURL URLWithString: iTunesSearchString];
        
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            iTunesSearchURL];
            [self performSelectorOnMainThread:@selector(fetchedArtist:)
                                   withObject:data waitUntilDone:YES];
        });
//        iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@&media=music&entity=album&limit=500", self.countryCode, self.artistNameFormatted];
        iTunesSearchString = [NSString stringWithFormat: @"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?lang=1&output=json&country=%@&term=%@%%20%@%%20%@&media=music&limit=50", self.countryCode, self.artistNameFormatted, self.albumNameFormatted, self.songNameFormatted];
        iTunesSearchURL = [NSURL URLWithString: iTunesSearchString];
        
        dispatch_async(kBgQueue2, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            iTunesSearchURL];
            [self performSelectorOnMainThread:@selector(fetchedAlbum:)
                                   withObject:data waitUntilDone:YES];
        });
        
    }
    //130911 1.1 add iTunesStoreButton end
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

    
}
- (void) loadiTunesInfoData {
    NSDate *date = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyLastPlayedDate];
    
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        self.lastPlayedDate = [NSString stringWithFormat: @"%@ %@", self.lastPlayedDateTitle, formattedDateString];
        [self.songInfoData addObject: self.lastPlayedDate];
    }
    
    //    //check to see if there is user data for this media item
    //    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    //    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    //
    //    self.userDataForMediaItem = [mediaItemUserData containsItem: [mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID]];
    //
    //    //if there is an MPMediaItemPropertyBeatsPerMinute value, use that, otherwise see if one has been stored in User Data and if not, then calculate one (will be stored in user data when this view is deallocated)
    if ([[self.mediaItemForInfo valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue] > 0) {
        self.saveBPM= [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyBeatsPerMinute];
        //    } else {
        //        if (self.userDataForMediaItem.bpm > 0) {
        //            self.saveBPM = self.userDataForMediaItem.bpm;
        //        } else {
        ////            [self calculateBPM];
        //            //self.userDataForMediaItem.bpm is set when it is calculated
        //        }
    }
    if (self.saveBPM > 0) {
        self.bpm = [[NSString alloc] initWithFormat:@"%2d BPM", [self.saveBPM intValue]];
        [self.songInfoData addObject: self.bpm];
    }
    
    if ([self.mediaItemForInfo valueForProperty: MPMediaItemPropertyUserGrouping]) {
        self.userGrouping = [NSString stringWithFormat: @"%@ %@", self.userGroupingTitle, [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyUserGrouping]];
        [self.songInfoData addObject: self.userGrouping];
    }
    
}
//130911 1.1 add iTunesStoreButton begin
- (void)fetchedArtist:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.artistLinkUrl = nil;

    if (responseData) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        NSArray* results = [json objectForKey:@"results"];
    
        if ([results count] > 0) {
//            NSDictionary* artistDictionary = [results objectAtIndex:0];
//
//            artistLinkUrl = [artistDictionary objectForKey:@"artistLinkUrl"];
            for (NSDictionary *item in results) {

                if ([[item objectForKey: @"kind"] isEqualToString: @"song"]
                    && [[item objectForKey: @"artistName"] isEqualToString: self.artist]) {
                    
                    self.artistLinkUrl = [item objectForKey: @"artistLinkUrl"];
                    break;
                }
            }
        }
    }
    if (self.artistLinkUrl) {
        NSLog(@"artistLinkUrl is %@", self.artistLinkUrl);
        [self.infoTableView reloadData];
    }
    //artistLinkUrl = "https://itunes.apple.com/us/artist/phillip-phillips/id199170038?uo=4";
}
- (void)fetchedAlbum:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.albumLinkUrl = nil;

    if (responseData) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData 
                        
                              options:kNilOptions
                              error:&error];
        
            NSArray* results = [json objectForKey:@"results"];
            
        if ([results count] > 0) {
            for (NSDictionary *item in results) {
        //        if ([[item objectForKey: @"itemName"] isEqualToString: self.album] && [[item objectForKey: @"artistName"] isEqualToString: self.artist]) {
//            if ([[item objectForKey: @"itemName"] isEqualToString: self.album]) {
//
//                        self.albumLinkUrl = [item objectForKey: @"itemLinkUrl"];
//                    break;
//                }
                if ([[item objectForKey: @"itemParentName"] isEqualToString: self.album]
                    && [[item objectForKey: @"kind"] isEqualToString: @"song"]
                    && [[item objectForKey: @"artistName"] isEqualToString: self.artist]) {
                    
                    self.albumLinkUrl = [item objectForKey: @"itemParentLinkUrl"];
                    break;
                }
            }
        }
    }
    
    if (self.albumLinkUrl) {
        NSLog (@"albumLinkUrl is %@", self.albumLinkUrl);

        [self.infoTableView reloadData];
    }
    //itemLinkUrl = "https://itunes.apple.com/us/album/you-love-me/id464532842?i=464532972&uo=4";
}
//130911 1.1 add iTunesStoreButton end

- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    for (NSIndexPath *indexPath in [self.infoTableView indexPathsForVisibleRows]) {
        
        //            NSLog (@" indexPath to scroll %@", indexPath);
        SongInfoCell *cell = (SongInfoCell *)[self.infoTableView cellForRowAtIndexPath:indexPath];
        [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    [super viewWillAppear: animated];
    
    //    if (self.tabBarController.selectedIndex = 0) {
    //        self.title = @"Info";
    ////        self.navigationItem.titleView = [self customizeTitleView];
    //    self.navItem.titleView = [self customizeTitleView];
    //
    //        NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
    //    } else {
    //        self.title = @"Notes";
    //        self.navigationItem.titleView = [self customizeTitleView];
    //        NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
    //    }
}
//- (UILabel *) customizeTitleView
//{
//    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    UIFont *font = [UIFont systemFontOfSize:12];
//    UIFont *newFont = [font fontWithSize:44];
//    label.font = newFont;
//    label.textColor = [UIColor yellowColor];
//    label.text = self.title;
//
//    return label;
//}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    CGFloat commentsHeight = self.comments.frame.size.height;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,commentsHeight,0)];
        self.lastPlayedDateTitle = @"Played:";
        self.userGroupingTitle = @"Grouping:";
        
        
    } else {
        NSLog (@"landscape");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,commentsHeight,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.lastPlayedDateTitle = @"Last Played:";
        self.userGroupingTitle = @"iTunes Grouping:";
        
    }
    //    [self.infoTableView reloadData];
}

#pragma mark Table view methods________________________
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
    //    NSLog (@"self.songInfoData count is %d", [self.songInfoData count]);
    return [self.songInfoData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    SongInfoCell *cell = (SongInfoCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"SongInfoCell"];
    
    cell.nameLabel.text = [self.songInfoData objectAtIndex:indexPath.row];
    //    NSLog (@"cell.nameLabel.frame.size.width is %f", CGRectGetWidth(cell.scrollView.bounds));
    
//130909 1.1 add iTunesStoreButton begin
    
    self.iTunesStoreSelector = nil;
    
    if (![cell.nameLabel.text isEqualToString: @"Unknown"]) {
        if (indexPath.row == 0 && self.artistLinkUrl) {
            self.iTunesStoreSelector = @"artist";
        } else {
            if (indexPath.row == 2 && self.albumLinkUrl) {
            self.iTunesStoreSelector = @"album";
            }
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (self.iTunesStoreSelector) {
        
        cell.scrollViewToCellConstraint.constant = 54;
        cell.iTunesStoreButton.hidden = NO;

        [cell.iTunesStoreButton addTarget:self action:@selector(linkToiTunesStore:event:)  forControlEvents:UIControlEventTouchUpInside];
        
        [cell.iTunesStoreButton setIsAccessibilityElement:YES];
        [cell.iTunesStoreButton setAccessibilityLabel: NSLocalizedString(@"ITunesStore", nil)];
        [cell.iTunesStoreButton setAccessibilityTraits: UIAccessibilityTraitButton];
        if ([self.iTunesStoreSelector isEqualToString: @"artist"]) {
            [cell.iTunesStoreButton setAccessibilityHint: NSLocalizedString(@"View more by this artist.", nil)];
        } else {
            [cell.iTunesStoreButton setAccessibilityHint: NSLocalizedString(@"View songs on this album.", nil)];
        }
//        UIView *superview = cell.contentView;
//        
//        [iTunesStoreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        [superview addSubview:iTunesStoreButton];
//        
//        NSLayoutConstraint *myConstraint = [NSLayoutConstraint
//                                            constraintWithItem:iTunesStoreButton
//                                            attribute:NSLayoutAttributeTrailing
//                                            relatedBy:NSLayoutRelationEqual
//                                            toItem:superview
//                                            attribute:NSLayoutAttributeTrailing
//                                            multiplier:1.0
//                                            constant:0];
//        
//        [superview addConstraint:myConstraint];
//        
//        myConstraint = [NSLayoutConstraint
//                        constraintWithItem:iTunesStoreButton
//                        attribute:NSLayoutAttributeTop
//                        relatedBy:NSLayoutRelationEqual
//                        toItem:superview
//                        attribute:NSLayoutAttributeTop
//                        multiplier:1.0
//                        constant:-3];
//        
//        [superview addConstraint:myConstraint];

        
    } else {
        //not artist or album row
        cell.scrollViewToCellConstraint.constant = 0;
        cell.iTunesStoreButton.hidden = YES;
//        [iTunesStoreButton removeFromSuperview];
    }

        
//    cell.scrollViewToCellConstraint.constant = iTunesStoreSelector ? -54 : 0;
    
//    NSLog (@"constraintConstant is %f", cell.scrollViewToCellConstraint.constant);
    
    NSUInteger scrollViewWidth;
    
    if (iTunesStoreSelector) {
        scrollViewWidth = (tableView.frame.size.width - 54);
    } else {
        scrollViewWidth = tableView.frame.size.width;
    }
            
    //calculate the label size to fit the text with the font size
    
//131210 1.2 iOS 7 begin
    
//    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
//                                       constrainedToSize:CGSizeMake(INT16_MAX,cell.frame.size.height)
//                                           lineBreakMode:NSLineBreakByClipping];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:cell.nameLabel.text
                                                                        attributes:@{NSFontAttributeName: cell.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(INT16_MAX, cell.frame.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize labelSize = rect.size;
    
//131210 1.2 iOS 7 end

    
//    //Make sure that label is aligned with scrollView
    [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    cell.scrollView.delegate = cell.scrollView;
    
    [cell.scrollView removeConstraint:cell.centerXAlignmentConstraint];
    
    NSLog (@"labelSize.width is %f and scrollViewWidth is %d", labelSize.width, scrollViewWidth);
    if (labelSize.width>scrollViewWidth) {
        cell.scrollView.scrollEnabled = YES;
        NSLog (@"scroll YES");
//        //this code is needed to prevent scrollable song titles from "flying" around in their scrollview on the 3GS
//        [cell.scrollView addConstraint:cell.centerYAlignmentConstraint];
    }
    else {
        cell.scrollView.scrollEnabled = NO;
        NSLog (@"scroll NO");

    }

//130909 1.1 add iTunesStoreButton end
    

    
    if (indexPath.row == 1) {
        cell.nameLabel.font = [UIFont boldSystemFontOfSize: 44];
        
    }
    return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

//- (void) registerForMediaPlayerNotifications {
//    //    LogMethod();
//
//	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//
//    [notificationCenter addObserver: self
//						   selector: @selector (handle_NowPlayingItemChanged:)
//							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//							 object: musicPlayer];
//
//    [musicPlayer beginGeneratingPlaybackNotifications];
//
//}
//
//// If displaying now-playing item when it changes, update mediaItemForInfo and show info for currently playing song
//- (void) handle_NowPlayingItemChanged: (id) notification {
//    LogMethod();
//    //the rightBarButtonItem is nil when the info is for the currently playing song
//    if (!self.navigationItem.rightBarButtonItem) {
//        self.mediaItemForInfo = [musicPlayer nowPlayingItem];
//        NSLog (@"newTitle is %@", [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle]);
//
////        self.albumInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.iTunesInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.iTunesCommentsViewController.mediaItemForInfo = self.mediaItemForInfo;
////        self.userInfoViewController.mediaItemForInfo = self.mediaItemForInfo;
////        [self loadArrayForTable];
////        [self.infoTableView reloadData];
////        [self.albumImageView setNeedsDisplay];
//
////        [self.albumInfoViewController.view setNeedsDisplay];
////        [self.iTunesInfoViewController.view setNeedsDisplay];
////        [self.iTunesCommentsViewController.view setNeedsDisplay];
////        [self.userInfoViewController.view setNeedsDisplay];
//
//    }
//}
//
//- (void)dealloc {
//    //    LogMethod();
//    [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//												  object: musicPlayer];
//    
//    [musicPlayer endGeneratingPlaybackNotifications];
//    
//}
//130909 1.1 add iTunesStoreButton begin

- (IBAction)linkToiTunesStore:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    //    NSLog (@"touch is %@" ,touch);
    CGPoint currentTouchPosition = [touch locationInView:self.infoTableView];
    //    NSLog (@"touchpoint  is %f %f" , currentTouchPosition.x, currentTouchPosition.y);
    
    NSIndexPath *indexPath = [self.infoTableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.infoTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.iTunesLinkUrl = [NSString stringWithFormat: @"%@&%@", self.artistLinkUrl, myAffiliateID];
    } else {
        self.iTunesLinkUrl = [NSString stringWithFormat: @"%@&%@", self.albumLinkUrl, myAffiliateID];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.iTunesLinkUrl]];

    NSLog (@"iTunesLink is %@", self.iTunesLinkUrl);
    
}

//130909 1.1 add iTunesStoreButton end
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end