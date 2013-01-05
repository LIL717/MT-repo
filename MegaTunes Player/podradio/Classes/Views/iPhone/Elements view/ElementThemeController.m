//
//  ElementThemeController.m
//  PodRadio
//
//  Created by Tope on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ElementThemeController.h"
#import "AppDelegate.h"
#import "UIImage+iPhone5.h"


@implementation ElementThemeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[appDelegate.colorSwitcher processImageWithName:@"background.png"]]];
    
    [self addButtonAtLocation:CGRectMake(10, 120, 298, 57) 
          WithBackgroundImage:@"blue-button" 
                     andTitle:@"Normal Button"];
    
    [self addButtonAtLocation:CGRectMake(10, 190, 298, 57) 
          WithBackgroundImage:@"red-button" 
                     andTitle:@"Cancel Button"];
    
    [self addButtonAtLocation:CGRectMake(10, 260, 298, 57) 
          WithBackgroundImage:@"green-button" 
                     andTitle:@"Confirm Button"];
    
    
    [self customizeLabel];
    [self customizeTextField];
    [self addSlider];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)customizeLabel
{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 200, 30)];
    [textLabel setTextColor:[UIColor colorWithRed:150.0/255 green:198.0/255 blue:255.0/255 alpha:1.0]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [textLabel setText:@"Label"];
    
    [self.view addSubview:textLabel];
}

-(void)customizeTextField
{
    
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, 268, 30)];
    textField.delegate = self;
    UIImage *textBackground = [UIImage tallImageNamed:@"text-input.png"];
    [textField setBackground:textBackground];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    
    [textField setText:@"Text Input"];
    
    [self.view addSubview:textField];
}


-(void)addSlider
{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 330, 298, 10)];
    
    [slider setValue:0.5];
    [self.view addSubview:slider];
}

-(void)addButtonAtLocation:(CGRect)location WithBackgroundImage:(NSString*)imageName andTitle:(NSString*)title
{
    UIButton * button = [[UIButton alloc] initWithFrame:location];
    UIImage * bgImage = [UIImage tallImageNamed:imageName];
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [button.titleLabel setShadowOffset:CGSizeMake(1.0, -1.0)];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    
    [self.view addSubview:button];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
