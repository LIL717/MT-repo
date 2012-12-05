//
//  UIImage+AdditionalFunctionalities.h
//  MegaTunes Player
//
//  Created by Lori Hill on 12/3/12.
//
//
@interface UIImage (AdditionalFunctionalities)

//TintColor...
- (UIImage *)imageWithTint:(UIColor *)tintColor;
//scale and resize...
- (UIImage *)scaleToSize:(CGSize)size;

@end
