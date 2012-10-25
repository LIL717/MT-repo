//
//  MagnifierViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//

#import "TextMagnifierViewController.h"
#import "AppDelegate.h"
//#import "ScrollLabel.h"

@interface TextMagnifierViewController ()

@end

@implementation TextMagnifierViewController

@synthesize scrollView;
@synthesize textToMagnify;
@synthesize magnifiedLabel;
@synthesize delegate;

- (void)viewDidLoad
{
    LogMethod();
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];

    // Display text

    self.magnifiedLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:144];
    self.magnifiedLabel.font = newFont;
    self.magnifiedLabel.text = self.textToMagnify;
    
    //calculate the label size
    CGSize labelSize = [self.magnifiedLabel.text sizeWithFont:self.magnifiedLabel.font
                                    constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(scrollView.bounds))
                                           lineBreakMode:UILineBreakModeClip];

    UILabel *newLabel = [[UILabel alloc] initWithFrame: self.magnifiedLabel.frame];
    CGRect frame = newLabel.frame;
//    frame.origin.x = 0;
    frame.size.height = CGRectGetHeight(scrollView.bounds);
    frame.size.width = labelSize.width;
    newLabel.frame = frame;

    // Recenter label vertically within the scroll view
    newLabel.center = CGPointMake(newLabel.center.x, roundf(scrollView.center.y - CGRectGetMinY(scrollView.frame)));
    
//    offset += CGRectGetWidth(label.bounds) + _labelSpacing;

//    CGSize size;
//    size.width = CGRectGetWidth(self.magnifiedLabel.bounds) + CGRectGetWidth(scrollView.bounds);
//    size.height = CGRectGetHeight(scrollView.bounds);
//    scrollView.contentSize = size;
//    scrollView.contentOffset = CGPointZero;

//// If the label is bigger than the space allocated, then it should scroll
//if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds))
//{

    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width,scrollView.frame.size.height);
    self.magnifiedLabel.frame = newLabel.frame;


}
- (void)didReceiveMemoryWarning
{
    LogMethod();

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//    Tap to cancel
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    [self.delegate textMagnifierViewControllerDidCancel:self];
    
}

- (IBAction)swipeDetected:(UIPanGestureRecognizer *)sender {
    self.magnifiedLabel.text= @"Swipe";

}

//- (IBAction)pinchDetected:(UIGestureRecognizer *)sender {
//    
//    CGFloat scale =
//    [(UIPinchGestureRecognizer *)sender scale];
//    CGFloat velocity =
//    [(UIPinchGestureRecognizer *)sender velocity];
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"Pinch - scale = %f, velocity = %f",
//                              scale, velocity];
//    self.label.text = resultString;
//}

//- (IBAction)rotationDetected:(UIGestureRecognizer *)sender {
//    CGFloat radians =
//    [(UIRotationGestureRecognizer *)sender rotation];
//    CGFloat velocity =
//    [(UIRotationGestureRecognizer *)sender velocity];
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"Rotation - Radians = %f, velocity = %f",
//                              radians, velocity];
//    self.label.text = resultString;
//}

//- (IBAction)longPressDetected:(UIGestureRecognizer *)sender {
//    self.label.text = @"Long Press";
//}
- (void)viewDidUnload {

    [self setScrollView:nil];
    [self setMagnifiedLabel:nil];
    [super viewDidUnload];
}

@end
