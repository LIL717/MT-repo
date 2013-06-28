//
//  AddTagViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 6/13/13.
//
//

#import "AddTagViewController.h"
#import "TagItem.h"
#import "TagData.h"
#import "UIImage+AdditionalFunctionalities.h"
#import "VBColorPicker.h"

@interface AddTagViewController ()

@end

@implementation AddTagViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize addTagViewControllerDelegate;
@synthesize tagName;
@synthesize landscapeOffset;
@synthesize lastObjectIndex;
@synthesize colorView;
@synthesize verticalSpaceTopToTagConstraint;
@synthesize verticalSpaceTopToColorViewConstraint;
//@synthesize horizontalSpaceSuperviewToColorViewConstraint;
//@synthesize horizontalSpaceColorViewToSuperviewConstraint;
@synthesize horizontalSpaceTagToSuperviewConstraint;
@synthesize horizontalSpaceTagToColorViewConstraint;
@synthesize centerXColorViewConstraint;

//@synthesize rect=_rect;
@synthesize cPicker=_cPicker;
@synthesize pickedColor;
@synthesize actionType;
@synthesize hasColor;
@synthesize nameToEdit;
@synthesize sortOrder;
@synthesize rightBarButton;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    landscapeOffset = 11.0;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    [self.colorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    //make the back arrow for left bar button item
    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(saveTag)];
    
    UIImage *menuBarImageDefault = [[UIImage imageNamed:@"checkMark57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"checkMark68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.rightBarButton setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.rightBarButton setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    [self.tagName setDelegate: self];
    [self.tagName addTarget:self
                          action:@selector(textFieldFinished:)
                forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if (self.cPicker == nil) {
//        [self.view setBackgroundColor:[UIColor grayColor]];
        self.cPicker = [[VBColorPicker alloc] initWithFrame:CGRectMake(0, 0, 202, 202)];
//        [self.cPicker setCenter:self.colorView.center];
        [self.colorView addSubview: self.cPicker];
        [self.cPicker setDelegate:self];
        [self.cPicker showPicker];
        
        // set default YES!
        [_cPicker setHideAfterSelection:NO];
    }
    
    if ([self.actionType isEqualToString: @"Edit"]) {
        self.tagName.text = self.nameToEdit;
        NSLog (@"self.tagName is %@", self.tagName.text);
        UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:pickedColor];
        [self.tagName setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
    
    [super viewWillAppear: animated];
    
    return;
}
-(void) viewDidAppear:(BOOL)animated {
    //    LogMethod();
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidAppear:(BOOL)animated];
}
- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44];
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
    
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    //    LogMethod();
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        //        NSLog (@"portrait");
        
        self.verticalSpaceTopToTagConstraint.constant = 11;
        self.verticalSpaceTopToColorViewConstraint.constant = 96;
//        [self.view removeConstraint: horizontalSpaceSuperviewToColorViewConstraint];
//        [self.view removeConstraint: horizontalSpaceColorViewToSuperviewConstraint];
        self.horizontalSpaceTagToSuperviewConstraint.constant = 10;
        [self.view removeConstraint: horizontalSpaceTagToColorViewConstraint];
        [self.view addConstraint: centerXColorViewConstraint];

        
//        [self.cPicker setCenter:self.colorView.center];


        
    } else {
        //        NSLog (@"landscape");
        self.verticalSpaceTopToTagConstraint.constant += landscapeOffset;
        self.verticalSpaceTopToColorViewConstraint.constant = self.verticalSpaceTopToTagConstraint.constant + 20;
        [self.view removeConstraint: centerXColorViewConstraint];
//        self.horizontalSpaceSuperviewToColorViewConstraint.constant = 120;
//        [self.view addConstraint: self.horizontalSpaceSuperviewToColorViewConstraint];
//        self.horizontalSpaceColorViewToSuperviewConstraint.constant = 5;
//        [self.view removeConstraint: horizontalSpaceSuperviewToColorViewConstraint];
//        [self.view removeConstraint: horizontalSpaceColorViewToSuperviewConstraint];
        self.horizontalSpaceTagToColorViewConstraint.constant = 5;
        [self.view addConstraint: self.horizontalSpaceTagToColorViewConstraint];

        self.horizontalSpaceTagToSuperviewConstraint.constant = 207;

//        [self.cPicker setCenter:self.colorView.center];
//        [self.view addSubview:_cPicker];
    }
}

