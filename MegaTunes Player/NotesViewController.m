//
//  NotesViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "NotesViewController.h"
#import "AppDelegate.h"
#import "SongInfo.h"


#import "bass.h"
#import "bass_fx.h" 

@interface NotesViewController ()

@end

@implementation NotesViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize songInfo;

@synthesize bpm;
@synthesize userClassification;
@synthesize userNotes;


- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
    
    //    UIImage* emptyImage = [UIImage imageNamed:@"notesLightButtonImage.png"];
    //    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    [self determineBPM];
    
}
- (void) determineBPM {
    //****************************    //BPM   can't get this to work
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing. To be called before BASS_Init.
    
    if (HIWORD(BASS_GetVersion()) != BASSVERSION) {
        NSLog(@"An incorrect version of BASS was loaded");
    }
    
    // Initialize default device.
    if (!BASS_Init(-1, 44100, 0, NULL, NULL)) {
        NSLog(@"Can't initialize device");
        
    }
    
    //NSArray *array = [NSArray arrayWithObject:@""
    
    NSString *respath = self.songInfo.songName;
    
    DWORD chan1;
    if(!(chan1=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
        NSLog(@"Can't load stream!");
        
    }
    
    HSTREAM mainStream=BASS_StreamCreateFile(FALSE, [respath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
    
    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
    NSLog(@"Play back duration is %f",playBackDuration);
    HSTREAM bpmStream=BASS_StreamCreateFile(FALSE, [respath UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
    BASS_ChannelPlay(bpmStream,FALSE);
    float BpmValue= BASS_FX_BPM_DecodeGet(bpmStream,0.0,
                                          playBackDuration,
                                          MAKELONG(45,256),
                                          BASS_FX_BPM_MULT2,
                                          NULL);
    NSLog(@"BPM is %f",BpmValue);
    
    //this is a user-Entered field - so would need to pass MediaItem to use it, maybe display this if its available or the calculated one if not.
//    self.bmp.text = [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute] stringValue];
//    NSLog (@"%d", [[song valueForProperty: MPMediaItemPropertyBeatsPerMinute]  intValue]);
    //     *********************************************/
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
