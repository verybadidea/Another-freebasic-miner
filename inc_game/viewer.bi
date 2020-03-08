'movement control for map viewer 

type viewer_type
	public:
	dim as flt2d posMap 'position in map / world [pixels]
	private:
	dim as float scrollSpeed 'pix/s
	dim as int2d requestDir
	dim as registered_key rkey
	public:
	declare function init() as integer
	declare sub reset_(posMap as int2d)
	declare sub processKeyInput()
	declare sub update(dt as double) 'update state
	declare sub updatePos(posChange as flt2d) 'update position
end type

function viewer_type.init() as integer
	'assing keys
	rkey.add(FB.SC_LEFT)
	rkey.add(FB.SC_RIGHT)
	rkey.add(FB.SC_UP)
	rkey.add(FB.SC_DOWN)
	return 0
end function

sub viewer_type.reset_(posMap as int2d)
	this.posMap = toFlt2d(posMap)
	scrollSpeed = 500.0
end sub

sub viewer_type.processKeyInput()
	requestDir = int2d(0, 0)
	if rkey.isDown(RKEY_LEFT) then requestDir.x = -1
	if rkey.isDown(RKEY_RIGHT) then requestDir.x = +1
	if rkey.isDown(RKEY_UP) then requestDir.y = -1
	if rkey.isDown(RKEY_DOWN) then requestDir.y = +1
	rkey.updateState() 'very important
end sub

'update position & state
sub viewer_type.update(dt as double)
	posMap.x += (scrollSpeed * dt) * requestDir.x
	posMap.y += (scrollSpeed * dt) * requestDir.y
end sub

