//
//  TestAppViewController.m
//  TestApp
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright UmlautLlama 2009. All rights reserved.
//

#import "TestAppViewController.h"

@implementation TestAppViewController




// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Animation Delegate

- (void) BL_Animation_WillStart:(NSString *)animationID context:(void *)context
{
	NSLog( @"BL_Animation_WillStart: %@", animationID);
}

- (void) BL_Animation_DidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	NSLog( @"BL_Animation_DidStop: %@", animationID);
	[item0 setAlpha:1.0];
	[item1 setAlpha:1.0];
}



#pragma mark -
#pragma mark UI stuff

- (IBAction) Press0:(id)obj
{
	if( blac0 == nil ) blac0 = [[BLAnimationController alloc]init];

	NSLog( @"Pressed A" );
	[blac0 BL_beginAnimations:@"TestAnimation0" context:nil];
	[blac0 BL_setAnimationDelegate:self];
	[blac0 BL_setAnimationWorkDelegate:item0];
	[blac0 BL_setAnimationDelay:2.0];
	[blac0 BL_setAnimationRepeatCount:3.2];
	[blac0 BL_setAnimationRepeatAutoreverses:YES];
	[blac0 BL_setAnimationDuration:2.0];
	[blac0 BL_commitAnimations];	
}

- (IBAction) Press1:(id)obj
{
	if( blac1 == nil ) blac1 = [[BLAnimationController alloc]init];

	NSLog( @"Pressed B" );
	[blac1 BL_beginAnimations:@"TestAnimation1" context:nil];
	[blac1 BL_setAnimationDelegate:self];
	[blac1 BL_setAnimationWorkDelegate:item1];
	[blac1 BL_setAnimationRepeatCount:1];
	[blac1 BL_setAnimationDuration:1.0];
	[blac1 BL_commitAnimations];	
}


@end
