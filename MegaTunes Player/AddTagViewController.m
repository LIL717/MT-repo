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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    landscapeOffset = 11.0;
    
//140127 1.2 iOS 7 begin
    
    self.navigationController.navigationBar.topItem.title = @"";
        
    UIButton *tempCheckMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempCheckMarkButton addTarget:self action:@selector(saveTag) forControlEvents:UIControlEventTouchUpInside];
    [tempCheckMarkButton setImage:[UIImage imageNamed:@"checkMarkImage.png"] forState:UIControlStateNormal];
    [tempCheckMarkButton setShowsTouchWhenHighlighted:NO];
    [tempCheckMarkButton sizeToFit];
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:tempCheckMarkButton];
//140127 1.2 iOS 7 end
    
    [self.rightBarButton setIsAccessibilityElement:YES];
    [self.rightBarButton setAccessibilityLabel: NSLocalizedString(@"Done", nil)];
    [self.rightBarButton setAccessibilityTraits: UIAccessibilityTraitButton];
    
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
        
//131203 1.2 iOS 7 begin
        [self.tagName setBackgroundColor: self.pickedColor];
//131203 1.2 iOS 7 end

    }
}
- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    //131216 1.2 iOS 7 begin
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //131216 1.2 iOS 7 end
    //set the navigation bar title
    self.navigationItem.titleView = [self customizeTitleView];
    
    [self updateLayoutForNewOrientation];
    
    [super viewWillAppear: animated];
    
    return;
}
- (UILabel *) customizeTitleView
{
//131205 1.2 iOS 7 begin
    
    //    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44]}].width, 48);
    
//131205 1.2 iOS 7 end
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:44];
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
		//    LogMethod();
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self updateLayoutForNewOrientation];
    
}
- (void) updateLayoutForNewOrientation {
    //    LogMethod();
	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) { //portrait
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
//131203 1.2 iOS 7 begin
        
        [textField setBackgroundColor:[UIColor blackColor]];

//131203 1.2 iOS 7 end
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
    //    if ([self.tagName.text isEqualToString: @""]) {
    //        tagItem.tagName = @"   ";
    //    } else {
    tagItem.tagName = self.tagName.text;
    //    }
    
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
    
    if ([actionType isEqualToString: @"Add"]) {
        NSLog (@"Add tag to TagData");
        //add 1 to the lastObject index and save that as the sortOrder
        //        NSLog (@"self.lastObjectIndex = %d", self.lastObjectIndex);
        
        self.lastObjectIndex += 1;
        tagItem.sortOrder = [NSNumber numberWithInt: self.lastObjectIndex];
        
        [tagData addTagItemToCoreData: tagItem];
    }
    if ([actionType isEqualToString: @"Edit"]) {
        NSLog (@"Update tag in TagData");
        
        tagItem.sortOrder = self.sortOrder;
        [tagData updateTagItemInCoreData: tagItem];
    }
    
    //    [tagData listAll];
//120218 1.2 iOS 7 begin
    [self.navigationController popViewControllerAnimated:YES];
//120218 1.2 iOS 7 ened
}
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}
//140217 1.2 iOS 7 begin
//intercept back Button pressed
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        [self.addTagViewControllerDelegate addTagViewControllerDidCancel:self];
    }
}
//140217 1.2 iOS 7 end
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
    
//131203 1.2 iOS 7 begin
    
    [self.tagName setBackgroundColor: self.pickedColor];
    
//131203 1.2 iOS 7 end


    
    self.hasColor = YES;
    [self.tagName setNeedsDisplay];
    //    [self.tagName setNeedsDisplay];
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

