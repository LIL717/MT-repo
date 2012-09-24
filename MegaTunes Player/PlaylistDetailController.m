//
//  PlaylistDetailController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "PlaylistDetailController.h"
#import "playlist.h"

@interface PlaylistDetailController ()


@end

@implementation PlaylistDetailController

@synthesize delegate;
@synthesize nameTextField;

NSString *duration;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init PlaylistDetailController");
		duration = @"61:00";
	}
	return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.durationLabel.text = duration;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickDuration"])
	{
		DurationPickerController *durationPickerController =
        segue.destinationViewController;
		durationPickerController.delegate = self;
		durationPickerController.duration = duration;
	}
}
#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        [self.nameTextField becomeFirstResponder];
    
}
- (IBAction)cancel:(id)sender
{
	[self.delegate playlistDetailControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
	Playlist *playlist = [[Playlist alloc] init];
	playlist.name = self.nameTextField.text;
	playlist.duration = duration;
    playlist.cover = [UIImage imageNamed:@"vinyl-record.jpg"];

	[self.delegate playlistDetailController:self
                                  didAddPlaylist:playlist];
}
- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setDurationLabel:nil];
    [super viewDidUnload];
}
#pragma mark - DurationPickerControllerDelegate

- (void)durationPickerController: (DurationPickerController *)controller
                   didSelectDuration:(NSString *)theDuration
{
	duration = theDuration;
	self.durationLabel.text = duration;
	[self.navigationController popViewControllerAnimated:YES];
}
@end
