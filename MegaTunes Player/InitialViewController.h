//
//  InitialViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

@interface InitialViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (nonatomic, strong)           NSArray  *playlists;
@property (strong, nonatomic) IBOutlet  UIButton *choosePlaylist;

- (IBAction)	choosePlaylist:	(id) sender;

@end
