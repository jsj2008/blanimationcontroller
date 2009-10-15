//
//  AnItem.m
//  TestApp
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import "AnItem.h"


@implementation AnItem


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
w    }
    return self;
}


//- (void)drawRect:(CGRect)rect {
    // Drawing code
//}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Animation Work delegate



- (void) BL_AnimationWork_Starting:(NSString *)animationID context:(void *)ctx
{
	NSLog( @"BL_Work_Starting: %@", animationID);
}

- (void) BL_AnimationWork_Process:(NSString *)animationID
						  context:(void *)ctx
				 percentThisCycle:(double)ptc
				  overallPosition:(double)op
{
	//	NSLog( @"BL_Work_Process: %@ %f", animationID, ptc);
	char buf[100];
	int x;
	buf[0] = '#';
	for( x=1 ; x < (int)(51.0 * ptc) ; x ++ )
	{
		buf[x] = '#';
	}
	buf[x] = '\0';
	NSLog( @"%0.3f %0.3f %s", ptc, op, buf );
	
	[self setAlpha:ptc];
	[self setNeedsDisplay];
}

- (void) BL_AnimationWork_Completing:(NSString *)animationID context:(void *)ctx
{
	NSLog( @"BL_Work_Completing: %@", animationID);
}

- (float) BL_AnimationWork_ValueForTime:(float)t forCurve:(int)c
{
	NSLog( @"BL_Work_ValueFor: %f", t);
	return( t/2 );
}

@end
