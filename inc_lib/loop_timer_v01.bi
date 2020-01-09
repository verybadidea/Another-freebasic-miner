type loop_timer_type
	private:
	dim as double tStart
	dim as double tNow
	dim as double tPrev
	dim as double dt
	'dim as double dtAvg
	dim as integer pauseFlag = 0
	public:
	declare sub init()
	declare sub update()
	declare sub togglePause()
	declare function isPaused() as integer
	declare function getDt() as double
	declare function getRunTime() as double
end type

sub loop_timer_type.init()
	tStart = timer
	tNow = tStart
	tPrev = tNow
	dt = 0.0
	pauseFlag = 0
	'dtAvg = 0.0
end sub

sub loop_timer_type.update()
	tPrev = tNow
	tNow = timer
	dt = tNow - tPrev
	if pauseFlag = 1 then dt = 0
	'dtAvg = 0.95 * dtAvg + 0.05 * dt
end sub

sub loop_timer_type.togglePause()
	pauseFlag xor= 1
end sub

function loop_timer_type.isPaused() as integer
	return pauseFlag
end function

function loop_timer_type.getDt() as double
	return dt
end function

function loop_timer_type.getRunTime() as double
	return timer - tStart
end function
