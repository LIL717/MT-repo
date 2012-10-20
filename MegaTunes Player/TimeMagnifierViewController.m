//
//  TimeMagnifierViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/15/12.
//
//

#import "TimeMagnifierViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface TimeMagnifierViewController ()

@end

@implementation TimeMagnifierViewController

@synthesize magnifiedText;
@synthesize textToMagnify;
@synthesize delegate;
@synthesize playbackTimer;
@synthesize timeType;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];
    [self.magnifiedText.titleLabel setNumberOfLines: 1];
    [self.magnifiedText.titleLabel setMinimumFontSize: 144.];
    [self.magnifiedText.titleLabel setAdjustsFontSizeToFitWidth: YES];
    
    [self.magnifiedText setTitle: self.textToMagnify forState: UIControlStateNormal];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateTime)
                                                   userInfo:nil
                                                    repeats:YES];
    
}
- (void) updateTime {
    MainViewController *mainViewController =( MainViewController *) self.delegate;
    [mainViewController updateTime];
    
    if ([self.timeType isEqualToString: @"MagnifyElapsedTime"]) {
        [self.magnifiedText setTitle:  mainViewController.elapsedTimeLabel.text
                            forState: UIControlStateNormal];
    }
    if ([self.timeType isEqualToString:@"MagnifyRemainingTime" ]) {
        [self.magnifiedText setTitle: mainViewController.remainingTimeLabel.text
                            forState: UIControlStateNormal];
    }
    if ([self.timeType isEqualToString: @"MagnifyPlaylistRemaining"]) {
        [self.magnifiedText setTitle: mainViewController.navigationItem.rightBarButtonItem.title
                            forState: UIControlStateNormal];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self.delegate timeMagnifierViewControllerDidCancel:self];
    
}
@end
