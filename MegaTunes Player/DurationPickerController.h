//
//  DurationPickerController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

@class DurationPickerController;

@protocol DurationPickerControllerDelegate <NSObject>
- (void)durationPickerController: (DurationPickerController *)controller
                   didSelectDuration:(NSString *)duration;
@end

@interface DurationPickerController : UITableViewController

@property (nonatomic, weak) id <DurationPickerControllerDelegate> delegate;
@property (nonatomic, strong) NSString *duration;

@end