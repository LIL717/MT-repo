//
//  MagnifierViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "TextMagnifierViewController.h"
#import "AppDelegate.h"

@interface TextMagnifierViewController ()

@end

@implementation TextMagnifierViewController

@synthesize magnifiedText;
@synthesize textToMagnify;
@synthesize scrollingLabel;
@synthesize delegate;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];
    
    // Display text 
    // scroll marquee style if too long for field
    
    self.scrollingLabel.text = self.textToMagnify;
    self.scrollingLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:144];
    self.scrollingLabel.font = newFont;
    
//not sure why AutoScrollLabel won't respond to these settings    
//    self.scrollingLabel.pauseInterval = 0.0f;
//    self.scrollingLabel.scrollSpeed = 150;
//    self.scrollingLabel.labelSpacing = 50;
    
//    [self.magnifiedText.titleLabel setNumberOfLines: 1];
//    [self.magnifiedText.titleLabel setMinimumFontSize: 144.];
//    [self.magnifiedText.titleLabel setAdjustsFontSizeToFitWidth: YES];
//
//    [self.magnifiedText setTitle: self.textToMagnify forState: UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    LogMethod();

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(id)sender
{
    LogMethod();
    [self.delegate textMagnifierViewControllerDidCancel:self];

}

@end
