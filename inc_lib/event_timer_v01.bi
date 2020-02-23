'simple event timer

type timer_type
	private:
	dim as double tEnd
	dim as double tStart
	dim as double tSpan
	dim as boolean active = false
	public:
	declare sub start(duration as double)
	declare sub stop_()
	declare function isActive() as boolean
	declare function ended() as boolean
	declare function timeLeft() as double
	'~ declare sub restart()
end type

sub timer_type.start(duration as double)
	tStart = timer()
	tSpan = duration
	tEnd = tStart + tSpan
	active = true
end sub

sub timer_type.stop_()
	active = false
end sub

'does NOT update the timer status
function timer_type.isActive() as boolean
	return active
end function

'check only once in loop! Inactive after ended.
function timer_type.ended() as boolean
	if active = false then return false
	if timer() >= tEnd then
		active = false
		return true
	else
		return false
	end if
end function

function timer_type.timeLeft() as double
	dim as double tLeft = tEnd - timer
	return iif(tLeft < 0, 0, tLeft)
end function

'~ 'continue timer, add same delay to original tStart
'~ sub timer_type.restart() 'extend time?
	'~ tStart = tEnd
	'~ tEnd = tStart + tSpan
	'~ active = 1
'~ end sub
