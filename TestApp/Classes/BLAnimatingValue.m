//
//  BLAnimatingValue.m
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import "BLAnimatingValue.h"


@implementation BLAnimatingValue


- (id)init
{
	if (self = [super init]) {
        // Initialization code
		[self set:0.0];
    }
    return self;
}

- (id)initWithValue:(float)tv
{
    if (self = [super init]) {
        // Initialization code
		[self set:tv];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark accessors

@synthesize v;

- (void) set:(float)tv
{
	fromV = v = tv;
}

- (void) animateTo:(float)tv
{
	toV = tv;
}


#pragma mark -
#pragma mark Animation Work delegate


- (void) BL_AnimationWork_Starting:(NSString *)animationID context:(void *)ctx
{
	v = fromV;
}

- (void) BL_AnimationWork_Process:(NSString *)animationID
						  context:(void *)ctx
				 percentThisCycle:(double)ptc
				  overallPosition:(double)op
{
	double itc = 1.0-ptc;
	
	v = (fromV * itc) + (toV * ptc);
	NSLog( @"Process %f  %f -> %f : %f", ptc, fromV, toV, v );

}
		 

- (void) BL_AnimationWork_Completing:(NSString *)animationID context:(void *)ctx
{
	// rail at the endpoint
	v = toV;
	
	// and also let us easily continue movement...
	fromV = v;
}

#ifdef NEVER
- (float) BL_AnimationWork_ValueForTime:(float)t forCurve:(int)c
{
}
#endif

@end
