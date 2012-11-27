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

@synthesize scrollView;
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

    tableWidth = [self calculateTableWidth];
    
    //resize infoTableView for widest title
    UITableView *newTableView = [[UITableView alloc] init];
    CGRect frame = newTableView.frame;
    frame.origin.x = 0;
    frame.size.height = self.infoTableView.frame.size.height;
    frame.size.width = tableWidth;
    newTableView.frame = frame;
    
    // Recenter label vertically within the scroll view
    //    newLabel.center = CGPointMake(newLabel.center.x, roundf(scrollView.center.y - CGRectGetMinY(scrollView.frame)));
    
    //    offset += CGRectGetWidth(self.magnifiedlabel.bounds);
    
//    CGSize size;
//    size.width = tableWidth;
//    size.height = self.infoTableView.frame.size.height;
//    scrollView.contentSize = size;
//    scrollView.contentOffset = CGPointZero;
    
    self.infoTableView.frame = newTableView.frame;
//    self.infoTableView.textAlignment = NSTextAlignmentCenter;
    
//    if (scrollView.contentSize.width>scrollView.frame.size.height) {
//        scrollView.scrollEnabled = YES;
//    }
//    else {
//        scrollView.scrollEnabled = NO;
//    }
    
    
    //
    [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
	[scrollView setCanCancelContentTouches:NO];
	scrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
	[scrollView addSubview: self.infoTableView];
	[scrollView setContentSize:CGSizeMake(self.infoTableView.frame.size.width, self.infoTableView.frame.size.height)];
	[scrollView setScrollEnabled:YES];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
}
- (CGFloat) calculateTableWidth {
    
    CGFloat maxTableWidth = CGRectGetWidth(scrollView.bounds);
    UILabel *magnifiedLabel = [[UILabel alloc] init];
    for (id tableObject in self.songInfoData) {
        if ([tableObject isKindOfClass:[NSString class]]) {
            
            UIFont *font = [UIFont systemFontOfSize:12];
            UIFont *newFont = [font fontWithSize:44];
            magnifiedLabel.font = newFont;
            magnifiedLabel.text = tableObject;
            
            //calculate the label size
            CGSize labelSize = [magnifiedLabel.text sizeWithFont:magnifiedLabel.font
                                                    constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
                                                        lineBreakMode:UILineBreakModeClip];
            
            if (labelSize.width > maxTableWidth) {
                maxTableWidth = labelSize.width;
            }
        }
    }
    return maxTableWidth;
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog (@"portrait");
//        [self.infoTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
        [scrollView setContentInset:UIEdgeInsetsMake(11,0,0,0)];

        //        [self.songInfoViewController.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
    } else {
        NSLog (@"landscape");
//        [self.infoTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [scrollView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//        [self.infoTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}
//-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    // return which subview we want to zoom
//    return self.imageView;
//}

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
        UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
        CGRect frame = newLabel.frame;
        //    frame.origin.x = 0;
        //    frame.size.height = CGRectGetHeight(scrollView.bounds);
        frame.size.width = tableWidth;
        newLabel.frame = frame;
        cell.nameLabel.frame = newLabel.frame;
        
        cell.nameLabel.textAlignment = NSTextAlignmentCenter;
        cell.nameLabel.text = [self.songInfoData objectAtIndex:indexPath.row];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list-background.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];

        
        if (indexPath.row == 1) {
            cell.nameLabel.font = [UIFont boldSystemFontOfSize: 44];
            
        }
        return cell;
    }
//    SongImageCell *imageCell = (SongImageCell *)[tableView
//                                                dequeueReusableCellWithIdentifier:@"SongImageCell"];
    
    UITableViewCell *imageCell = (UITableViewCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"SongInfoCell"];

    if (indexPath.row == 3) {
        UIImage *albumImage = [self.songInfoData objectAtIndex: indexPath.row];
        UIImageView* albumImageView = [[UIImageView alloc] initWithImage:albumImage];
        [albumImageView sizeToFit];
        
        //TODO: need better solution
        //Eyeballing attempt:
        float xPos = albumImage.size.width - 100;
        CGRect albumFrame = albumImageView.frame;
        albumFrame.origin.x = xPos;
        albumImageView.frame = albumFrame;
//        albumImageView.tag = 9000;
        albumImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [imageCell.contentView addSubview:albumImageView];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
        imageCell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"list-background.png"] resizableImageWithCapInsets: insets]];
        
        albumImageView.center = CGPointMake(imageCell.contentView.bounds.size.width/2,albumImageView.center.y);
        
        
//        UIImageView *newImageView = [[UIImageView alloc] initWithFrame: cell.imageView.frame];
//        CGRect frame = newImageView.frame;
//        //    frame.origin.x = 0;
//        //    frame.size.height = CGRectGetHeight(scrollView.bounds);
//        frame.size.width = tableWidth;
//        newImageView.frame = frame;
//        imageCell.imageView.frame = newImageView.frame;
        
//        [imageCell.imageView.image drawInRect:CGRectMake((self.infoTableView.frame.size.width/2) - (imageCell.imageView.frame.size.width/2), imageCell.imageView.frame.origin.y, imageCell.imageView.frame.size.width, imageCell.imageView.frame.size.height)];

//        imageCell.imageView.image = [self.songInfoData objectAtIndex: indexPath.row];
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
    scrollView = nil;
    [super viewDidUnload];
}
@end
