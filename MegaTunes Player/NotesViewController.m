//
//  NotesViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "NotesViewController.h"
#import "AppDelegate.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize musicPlayer;


- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
