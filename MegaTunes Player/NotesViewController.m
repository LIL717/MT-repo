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
@synthesize songInfo;

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    LogMethod();
//
//    if ((self = [super initWithCoder:aDecoder]))
//    {
////        self.title = @"Notes";
////        self.navigationItem.titleView = [self customizeTitleView];
////        NSLog (@"self.navigationItem.titleview is %@", self.navigationItem.titleView);

//    }
//    return self;
//}

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
- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];

//    UIImage* emptyImage = [UIImage imageNamed:@"notesLightButtonImage.png"];
//    [[UITabBar appearance] setSelectionIndicatorImage:emptyImage];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
