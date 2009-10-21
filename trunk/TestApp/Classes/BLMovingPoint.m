//
//  BLMovingPoint.m
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import "BLMovingPoint.h"


@implementation BLMovingPoint


- (id)init
{
	if (self = [super init]) {
        // Initialization code
		[self set:0.0 y:0.0 z:0.0];
    }
    return self;
}

- (id)initWith:(float)tx y:(float)ty z:(float)tz
{
    if (self = [super init]) {
        // Initialization code
		[self set:tx y:ty z:tz];
    }
    return self;
}


- (id)initWith:(float)tx y:(float)ty
{
    if (self = [super init]) {
        // Initialization code
		[self set:tx y:ty z:0.0];
    }
    return self;
}

- (id)initWith:(CGPoint) tp
{
	if( self = [super init]) {
		[self set:tp];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark accessors

@synthesize x,y,z;
@synthesize p;

- (void) set:(float)tx y:(float)ty z:(float)tz
{
	fromX = x = tx;
	fromY = y = ty;
	fromZ = z = tz;
}

- (void) set:(float)tx y:(float)ty
{
	[self set:tx y:ty z:0.0];
}

- (void) set:(CGPoint)tp
{
	[self set:tp.x y:tp.y];
}

- (void) moveTo:(float)tx y:(float)ty z:(float)tz
{
	toX = tx;
	toY = ty;
	toZ = tz;
}

- (void) moveTo:(float)tx y:(float)ty
{
	[self moveTo:tx y:ty z:0.0];
}

- (void) moveTo:(CGPoint)tp
{
	[self moveTo:tp.x y:tp.y];
}


#pragma mark -
#pragma mark Animation Work delegate


- (void) BL_AnimationWork_Starting:(NSString *)animationID context:(void *)ctx
{
	x = fromX;
	y = fromY;
	z = fromZ;
}

- (void) BL_AnimationWork_Process:(NSString *)animationID
						  context:(void *)ctx
				 percentThisCycle:(double)ptc
				  overallPosition:(double)op
{
	double itc = 1.0-ptc;
	
	x = (fromX * itc) + (toX * ptc);
	y = (fromY * itc) + (toY * ptc);
	z = (fromZ * itc) + (toZ * ptc);
	p.x = x;
	p.y = y;
//	NSLog( @"Process %f  %f %f %f -> %f %f %f : %f %f %f", ptc,fromX, fromY, fromZ, toX, toY, toZ, x, y, z );
}
		 

- (void) BL_AnimationWork_Completing:(NSString *)animationID context:(void *)ctx
{
	// rail at the endpoint
	x = toX;
	y = toY;
	z = toZ;
	
	// and also let us easily continue movement...
	fromX = x;
	fromY = y;
	fromZ = z;
}

#ifdef NEVER
- (float) BL_AnimationWork_ValueForTime:(float)t forCurve:(int)c
{
}
#endif

@end
