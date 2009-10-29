//
//  BLAnimatingValue.h
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLAnimationController.h"


@interface BLAnimatingValue : BLAnimationController <BLAnimationWorkDelegate>
{
	// current values
	float v;
	
	// start values
	float fromV;
	
	// end values
	float toV;
}

@property (readonly) float v;

- (id)init;
- (id)initWithValue:(float)v;

- (void) set:(float)tv;
- (void) animateTo:(float)tv;

@end
