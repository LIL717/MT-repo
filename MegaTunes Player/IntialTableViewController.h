//
//  IntialTableViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import <UIKit/UIKit.h>



@interface IntialTableViewController : UITableViewController <MPMediaPickerControllerDelegate>

@property (nonatomic, strong)           NSArray  *collection;
@property (nonatomic, strong)           NSArray *groupingData;

@end


