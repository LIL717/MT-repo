//
//  TimeMagnifierViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/15/12.
//
//

@class TimeMagnifierViewController;

@protocol TimeMagnifierViewControllerDelegate <NSObject>

- (void)timeMagnifierViewControllerDidCancel: (TimeMagnifierViewController *)controller;

@end

@interface TimeMagnifierViewController : UIViewController

@property (nonatomic, weak) id <TimeMagnifierViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *magnifiedText;
@property (strong, nonatomic) NSString *textToMagnify;
@property (nonatomic, retain)   NSTimer                 *playbackTimer;
@property (nonatomic, retain) NSString *timeType;

- (void) updateTime;
- (IBAction)cancel:(id)sender;

@end