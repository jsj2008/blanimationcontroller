//
//  BLAnimationController.m
//
//  Created by Scott Lawrence on 10/14/09. v01
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import "BLAnimationController.h"

#define INTERNALTIMEDURATION (0.05)

@interface BLAnimationController()
- (void) BL_ResetDefaults;
- (float) BL_InternalValueForTime:(float)t forCurve:(UIViewAnimationCurve)c;

- (void) BL_InternalCommence:(id)obj;				// starts the countdown timer stuff
- (void) BL_InternalStartDateArrived:(id)obj;		// the atDate time has arrived
- (void) BL_InternalBeginAnimation:(id)obj;			// actually starts the animation/loop
- (void) BL_InternalTimeTick:(NSTimer*)theTimer;	// the timer fired, handle
- (void) BL_InternalConclude:(id)obj;				// the animation reached the end, which loops or stops
@end


@implementation BLAnimationController

#pragma mark -
#pragma mark init delete stuff

- (id)init
{
	if (self = [super init]) {
		[self BL_ResetDefaults];
	}
	return self;
}


#ifdef NEVER_EXAMPLE
#pragma mark -
#pragma mark User - Runtime methods

- (void) BL_Work_Starting:(NSString *)animationID context:(void *)ctx
{
}

- (void) BL_Work_Process:(NSString *)animationID context:(void *)ctx percentComplete:(double)pct
{
}

- (void) BL_Work_Completing:(NSString *)animationID context:(void *)ctx
{
}

#pragma mark -
#pragma mark User - Curve computations
- (float) BL_Work_ValueForTime:(float)t forCurve:(int)c
{
	return t;
}

- (void) BL_AnimationWillStart:(NSString *)animationID context:(void *)context
{
}

- (void) BL_AnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}
#endif

#pragma mark -
#pragma mark runtime Stuff

// math for curves provided by Pat Stein!  http://nklein.com
// Thanks (pat)+

#define CURVE_P	(0.25)

#define CURVE_MIO	(1/(1-CURVE_P))
#define CURVE_AIO	(CURVE_MIO/(2*CURVE_P))
#define CURVE_BIO	(CURVE_P*CURVE_MIO/2)

#define CURVE_MS	(2/(2-CURVE_P))
#define CURVE_AS	(CURVE_MS/(2*CURVE_P))
#define CURVE_BS	(CURVE_P*CURVE_MS/2)

- (float) BL_InternalValueForTime:(float)t forCurve:(UIViewAnimationCurve)c
{
	
	float ret = t;
	switch( c ){
		case( UIViewAnimationCurveEaseInOut ):
			if( t < CURVE_P ) {
				return CURVE_AIO * t * t;
			} else if( t < 1 - CURVE_P ) {
				return CURVE_MIO * t - CURVE_BIO;
			} else {
				return 1 - CURVE_AIO * (1-t) * (1-t);
			}
			break;
			
		case( UIViewAnimationCurveEaseIn ):
			if( t < CURVE_P ) {
				return CURVE_AS * t * t;
			} else {
				return CURVE_MS * t - CURVE_BS;
			}
			break;
			
		case( UIViewAnimationCurveEaseOut ):
			if( t < (1-CURVE_P) ) {
				return CURVE_MS * t;
			} else {
				return 1 - CURVE_AS * (1-t) * (1-t);
			}
			
			break;
			
			
		case( UIViewAnimationCurveLinear ):
		default:
			ret = t;
	}
	return ret;
}

// commitAnimations() calls InternalCommence
// InternalCommence()
//		sets up StartDateTimer which triggers StartDateArrived
// InternalStartDateArrived
//		sets up the Delay which triggers InternalBeginAnimation
// InternalBeginAnimation
//		if (first time looping)
//			calls [delegate willStartSelector];
//			calls [self Work Starting]
//		sets up the repeating timer
//		sets up the completion timer to call BL_InternalConclude;
// InternalTimeTick
//		gets the value
//		calls [self Work_Process:value] 
// InternalConclude
//		if repeat:
//			inc reps, boundary check
//			toggle flag for ping-pong
//			call BeginAnimation
//		if no repeat, or done:
//		invalidate the timer tick
//		calls [delegate didStopSelector]


