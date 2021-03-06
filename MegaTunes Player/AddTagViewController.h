//
//  AddTagViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/13/13.
//
//
@class AddTagViewController;
#import "VBColorPicker.h"


@protocol AddTagViewControllerDelegate <NSObject>

- (void)addTagViewControllerDidCancel: (AddTagViewController *)controller;

@end

@interface AddTagViewController : UIViewController <VBColorPickerDelegate, UITextFieldDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <AddTagViewControllerDelegate> addTagViewControllerDelegate;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToTagConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopToColorViewConstraint;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceSuperviewToColorViewConstraint;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceColorViewToSuperviewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceTagToSuperviewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerXColorViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceTagToColorViewConstraint;
@property (strong, nonatomic) IBOutlet UITextField *tagName;
@property (strong, nonatomic) IBOutlet UIView *colorView;

@property (readwrite)                  CGFloat landscapeOffset;
@property (nonatomic) int lastObjectIndex;
@property (nonatomic, strong) NSString *actionType;
@property (nonatomic, strong) UIColor *pickedColor;
@property (nonatomic, strong) NSString *nameToEdit;
@property (nonatomic, strong) VBColorPicker *cPicker;
@property (readwrite)       BOOL hasColor;
@property (nonatomic, strong) NSNumber *sortOrder;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;


@end
