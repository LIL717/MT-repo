//
//  ITunesCommentsViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 2/14/13.
//
//

@interface ITunesCommentsViewController : UIViewController < MPMediaPickerControllerDelegate> {
    
}

@property (nonatomic, strong)	MPMusicPlayerController     *musicPlayer;
@property (nonatomic, strong)   MPMediaItem                 *mediaItemForInfo;

@property (strong, nonatomic) IBOutlet UITextView   *comments;

//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceToTop;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceToTop28;
- (void) loadDataForView;


@end
