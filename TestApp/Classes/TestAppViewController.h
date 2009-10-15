//
//  TestAppViewController.h
//  TestApp
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright UmlautLlama 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLAnimationController.h"
#import "AnItem.h"

@interface TestAppViewController : UIViewController <BLAnimationControllerDelegate>
{
	IBOutlet AnItem * item0;
	BLAnimationController * blac0;
	
	IBOutlet AnItem * item1;
	BLAnimationController * blac1;
}

- (IBAction) Press0:(id)obj;
- (IBAction) Press1:(id)obj;

@end