- (void) BL_InternalCommence:(id)obj // starts the countdown timer stuff
{
//	if( !BL_pool ) BL_pool = [[NSAutoreleasePool alloc] init];

	BL_CurrentIteration = 0;
	BL_PastEnd = NO;
	// if there's no startDate set, just advance to StartDateArrived
	if( !BL_startDate ) {
		[self BL_InternalStartDateArrived:self];
		return;
	}
	
	// start the StartDate timer
	[self performSelector:@selector( BL_InternalStartDateArrived: )
			   withObject:self
			   afterDelay:[BL_startDate timeIntervalSinceNow]];
}

- (void) BL_InternalStartDateArrived:(id)obj // the atDate time has arrived
{
	[self performSelector:@selector( BL_InternalBeginAnimation: )
			   withObject:self
			   afterDelay:BL_delay ];
}

- (void) BL_InternalBeginAnimation:(id)obj // actually starts the animation/loop
{
	if( BL_CurrentIteration == 0 )
	{
		// first time through loop. send the will start call
		[BL_animationDelegate BL_Animation_WillStart:BL_animationID context:BL_context];
		[BL_animationWorkDelegate BL_AnimationWork_Starting:BL_animationID context:BL_context];
	}
	
	BL_actualStartDate = [NSDate date];
	[BL_actualStartDate retain];
	
	BL_TickTimer = [NSTimer scheduledTimerWithTimeInterval:BL_pollInterval
													target:self
												  selector:@selector( BL_InternalTimeTick: )
												  userInfo:self
												   repeats:YES ];
	[BL_TickTimer fire];
}

- (void) BL_InternalTimeTick:(NSTimer*)theTimer // the timer fired, handle it
{
	BOOL completed = NO;
	
	float value = 0.0;
	
	NSTimeInterval percentTimeSoFar = -1 * [BL_actualStartDate timeIntervalSinceNow] / BL_duration;

	if( percentTimeSoFar < 0.0 ) {
		// negative time?  what does that even mean!??!
		percentTimeSoFar = 0.0;
	}
	
	float CompleteTimeSoFar = percentTimeSoFar + BL_CurrentIteration;

	// check for multiple iterations
	if( CompleteTimeSoFar >= BL_repeatCount )
	{
		[theTimer invalidate];
		completed = YES;
		BL_PastEnd = YES;
	}
	
	// check for single iteration
	if( percentTimeSoFar > 1.0  && !completed) {
		// we've hit the end of the animation
		[theTimer invalidate]; // stop the timer!
		percentTimeSoFar = 1.0;
		completed = YES;
	}
	
	// get the value
	if( BL_externalCurve == BL_AnimationCurveInternal )
	{
		value = [self BL_InternalValueForTime:percentTimeSoFar forCurve:BL_animationCurve];
	} else {
		value = [BL_animationWorkDelegate BL_AnimationWork_ValueForTime:percentTimeSoFar forCurve:BL_externalCurve];
	}
	
	// reverse if autoreverse
	if( BL_autoReverse && (BL_CurrentIteration & 0x01)) {
		value = 1.0 - value;
	}
	
	
	// send it to the caller
	[BL_animationWorkDelegate BL_AnimationWork_Process:BL_animationID
											   context:BL_context
									  percentThisCycle:value 
									   overallPosition:(float)BL_CurrentIteration + percentTimeSoFar];
	if( completed )
	{
		[self BL_InternalConclude:self];
	}
}

