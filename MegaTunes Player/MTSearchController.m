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

- (void) formatSearchBarForInitialView {
        LogMethod();

	self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, 99.0);

//	[self.searchBar setSearchTextPositionAdjustment: UIOffsetMake (0.0, -10.0)];
	[self.searchBar setSearchFieldBackgroundPositionAdjustment: UIOffsetMake (0.0, -20.0)];
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

//	CGFloat ViewHeight = 50;
//	CGFloat ViewMargin = 2;
////	CGFloat TextfieldLeftMargin = 35;
//
//		// resize textfield
//	CGRect frame = searchTextField.frame;
//	frame.size.height = ViewHeight;
//	frame.origin.y = ViewMargin;
//	frame.origin.x = ViewMargin;
//	frame.size.width -= ViewMargin / 2;
//	searchTextField.frame = [searchTextField textRectForBounds: frame];

//	- (CGRect)borderRectForBounds:(CGRect)bounds;
//	- (CGRect)textRectForBounds:(CGRect)bounds;
//	- (CGRect)placeholderRectForBounds:(CGRect)bounds;
//	- (CGRect)editingRectForBounds:(CGRect)bounds;
//	- (CGRect)clearButtonRectForBounds:(CGRect)bounds;
//	- (CGRect)leftViewRectForBounds:(CGRect)bounds;
//	- (CGRect)rightViewRectForBounds:(CGRect)bounds;

}
- (void) formatSearchBarForSearchingView {
	LogMethod();

	self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, 44.0);

		//	[self.searchBar setSearchTextPositionAdjustment: UIOffsetMake (0.0, -10.0)];
	[self.searchBar setSearchFieldBackgroundPositionAdjustment: UIOffsetMake (0.0, -10.0)];
	NSAttributedString *attrPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor redColor] }];
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

		//	CGFloat ViewHeight = 50;
		//	CGFloat ViewMargin = 2;
		////	CGFloat TextfieldLeftMargin = 35;
		//
		//		// resize textfield
		//	CGRect frame = searchTextField.frame;
		//	frame.size.height = ViewHeight;
		//	frame.origin.y = ViewMargin;
		//	frame.origin.x = ViewMargin;
		//	frame.size.width -= ViewMargin / 2;
		//	searchTextField.frame = [searchTextField textRectForBounds: frame];

		//	- (CGRect)borderRectForBounds:(CGRect)bounds;
		//	- (CGRect)textRectForBounds:(CGRect)bounds;
		//	- (CGRect)placeholderRectForBounds:(CGRect)bounds;
		//	- (CGRect)editingRectForBounds:(CGRect)bounds;
		//	- (CGRect)clearButtonRectForBounds:(CGRect)bounds;
		//	- (CGRect)leftViewRectForBounds:(CGRect)bounds;
		//	- (CGRect)rightViewRectForBounds:(CGRect)bounds;
	
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
