//
//  TemporaryViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 1/22/13.
//
//

#import "TemporaryViewController.h"

@interface TemporaryViewController ()

@end

@implementation TemporaryViewController
@synthesize songName;
@synthesize song;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.songName.text = self.song;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
