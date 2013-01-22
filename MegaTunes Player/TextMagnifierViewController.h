//
//  MagnifierViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
@class TextMagnifierViewController;

@protocol TextMagnifierViewControllerDelegate <NSObject>

- (void)textMagnifierViewControllerDidCancel: (TextMagnifierViewController *)controller;

@end

@interface TextMagnifierViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id <TextMagnifierViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *textToMagnify;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *magnifiedLabel;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelWidth;

- (IBAction)tapDetected:(UITapGestureRecognizer *)sender;
- (IBAction)swipeDownDetected:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeUpDetected:(UISwipeGestureRecognizer *)sender;


@end