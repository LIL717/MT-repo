//
//  NotesViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "NotesViewController.h"
#import "AppDelegate.h"
#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"


#import "bass.h"
#import "bass_fx.h" 
#import <AudioToolbox/AudioToolbox.h> // for the core audio constants


@interface NotesViewController ()

@end

@implementation NotesViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize mediaItemForInfo;

@synthesize userDataForMediaItem;
@synthesize bpm;
@synthesize userClassification;
@synthesize userNotes;
@synthesize lastPlayedDate;

@synthesize verticalSpaceToTop;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    //    UIImage* emptyImage = [UIImage imageNamed:@"notesLightButtonImage.png"];
    //    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //check to see if there is user data for this media item
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    self.userDataForMediaItem = [mediaItemUserData containsItem: [mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID]];
    
    //if there is an MPMediaItemPropertyBeatsPerMinute value, use that, otherwise see if one has been stored in User Data and if not, then calculate one (will be stored in user data when this view is deallocated)
    if ([[self.mediaItemForInfo valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue] > 0) {
        //save this value in userDataForMediaItem in Core Data
        self.userDataForMediaItem.bpm = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyBeatsPerMinute];
        NSLog (@"Apple's BPM %d", [[self.mediaItemForInfo valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue]);
    } else {
        if (self.userDataForMediaItem.bpm > 0) {
            NSLog (@"User's BPM %d", [self.userDataForMediaItem.bpm intValue]);
        } else {
            [self calculateBPM];
            //self.userDataForMediaItem.bpm is set when it is calculated
        }
    }
    if (self.userDataForMediaItem.bpm > 0) {
        self.bpm.text = [[NSString alloc] initWithFormat:@"%2dBPM", [self.userDataForMediaItem.bpm intValue]];

    }
//    self.bpm.text = [[NSString alloc] initWithFormat:@"%2@ BPM", self.userDataForMediaItem.bpm];

    self.userClassification.text = self.userDataForMediaItem.userClassification;
    self.userNotes.text = self.userDataForMediaItem.userNotes;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate *date = self.userDataForMediaItem.lastPlayedDate;
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSLog(@"formattedDateString: %@", formattedDateString);
    // Output for locale en_US: "formattedDateString: 10/31/13".
    self.lastPlayedDate.text = formattedDateString;
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        
        [self.view addConstraint:self.verticalSpaceToTop];

    } else {
        NSLog (@"landscape");
        [self.view removeConstraint:self.verticalSpaceToTop];

        // Set top row spacing to superview top 
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userClassification attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:28]];

    }
}

- (void) viewWillAppear:(BOOL)animated
{
    LogMethod();
    [super viewWillAppear: animated];
    
    //    NSLog (@"tabBarItem.title is %@", self.tabBarItem.title);
    //    self.title = @"Notes";
    //    self.navigationItem.titleView = [self customizeTitleView];
    //    NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);
    
}
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

-(void) calculateBPM {
    LogMethod();
    
    NSURL *url = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetPassthrough];
//                                                                      presetName: AVAssetExportPresetAppleM4A];
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);

    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *exportFile = [myDocumentsDirectory() stringByAppendingPathComponent:
                            @"exported.m4a"];
   
    myDeleteFile(exportFile);

    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    

    exporter.outputURL = exportURL;
    
   
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@",exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");
                [self continueCalculatingBPM];
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting"); break;}
            case AVAssetExportSessionStatusCancelled: {
                NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
            case AVAssetExportSessionStatusWaiting: {
                NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
            default: { NSLog (@"didn't get export status"); break;}
        }
    }];
    return;
}
#pragma mark conveniences
NSString* myDocumentsDirectory() {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];;
}
void myDeleteFile (NSString* path) {
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSError *deleteErr = nil;
		[[NSFileManager defaultManager] removeItemAtPath:path error:&deleteErr];
		if (deleteErr) {
			NSLog (@"Can't delete %@: %@", path, deleteErr);
		}
	}
}
- (void) continueCalculatingBPM {
    LogMethod();

    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing. To be called before BASS_Init.
    
    if (HIWORD(BASS_GetVersion()) != BASSVERSION) {
        NSLog(@"An incorrect version of BASS was loaded");
    }
    
    // Initialize default device.
    if (!BASS_Init(-1, 44100, 0, NULL, NULL)) {
        NSLog(@"Can't initialize device");
        
    }
    
    NSString *respath = [myDocumentsDirectory() stringByAppendingPathComponent: @"exported.m4a"];
    NSError *error = nil;
    NSString *str = [NSString stringWithContentsOfFile:respath encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"There was an error: %@", [error description]);
    } else {
        NSLog(@"respath file data: %@", str);
    }
//    NSLog (@" respath is %@", respath);
    
    DWORD chan1;
    if(!(chan1=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
        NSLog(@"Can't load stream!");
    }
    
    HSTREAM mainStream=BASS_StreamCreateFile(FALSE, [respath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
    
    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
    NSLog(@"Play back duration is %f",playBackDuration);
    HSTREAM bpmStream=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
    BASS_ChannelPlay(bpmStream,FALSE);
    //    BPMPROCESSPROC *proc = (bpmStream, 1.0, NULL);
    float BpmValue= BASS_FX_BPM_DecodeGet(bpmStream,
                                          0.0,
                                          playBackDuration,
                                          MAKELONG(45,256),
                                          BASS_FX_BPM_MULT2,
                                          NULL,
                                          NULL);
    if (BpmValue > 0) {
        self.bpm.text = [[NSString alloc] initWithFormat:@"%02.0fBPM", BpmValue];
    }
    //fill in bpm for Core Data - if we went through here there was neither a bpm existing on the mediaItem or a previously calculated bpm
    userDataForMediaItem.bpm = [NSNumber numberWithFloat: BpmValue];
    NSLog(@"BPM is %f",BpmValue);
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
    //should this be on dealloc instead??
    LogMethod();
    [super viewWillDisappear: animated];
    

}
- (void)dealloc {
    LogMethod();
    //update or add object to Core Data
    MediaItemUserData *mediaItemUserData = [MediaItemUserData alloc];
    mediaItemUserData.managedObjectContext = self.managedObjectContext;
    
    NSNumber *saveBpm = self.userDataForMediaItem.bpm;
    self.userDataForMediaItem = [[UserDataForMediaItem alloc] init];
    self.userDataForMediaItem.title = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyTitle];
    self.userDataForMediaItem.persistentID = [self.mediaItemForInfo valueForProperty: MPMediaItemPropertyPersistentID];
    self.userDataForMediaItem.userClassification = self.userClassification.text;
    self.userDataForMediaItem.userNotes = self.userNotes.text;
    self.userDataForMediaItem.bpm = saveBpm;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:self.lastPlayedDate.text];

    self.userDataForMediaItem.lastPlayedDate = dateFromString;
    [mediaItemUserData addMediaItemToCoreData: self.userDataForMediaItem];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