- (void) textFieldDidBeginEditing: (UITextField *) textField {
//    LogMethod();
    if (!self.hasColor) {
        UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:[UIColor darkGrayColor]];
        [textField setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    }
}

- (void) textFieldDidEndEditing: (UITextField *) textField {
//    LogMethod();

    if (!self.hasColor) {
       [textField setBackgroundColor: [UIColor clearColor]];
    }
}

- (void)saveTag {

    TagItem *tagItem = [TagItem alloc];
    tagItem.tagName = self.tagName.text;
    
    if (self.hasColor) {
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        //        CGFloat hue = 0.0, saturation = 0.0, brightness = 0.0;
        //        [self.pickedColor getHue: &hue saturation: &saturation brightness:&brightness alpha:&alpha];
        [self.pickedColor getRed:&red green:&green blue:&blue alpha:&alpha];
        
        tagItem.tagColorRed = [NSNumber numberWithInt: (int) (red * 255)];
        tagItem.tagColorGreen = [NSNumber numberWithInt: (int) (green * 255)];
        tagItem.tagColorBlue = [NSNumber numberWithInt: (int) (blue * 255)];
        tagItem.tagColorAlpha = [NSNumber numberWithInt: (int) (alpha * 255)];
    }

    TagData *tagData = [TagData alloc];
    tagData.managedObjectContext = self.managedObjectContext;

    if ([actionType isEqualToString: @"Add"]) {
        
        //add 1 to the lastObject index and save that as the sortOrder
//        NSLog (@"self.lastObjectIndex = %d", self.lastObjectIndex);
        
        self.lastObjectIndex += 1;
        tagItem.sortOrder = [NSNumber numberWithInt: self.lastObjectIndex];
        
        [tagData addTagItemToCoreData: tagItem];
    }
    if ([actionType isEqualToString: @"Edit"]) {
        
        tagItem.sortOrder = self.sortOrder;
        [tagData updateTagItemInCoreData: tagItem];
    }
    [self goBackClick];
}
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}
- (void)goBackClick
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.addTagViewControllerDelegate addTagViewControllerDidCancel:self];
    
    
}
// set color from picker
- (void) pickedColor:(UIColor *)color {
    self.pickedColor = color;
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
//    CGFloat hue = 0.0, saturation = 0.0, brightness = 0.0;
//    [self.pickedColor getHue: &hue saturation: &saturation brightness:&brightness alpha:&alpha];
    [self.pickedColor getRed:&red green:&green blue:&blue alpha:&alpha];
//    NSLog (@"pickedColor before saturation change is %f %f %f %f", red, green, blue, alpha);
//    
//    if (brightness > 0.7) {
//        brightness = 0.5;
//    }
////    if (saturation < 0.7) {
//        saturation = 1.0;
////    }
//
//    self.pickedColor = [UIColor colorWithHue: hue
//                                  saturation: saturation
//                                  brightness: brightness
//                                       alpha: alpha];
//    [self.pickedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    NSLog (@"pickedColor after saturation change is %f %f %f %f", red, green, blue, alpha);
    
    UIImage *coloredBackgroundImage = [[UIImage imageNamed: @"list-background.png"] imageWithTint:self.pickedColor];
    [self.tagName setBackgroundColor:[UIColor colorWithPatternImage: coloredBackgroundImage]];
    self.hasColor = YES;
//    [_rect setBackgroundColor:color];
//    [_cPicker hidePicker];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.cPicker removeFromSuperview];
    self.cPicker = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