- (void) BL_InternalConclude:(id)obj // the animation reached the end, which loops or stops
{
	// -animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
	
	// stop the timer
	[BL_TickTimer invalidate];
	BL_TickTimer = nil;
	
	// deal with repetitions here in the future
	if( BL_CurrentIteration < BL_repeatCount && !BL_PastEnd )
	{
		// we're not done yet!
		BL_CurrentIteration++;
		[self BL_InternalBeginAnimation:self];
		
	} else {
		[BL_animationWorkDelegate BL_AnimationWork_Completing:BL_animationID context:BL_context];
		[BL_animationDelegate BL_Animation_DidStop:BL_animationID finished:0 context:BL_context];
	}
	
//	if( BL_pool ) [BL_pool release];
}


////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The UIView Animation style interface

- (void) BL_ResetDefaults
{
	BL_animationDelegate = nil;
	BL_animationWorkDelegate = nil;
	BL_pollInterval = 0.1;
	BL_duration = 0.2;
	BL_delay = 0.0;
	BL_startDate = nil;
	BL_animationCurve = UIViewAnimationCurveEaseInOut;
	BL_externalCurve = 0;
	BL_repeatCount = 0.0;
	BL_CurrentIteration = 0;
	BL_autoReverse = NO;
	BL_beginsFromCurrentState = NO;
	BL_animationsEnabled =YES;
}


- (void)BL_beginAnimations:(NSString *)animationID context:(void *)context
{
	NSLog( @"Begin" );
	if( !BL_animationsEnabled ) return;
	
	[self BL_ResetDefaults];
	BL_context = context;
	BL_animationID = animationID;
	BL_settingUp = YES;
}

- (void)BL_commitAnimations
{
	if( !BL_animationsEnabled ) return;
	BL_settingUp = NO;
	
	[self performSelectorOnMainThread:@selector( BL_InternalCommence: ) withObject:self waitUntilDone:NO];

}


- (void)BL_setAnimationDelegate:(id<BLAnimationControllerDelegate>)delegate
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_animationDelegate = delegate;
}


- (void)BL_setAnimationWorkDelegate:(id<BLAnimationWorkDelegate>)delegate
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_animationWorkDelegate = delegate;
}

#ifdef NEVER
- (void)BL_setAnimationWillStartSelector:(SEL)selector
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;

	//-animationWillStart:(NSString *)animationID context:(void *)context
	BL_animationWillStartSelector = selector;
}

- (void)BL_setAnimationDidStopSelector:(SEL)selector
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	// -animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
	BL_animationDidStopSelector = selector;
}
#endif

- (void)BL_setAnimationDuration:(NSTimeInterval)duration
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_duration = duration;
}

- (void)BL_setAnimationDelay:(NSTimeInterval)delay
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_delay = delay;
}

- (void)BL_setAnimationStartDate:(NSDate *)startDate
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	// default = now ([NSDate date])
	BL_startDate = startDate;
}

- (void)BL_setAnimationCurve:(UIViewAnimationCurve)curve
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_animationCurve = curve;
}

- (void)BL_setAnimationRepeatCount:(float)repeatCount
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_repeatCount = repeatCount;
}

- (void)BL_setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	// used if repeat count is nonzero
	BL_autoReverse = repeatAutoreverses;
}

- (void)BL_setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	BL_beginsFromCurrentState = fromCurrentState;
}

- (void)BL_setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache
{
	if( !BL_animationsEnabled ) return;
	if( !BL_settingUp ) return;
	
	// current limitation - only one per begin/commit block
	// -- IGNORED FOR US
}


- (void)BL_setAnimationsEnabled:(BOOL)enabled
{
	BL_animationsEnabled = enabled;
}

- (BOOL)BL_areAnimationsEnabled
{
	return BL_animationsEnabled;
}


#pragma mark -
#pragma mark New stuff
- (void)BL_setCustomAnimationCurve:(int)curveId
{
	BL_externalCurve = curveId;
}

- (void)BL_setPollInterval:(float)interval
{
	BL_pollInterval = interval;
}

@end
