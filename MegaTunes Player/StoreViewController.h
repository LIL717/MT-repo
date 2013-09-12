//
//  StoreViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/12/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIWebView.h>

@interface StoreViewController : UIViewController  <UIWebViewDelegate> {
    UIWebView *webView_;
    NSURL *urlObject_;
    
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURL *urlObject;
@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (readwrite)           BOOL iPodLibraryChanged;





@end
