//
//  MTself..m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/29/14.
//
//

#import "MTSearchController.h"

@interface MTSearchController (){
	UITextField *searchTextField;
	UILabel *searchTextLabel;

}

@end

@implementation MTSearchController

- (void) formatSearchBarForInitialViewWithHeight: (CGFloat) searchBarHeight andOffset: (CGFloat) searchBarOffset {
        LogMethod();

	self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, searchBarHeight);

	[self.searchBar setSearchFieldBackgroundPositionAdjustment: UIOffsetMake (0.0, searchBarOffset)];
	NSAttributedString *attrPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAttributedPlaceholder: attrPlaceholder];

	[self.searchBar setBarTintColor: [UIColor blackColor]];
	[self.searchBar setTintColor: [UIColor whiteColor]];

		// find textfield in subviews
	for (int i = (int)[self.searchBar.subviews count] - 1; i >= 0; i--) {
		UIView *view = [self.searchBar.subviews objectAtIndex:i];
			for (int j = (int)[view.subviews count] - 1; j>=0; j--) {
				UIView *subview = [view.subviews objectAtIndex:j];
				if ([subview.class isSubclassOfClass:[UITextField class]]) {
					searchTextField = (UITextField *)subview;
				}
		}
	}
		// set the search Icon to a larger magifying glass
	UIImage *image = [UIImage imageNamed: @"searchIcon.png"];
	UIImageView *iView = [[UIImageView alloc] initWithImage:image];
	searchTextField.leftView = iView;

		//set font size to 44
	searchTextField.font = [UIFont systemFontOfSize:33];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
