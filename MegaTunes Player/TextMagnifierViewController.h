//
//  MagnifierViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
@class TextMagnifierViewController;
#import "AutoScrollLabel.h"


@protocol TextMagnifierViewControllerDelegate <NSObject>

- (void)textMagnifierViewControllerDidCancel: (TextMagnifierViewController *)controller;

@end

@interface TextMagnifierViewController : UIViewController <UIGestureRecognizerDelegate>


@property (nonatomic, weak) id <TextMagnifierViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *magnifiedText;
@property (strong, nonatomic) NSString *textToMagnify;
@property (nonatomic, strong) IBOutlet AutoScrollLabel	*scrollingLabel;


- (IBAction)cancel:(id)sender;

@end