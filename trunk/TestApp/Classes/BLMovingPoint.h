//
//  BLMovingPoint.h
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLAnimationController.h"


@interface BLMovingPoint : BLAnimationController <BLAnimationWorkDelegate>
{
	// current values
	float x;
	float y;
	float z;
	CGPoint p;
	
	// start values
	float fromX;
	float fromY;
	float fromZ;
	
	// end values
	float toX;
	float toY;
	float toZ;
}

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;
@property (readonly) CGPoint p;

- (id)init;
- (id)initWith:(float)tx y:(float)ty z:(float)tz;
- (id)initWith:(float)tx y:(float)ty;
- (id)initWith:(CGPoint) tp;

- (void) set:(float)tx y:(float)ty z:(float)tz;
- (void) set:(float)tx y:(float)ty;
- (void) set:(CGPoint)tp;

- (void) moveTo:(float)tx y:(float)ty z:(float)tz;
- (void) moveTo:(float)tx y:(float)ty;
- (void) moveTo:(CGPoint)tp;

@end
