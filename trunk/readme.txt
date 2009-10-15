
Hi.  Thanks for the interest in BLAnimationController.

Apologies, as there is no real documentation for it just yet.   I promise that
by Oct 18, there will be full docs here instead of this excuse.txt


-Scott Lawrence (BleuLlama) yorgle@gmail.com


The announcement made to the iphonesdk mailing list follows:
--------------------------------------------------------------------------------

So, after finding out that the UIView Animaitons are not extensible
at all, that you're limited to the dozen or so attributes that Apple
decreed were "animatable", I decided to take matters into my own
hands.

I've created BLAnimationController.

http://code.google.com/p/blanimationcontroller/

It provides you a very similar interface to the UIView Animations,
with very similar (if not identical) interface.

To make your "thing" animatable, you simply need to implement the
"Work" delegates.  Your object will get messages for Start, Complete,
and Progress.  The progress message is sent with "current value"
and "percent complete", both as floats.

Rather than setting explicit willStart and didComplete delegate
methods, there is a general delegate that your class needs to
implement to get these methods.


It supports:

- Curves: linear, easein, easeout, easeinout

- Start Date, delay, duration, repeats, autoreverse


It does not support:

- transition animations

- begins from current state (not sure how to implement this one)  
	I think it's a hybrid by current design of YES and NO. heh


It adds:

- User definable curves for more complex operations

- Adjustable polling interval (how many ticks per second your
	"update" work message gets called.


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


Oh, and I'm flexible with the license on it.  if MIT doesn't suit
your needs, I can change it.

-s

-- 
Scott Lawrence (BleuLlama)
yorgle@gmail.com

