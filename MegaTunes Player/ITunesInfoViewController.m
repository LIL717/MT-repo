//
//  ITunesInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "ITunesInfoViewController.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"
//#import "InfoTabBarController.h"
#import "SongInfoCell.h"



#import "bass.h"
#import "bass_fx.h" 
#import <AudioToolbox/AudioToolbox.h> // for the core audio constants


@interface ITunesInfoViewController ()

@end

@implementation ITunesInfoViewController

//@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize mediaItemForInfo;

//@synthesize userDataForMediaItem;
@synthesize songInfoData;

@synthesize lastPlayedDate;
@synthesize lastPlayedDateTitle;
@synthesize bpm;
@synthesize userGrouping;
@synthesize userGroupingTitle;

@synthesize saveBPM;
//@synthesize infoTabBarController;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    //    UIImage* emptyImage = [UIImage imageNamed:@"notesLightButtonImage.png"];
    //    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    [self loadTableData];
    
}
- (void) loadTableData {
    NSDate *date = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyLastPlayedDate];
    
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        self.lastPlayedDate = [NSString stringWithFormat: @"%@ %@", self.lastPlayedDateTitle, formattedDateString];
    } else {
        self.lastPlayedDate = @"No Last Played Date";
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
    } else {
        self.bpm = @"No BPM";
    }
    
    if ([self.mediaItemForInfo valueForProperty: MPMediaItemPropertyUserGrouping]) {
        self.userGrouping = [NSString stringWithFormat: @"%@ %@", self.userGroupingTitle, [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyUserGrouping]];
    } else {
        self.userGrouping = @"No iTunes Grouping";
    }
    
    self.songInfoData = [NSArray arrayWithObjects: self.lastPlayedDate, self.bpm, self.userGrouping,  nil];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,-11,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.lastPlayedDateTitle = @"Played:";
        self.userGroupingTitle = @"Grouping:";
        
        
        
    } else {
        NSLog (@"landscape");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.lastPlayedDateTitle = @"Last Played:";
        self.userGroupingTitle = @"iTunes Grouping:";
        
    }
}
//
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
    
    
    //calculate the label size to fit the text with the font size
    //    NSLog (@"size of nextSongLabel is %f", self.nextSongLabel.frame.size.width);
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(cell.nameLabel.bounds))
                                           lineBreakMode:NSLineBreakByClipping];
    
    //build a new label that will hold all the text
    UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
    CGRect frame = newLabel.frame;
    frame.size.height = CGRectGetHeight(cell.nameLabel.bounds);
    frame.size.width = labelSize.width + 1;
    newLabel.frame = frame;
    
    //    NSLog (@"size of newLabel is %f", frame.size.width);
    
    //calculate the size (w x h) for the scrollview content
    CGSize size;
    size.width = CGRectGetWidth(newLabel.bounds);
    size.height = CGRectGetHeight(newLabel.bounds);
    cell.scrollView.contentSize = size;
    cell.scrollView.contentOffset = CGPointZero;
    
    //set the UIOutlet label's frame to the new sized frame
    cell.nameLabel.frame = newLabel.frame;
    
    //    NSLog (@"cell.scrollView.contentSize.width is %f", cell.scrollView.contentSize.width);
    //    NSLog (@"cell.scrollView.frame.size.width is %f", cell.scrollView.frame.size.width);
    //enable scroll if the content will not fit within the scrollView
    if (cell.scrollView.contentSize.width>cell.scrollView.frame.size.width) {
        cell.scrollView.scrollEnabled = YES;
        //        NSLog (@"scrollEnabled");
    }
    else {
        cell.scrollView.scrollEnabled = NO;
        //        NSLog (@"scrollDisabled");
        
    }
    
    return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

//-(void) calculateBPM {
//    LogMethod();
//    
//    NSURL *url = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyAssetURL];
//    
//    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
//
//    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
//                                                                      presetName: AVAssetExportPresetPassthrough];
////                                                                      presetName: AVAssetExportPresetAppleM4A];
//    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
//
//    exporter.outputFileType = @"com.apple.m4a-audio";
//    
//    NSString *exportFile = [myDocumentsDirectory() stringByAppendingPathComponent:
//                            @"exported.m4a"];
//   
//    myDeleteFile(exportFile);
//
//    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
//    
//
//    exporter.outputURL = exportURL;
//    
//   
//    // do the export
//    [exporter exportAsynchronouslyWithCompletionHandler:^{
//        int exportStatus = exporter.status;
//        switch (exportStatus) {
//            case AVAssetExportSessionStatusFailed: {
//                NSError *exportError = exporter.error;
//                NSLog (@"AVAssetExportSessionStatusFailed: %@",exportError);
//                break;
//            }
//            case AVAssetExportSessionStatusCompleted: {
//                NSLog (@"AVAssetExportSessionStatusCompleted");
//                [self continueCalculatingBPM];
//                break;
//            }
//            case AVAssetExportSessionStatusUnknown: {
//                NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
//            case AVAssetExportSessionStatusExporting: {
//                NSLog (@"AVAssetExportSessionStatusExporting"); break;}
//            case AVAssetExportSessionStatusCancelled: {
//                NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
//            case AVAssetExportSessionStatusWaiting: {
//                NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
//            default: { NSLog (@"didn't get export status"); break;}
//        }
//    }];
//    return;
//}
//#pragma mark conveniences
//NSString* myDocumentsDirectory() {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	return [paths objectAtIndex:0];;
//}
//void myDeleteFile (NSString* path) {
//	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//		NSError *deleteErr = nil;
//		[[NSFileManager defaultManager] removeItemAtPath:path error:&deleteErr];
//		if (deleteErr) {
//			NSLog (@"Can't delete %@: %@", path, deleteErr);
//		}
//	}
//}
//- (void) continueCalculatingBPM {
//    LogMethod();
//
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
//    NSString *respath = [myDocumentsDirectory() stringByAppendingPathComponent: @"exported.m4a"];
//    NSError *error = nil;
//    NSString *str = [NSString stringWithContentsOfFile:respath encoding:NSUTF8StringEncoding error:&error];
//    if (error != nil) {
//        NSLog(@"There was an error: %@", [error description]);
//    } else {
//        NSLog(@"respath file data: %@", str);
//    }
////    NSLog (@" respath is %@", respath);
//    
//    DWORD chan1;
//    if(!(chan1=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
//        NSLog(@"Can't load stream!");
//    }
//    
//    HSTREAM mainStream=BASS_StreamCreateFile(FALSE, [respath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
//    
//    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
//    NSLog(@"Play back duration is %f",playBackDuration);
//    HSTREAM bpmStream=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
//    BASS_ChannelPlay(bpmStream,FALSE);
//    //    BPMPROCESSPROC *proc = (bpmStream, 1.0, NULL);
//    float BpmValue= BASS_FX_BPM_DecodeGet(bpmStream,
//                                          0.0,
//                                          playBackDuration,
//                                          MAKELONG(45,256),
//                                          BASS_FX_BPM_MULT2,
//                                          NULL,
//                                          NULL);
//    if (BpmValue > 0) {
//        self.bpm.text = [[NSString alloc] initWithFormat:@"%02.0fBPM", BpmValue];
//    }
//    //fill in bpm for Core Data - if we went through here there was neither a bpm existing on the mediaItem or a previously calculated bpm
//    userDataForMediaItem.bpm = [NSNumber numberWithFloat: BpmValue];
//    NSLog(@"BPM is %f",BpmValue);
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
