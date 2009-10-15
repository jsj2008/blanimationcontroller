//
//  BLAnimationController.h
//
//  Created by Scott Lawrence on 10/14/09.
//  Copyright 2009 UmlautLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
// this is the delegte that your calling object can implement
// these get called when the animation starts and ends

@protocol BLAnimationControllerDelegate<NSObject>
- (void) BL_Animation_WillStart:(NSString *)animationID context:(void *)context;
- (void) BL_Animation_DidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end


////////////////////////////////////////////////////////////////////////////////
// this is the delegate that your animatable object should implement
// it handles the things you would expect. start/process/complete
// "process" is called incrementally, while the animation progresses. 
//  You are guaranteed that "process" is called at 0% and 100% of animation progression.
//  intermediate calls/interval are determined by the Interval defined in the code.

@protocol BLAnimationWorkDelegate<NSObject>
// they will be called in a background thread, so be aware of that.
- (void) BL_AnimationWork_Starting:(NSString *)animationID context:(void *)ctx;
- (void) BL_AnimationWork_Process:(NSString *)animationID context:(void *)ctx percentThisCycle:(double)ptc overallPosition:(double)op;
- (void) BL_AnimationWork_Completing:(NSString *)animationID context:(void *)ctx;
@optional
- (float) BL_AnimationWork_ValueForTime:(float)t forCurve:(int)c;
@end


////////////////////////////////////////////////////////////////////////////////
// implementation of the class itself...

@interface BLAnimationController : NSObject //<BLAnimationsDelegate>
{
	bool BL_AnimationsEnabled:YES;
	void * BL_context;
	NSString * BL_animationID;
	
	NSTimer * BL_TickTimer;
	NSTimer * BL_CompletionTimer;
	bool BL_settingUp;

	id <BLAnimationControllerDelegate> BL_animationDelegate;
	id <BLAnimationWorkDelegate> BL_animationWorkDelegate;
	
	NSTimeInterval BL_duration;
	NSTimeInterval BL_delay;
	float BL_pollInterval;
	NSDate * BL_startDate;
	UIViewAnimationCurve BL_animationCurve;
	int BL_externalCurve;
	float BL_repeatCount;
	int BL_CurrentIteration;
	BOOL BL_autoReverse;
	BOOL BL_beginsFromCurrentState;
	BOOL BL_animationsEnabled;
	BOOL BL_PastEnd;
	
	NSDate * BL_actualStartDate;
	
	NSAutoreleasePool * BL_pool;
}




// the interface for the animations.  don't breathe these.
// based on UIView.h
- (void)BL_beginAnimations:(NSString *)animationID context:(void *)context;  // additional context info passed to will start/did stop selectors. 
- (void)BL_commitAnimations;                                                 // starts up any animations when the top level animation is commited

- (void)BL_setAnimationDelegate:(id<BLAnimationControllerDelegate>)delegate;			// default = nil
- (void)BL_setAnimationWorkDelegate:(id<BLAnimationWorkDelegate>)delegate;			// default = nil

- (void)BL_setAnimationDuration:(NSTimeInterval)duration;              // default = 0.2
- (void)BL_setAnimationDelay:(NSTimeInterval)delay;                    // default = 0.0
- (void)BL_setAnimationStartDate:(NSDate *)startDate;                  // default = now ([NSDate date])

- (void)BL_setAnimationCurve:(UIViewAnimationCurve)curve;              // default = UIViewAnimationCurveEaseInOut

- (void)BL_setAnimationRepeatCount:(float)repeatCount;                 // default = 0.0.  May be fractional
- (void)BL_setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;    // default = NO. used if repeat count is non-zero

// not implemented yet...
- (void)BL_setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState;
- (void)BL_setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache; 

// enabled accessor.
- (void)BL_setAnimationsEnabled:(BOOL)enabled;                         // ignore any attribute changes while set.
- (BOOL)BL_areAnimationsEnabled;

// and some new things
- (void)BL_setCustomAnimationCurve:(int)curveId;					// curveID passed in to the WORK callback
#define BL_AnimationCurveInternal	(0)		/* the default, additionals should be >0 */
- (void)BL_setPollInterval:(float)interval;		// number of ticks per second that the work-process message gets called
@end
