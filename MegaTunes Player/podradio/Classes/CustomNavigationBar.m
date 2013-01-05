//
//  CustomNavigationBar.m
//  Custom Navigation Bar
//

#import "CustomNavigationBar.h"

@interface CustomNavigationBar ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSMutableDictionary *backgroundImages;
- (void)updateBackgroundImage;
@end


@implementation CustomNavigationBar

@synthesize backgroundImages = _backgroundImages;
@synthesize backgroundImageView = _backgroundImageView;

+ (void)initialize {

    UIImage *backBgImage = [UIImage imageNamed:@"megaBack.png"];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 23.0f, 0.0f, 0.0f);
    backBgImage = [backBgImage resizableImageWithCapInsets: contentInsets];

    [[UIBarButtonItem appearanceWhenContainedIn:[CustomNavigationBar class], nil]
     setBackButtonBackgroundImage:backBgImage forState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[CustomNavigationBar class], nil]
     setBackButtonBackgroundImage:backBgImage forState:UIControlStateNormal
     barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[CustomNavigationBar class], nil]
     setBackButtonBackgroundVerticalPositionAdjustment:2.0f
     forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[CustomNavigationBar class], nil]
     setBackButtonBackgroundVerticalPositionAdjustment:8.0f
     forBarMetrics:UIBarMetricsLandscapePhone];
}

#pragma mark - View Lifecycle


#pragma mark - Background Image

- (NSMutableDictionary *)backgroundImages
{
    if (_backgroundImages == nil)
    {
        _backgroundImages = [[NSMutableDictionary alloc] init];
    }
    
    return _backgroundImages;
}

- (void)setBackgroundImage:(UIImage *)bgImage forBarMetrics:(UIBarMetrics)barMetrics
{

    if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [super setBackgroundImage:bgImage forBarMetrics:barMetrics];
    }
    else
    {
        [[self backgroundImages] setObject:bgImage forKey:[NSNumber numberWithInt:barMetrics]];
        [self updateBackgroundImage];

    }

}

- (void)updateBackgroundImage
{
    UIBarMetrics metrics = ([self bounds].size.height > 40.0) ? UIBarMetricsDefault : UIBarMetricsLandscapePhone;
    UIImage *image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:metrics]];

    if (image == nil && metrics != UIBarMetricsDefault)
    {
        image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:UIBarMetricsDefault]];
    }
    
    if (image != nil)
    {
        [[self backgroundImageView] setImage:image];
    }
}

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    
    return _backgroundImageView;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_backgroundImageView != nil)
    {
        [self updateBackgroundImage];
        [self sendSubviewToBack:_backgroundImageView];
    }
}

@end
