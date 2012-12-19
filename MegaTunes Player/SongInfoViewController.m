//
//  SongInfoViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 11/16/12.
//
//

#import "SongInfoViewController.h"
#import "AppDelegate.h"
#import "SongInfo.h"
#import "SongInfoCell.h"
#import "SongImageCell.h"

@interface SongInfoViewController ()

@end

@implementation SongInfoViewController

@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize songInfo;

@synthesize infoTableView;

@synthesize songInfoData;
CGFloat tableWidth;


- (void)viewDidLoad
{
    //    LogMethod();
    [super viewDidLoad];
//    self.scrollView.delegate = self;
//    self.scrollView.contentSize = self.imageView.image.size;
//    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
    self.songInfoData = [NSArray arrayWithObjects: self.songInfo.artist, self.songInfo.songName, self.songInfo.album, self.songInfo.albumImage, nil];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
    } else {
        NSLog (@"landscape");
        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
#pragma mark Table view methods________________________
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
    return [self.songInfoData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    SongInfoCell *cell = (SongInfoCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"SongInfoCell"];
    
    if (indexPath.row < 3) {
        cell.nameLabel.text = [self.songInfoData objectAtIndex:indexPath.row];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list-background.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];

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
        
        //    NSLog (@"size of nextSongScrollView is %f", self.nextSongScrollView.frame.size.width);
        
        //enable scroll if the content will not fit within the scrollView
        if (cell.scrollView.contentSize.width>cell.scrollView.frame.size.width) {
            cell.scrollView.scrollEnabled = YES;
            //        NSLog (@"scrollEnabled");
        }
        else {
            cell.scrollView.scrollEnabled = NO;
            //        NSLog (@"scrollDisabled");
            
        }
        
        if (indexPath.row == 1) {
            cell.nameLabel.font = [UIFont boldSystemFontOfSize: 44];
            
        }
        return cell;
    }
//    SongImageCell *imageCell = (SongImageCell *)[tableView
//                                                dequeueReusableCellWithIdentifier:@"SongImageCell"];
    
    UITableViewCell *imageCell = (UITableViewCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"SongImageCell"];

    if (indexPath.row == 3) {
//        UIImage *albumImage = [self.songInfoData objectAtIndex: indexPath.row];
////        UIImageView* albumImageView = [[UIImageView alloc] initWithImage:albumImage];
////        //calculate the size (w x h) for the albumImageView
//        SongImageCell *songImageCell = [[SongImageCell alloc] init];
//        songImageCell.imageView = [[UIImageView alloc] initWithImage:albumImage];
//
//        CGSize imageSize;
//        imageSize.width = imageCell.contentView.bounds.size.width;
//        imageSize.height = imageCell.contentView.bounds.size.width;
//        [imageCell.imageView sizeThatFits: imageSize];
//
//        //TODO: need better solution
//        //Eyeballing attempt:
//        float xPos = albumImage.size.width - 100;
//        CGRect albumFrame = albumImageView.frame;
//        albumFrame.origin.x = xPos;
//        albumImageView.frame = albumFrame;
////        albumImageView.tag = 9000;
//        albumImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
//        [imageCell.contentView addSubview:albumImageView];
        
//        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
//        imageCell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"list-background.png"] resizableImageWithCapInsets: insets]];
        
//        albumImageView.center = CGPointMake(imageCell.contentView.bounds.size.width/2,albumImageView.center.y);
        
        
//        UIImageView *newImageView = [[UIImageView alloc] initWithFrame: cell.imageView.frame];
//        CGRect frame = newImageView.frame;
//        //    frame.origin.x = 0;
//        //    frame.size.height = CGRectGetHeight(scrollView.bounds);
//        frame.size.width = tableWidth;
//        newImageView.frame = frame;
//        imageCell.imageView.frame = newImageView.frame;
        
//        [imageCell.imageView.image drawInRect:CGRectMake((self.infoTableView.frame.size.width/2) - (imageCell.imageView.frame.size.width/2), imageCell.imageView.frame.origin.y, imageCell.imageView.frame.size.width, imageCell.imageView.frame.size.height)];

        imageCell.imageView.image = [self.songInfoData objectAtIndex: indexPath.row];
        return imageCell;
    }
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

//    [self setImageView:nil];
    [self setInfoTableView:nil];
//    [self setScrollView:nil];
//    scrollView = nil;
    [super viewDidUnload];
}
@end
