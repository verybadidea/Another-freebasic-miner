#include once "fbgfx.bi"

type registered_key
	private:
		dim as long scanCode(any)
		dim as boolean oldState(any)
		dim as boolean newState(any)
	public:
		declare constructor()
		declare destructor()
		declare function add(scanCode as long) as long
		declare sub show()
		declare function isDown(myKey as integer) as boolean
		declare function isPressed(myKey as integer) as boolean
		declare function isReleased(myKey as integer) as boolean
		declare sub updateState()
end type

constructor registered_key()
	add(0) 'reserve position 0 with 0 (no key)
end constructor

destructor registered_key()
	erase scanCode, oldState, newState
end destructor

function registered_key.add(scanCode as long) as long
	dim as integer ub = ubound(this.scanCode)
	redim preserve this.scanCode(ub + 1)
	redim preserve this.oldState(ub + 1)
	redim preserve this.newState(ub + 1)
	this.scanCode(ub + 1) = scanCode
	this.oldState(ub + 1) = false
	this.newState(ub + 1) = false
	return ub + 1
end function

'for debugging
sub registered_key.show()
	for i as integer = 0 to ubound(scanCode)
		print i, scanCode(i), oldState(i), newState(i)
	next
end sub

function registered_key.isDown(myKey as integer) as boolean
	if myKey < 1 orelse myKey > ubound(scanCode) then return false
	return multikey(scanCode(myKey))
end function

function registered_key.isPressed(myKey as integer) as boolean
	if myKey < 1 orelse myKey > ubound(scanCode) then return false
	newState(myKey) = multikey(scanCode(myKey))
	return (newState(myKey) = true) andalso (oldState(myKey) = false) 
end function

function registered_key.isReleased(myKey as integer) as boolean
	if myKey < 1 orelse myKey > ubound(scanCode) then return false
	newState(myKey) = multikey(scanCode(myKey))
	return (newState(myKey) = false) andalso (oldState(myKey) = true) 
end function

sub registered_key.updateState()
	for i as integer = 1 to ubound(scanCode)
		oldState(i) = newState(i)
	next
end sub

'-------------------------------------------------------------------------------

'~ dim as integer jumpKey, duckKey, quitKey, actionKey, noInitKey
'~ dim as registered_key rkey

'~ jumpKey = rkey.add(FB.SC_SPACE)
'~ duckKey = rkey.add(FB.SC_DOWN)
'~ quitKey = rkey.add(FB.SC_ESCAPE)
'~ actionKey = rkey.add(FB.SC_ENTER)
'~ noInitKey = 0

'~ rkey.show()

'~ do
	'~ if rkey.isDown(duckKey) then print "duckKey is down" 

	'~ if rkey.isPressed(jumpKey) then print "jumpKey is pressed" 
	'~ if rkey.isReleased(jumpKey) then print "jumpKey is released"

	'~ if rkey.isPressed(actionKey) then print "actionKey is pressed" 
	'~ if rkey.isReleased(actionKey) then print "actionKey is released"

	'~ if rkey.isPressed(noInitKey) then print "noInitKey is pressed" 
	'~ if rkey.isReleased(noInitKey) then print "noInitKey is released"

	'~ rkey.updateState()
	
	'~ sleep 1
'~ loop until rkey.isDown(quitKey)
