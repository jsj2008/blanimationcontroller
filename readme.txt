
	BLAnimationController v1.0
	Scott Lawrence
	yorgle@gmail.com


Overview:

After finding out that the UIView Animaitons are not extensible at
all, that you're limited to the dozen or so attributes that Apple
decreed were "animatable", I decided to take matters into my own
hands.

I've created BLAnimationController.

	http://code.google.com/p/blanimationcontroller/

It provides you a very similar interface to the UIView Animations,
with very similar (if not identical) interface.

----------------------------------------

To make your "thing" animatable, you simply need to implement the
BLAnimationWorkDelegate protocol.

On all of these messages, the animationID and ctx are the same vars
passed in to the BL_beginAnimations() call.  They are not changed
at all internally.  It is expected that these are used to help
associate all of the calls together.


- (void) BL_AnimationWork_Starting:(NSString *)animationID
                           context:(void *)ctx;

	Called when the animation is about to start.  This is called
	after the date/time delay, and after the regular delay.  It
	is called exactly when animation is expected to start.


- (void) BL_AnimationWork_Process:(NSString *)animationID
                          context:(void *)ctx 
                 percentThisCycle:(double)ptc
                  overallPosition:(double)op;

	As the animation progresses, this method is called to your
	object periodically, as per the BL_setPollInterval()
	accessor's setting, or the default setting of 0.05 seconds.

	If the caller sets a RepeatCount, then we might go through
	the cycle more than once.  The "percentThisCycle" value
	will go through [0.0, 1.0].  It can be assumed that your
	object will get the start and ending values, but due to
	float rounding errors, this may not be the case.

	the ptc value is already filtered through the animation curve.
	With a linear curve, and 10 steps, your object will receive
	something like:

		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0

	With an Ease-In/Ease-Out curve, those same timeslices may get
	something like:

		0.0 0.05 0.1 0.2 0.4 0.5 0.6 0.7 0.9 0.95 1.0

	The number of timeslices does not change, the percent values
	will change.

	If the user selects a RepeatCount of 3.0, the ptc value will
	get a sequence similar to the following:

		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0

	If the user also selects Autoreverses, the following sequence
	might occur:

		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
		1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.0
		0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0


- (void) BL_AnimationWork_Completing:(NSString *)animationID
                             context:(void *)ctx;

	Once the sequence completes, the Completing message will be 
	called.  Do any finishing-up code in here.


- (float) BL_AnimationWork_ValueForTime:(float)t
                               forCurve:(int)c;

	This is an optional message that your object can implement.
	It is for designating custom curves.  (c)urve 0 is for
	internal use only.  All these integers are yours except 0.
	Attempt no landings there.  Use them together. Use them in
	peace.

	This will get called at each timeslice, with the actual
	linear timestep value.  Your implementation of this will
	return a float associated with the input value (f).

	A linear function will simply:   return( t )  and also will
	be silly to do.


----------------------------------------

For using this, the interface is the same as UIView Animation
controls.  Here's my understanding of these methods, and therefore,
the explanation of what they do in this implementation

- (void)BL_beginAnimations:(NSString *)animationID context:(void *)context

	Clears all internal values, resets everything to the defaults.
	It also stores aside animationID and context, to send them
	to the object d'animation.

- (void)BL_commitAnimations

	Triggers the timer start, and therefore, the animation as
	well.

- (void)BL_setAnimationDelegate:(id<BLAnimationControllerDelegate>)delegate

	(New/Different than UIView) This sets the Controller Delegate.
	This is the caller that instantiates the animation, and will
	receive the following messages:

	- (void) BL_Animation_WillStart:(NSString *)animationID
                                context:(void *)context;

		Called when the animation is about to start

	- (void) BL_Animation_DidStop:(NSString *)animationID
                             finished:(NSNumber *)finished
                              context:(void *)context;

		Called when the animation finishes.

- (void)BL_setAnimationWorkDelegate:(id<BLAnimationWorkDelegate>)delegate

	(New/Different than UIView) This sets the worker delegate
	as defined above.  The worker is the object d'animation.
	Default is 'self'.  This makes it possible for your object to
	handle its own animations.

- (void)BL_setAnimationDuration:(NSTimeInterval)duration

	Amount of time in seconds that the entire animation will
	take to complete.
	Default is 0.2 seconds

- (void)BL_setAnimationDelay:(NSTimeInterval)delay

	Amount of time in seconds to wait before starting the
	animation.
	Default is 0.0 seconds

- (void)BL_setAnimationStartDate:(NSDate *)startDate

	When to start the animation.  The timer cycle waits this
	time, then waits the delay, then runs the animation.
	Default is NOW.

- (void)BL_setAnimationCurve:(UIViewAnimationCurve)curve

	Which internal animation curve to use.
	Options are:
		UIViewAnimationCurveEaseIn
		UIViewAnimationCurveEaseOut
		UIViewAnimationCurveEaseInOut	(default)
		UIViewAnimationCurveEaseLinear

- (void)BL_setAnimationRepeatCount:(float)repeatCount

	Number of times that the animations should repeat.
	0.0 is a special case that no repeats should occur.
	1.0 means that it will perform once cycle.
	2.0 means it will perform two cycles.
	Default is 0.0

- (void)BL_setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses

	Should the animation autoreverse (ping-pong/cylon) or should
	it cycle through forward only?
	Default is NO


- (void)BL_setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState

	Not implemented.

- (void)BL_setAnimationTransition:(UIViewAnimationTransition)transition
                          forView:(UIView *)view
                            cache:(BOOL)cache

	Not implemented.


- (void)BL_setAnimationsEnabled:(BOOL)enabled

	Enables/disables the above calls.  If set to NO, the above
	calls have no function, and return immediately.
	Default is YES

- (BOOL)BL_areAnimationsEnabled

	Returns the current enabled state.

--------------------

- (void)BL_setCustomAnimationCurve:(int)curveId

	Lets the caller select one of the object-extended animation
	curves.  Curve 0 is reserved to signify that the internal
	curve selection should be used instead of these.

		BL_AnimationCurveInternal	(0)

	Any other integer is valid, assuming there is a significance
	for that number.  There will be a chosen one.  It will be
	significant.

- (void)BL_setPollInterval:(float)interval

	Sets the internal poll interval in seconds. 
	Default is 0.1 seconds (1/10th second per step)


----------------------------------------


Limitations:

- only one "animation" per instance right now.  If you want to
	do two different, unrelated animations, you need to have 
	two BLAnimationControllers

- no real nesting, since you only have one animation per instance
	- the design is a little different than UIView's

- i just finished it last night (after starting it yesterday) so
	it might not function 100% just yet, but it seems pretty 
	solid to me so far.

- I haven't written formal docs for it yet.  I will be doing this 
	over the next couple days.


I prefixed all of the variables and message names with BL_ with the
thought that it could be inherited by a UIView subclass, so that
the names wouldn't clash, but I'm not sure that was the best thing
to do; I'm starting to think that using it like the example included
shows, as external to the UIView, might be the better way to go.
Although this way you get the flexibility to do either, i suppose.
