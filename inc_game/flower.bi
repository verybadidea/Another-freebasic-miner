type flower_type
	private:
	'move this flower stuff elsewhere?
	dim as timer_type spawnTmr
	dim as double spawnTime = 5.0
	'move this flower stuff elsewhere?
	dim as timer_type animTmr
	dim as integer animSeq 'index for flowerAnimFrame()
	dim as double animDuration = 0.2
	dim as short animFrame(0 to 3) = {0, 1, 2, 1}
	dim as integer firstImgId(0 to 4) = {_
		fg_landscape_flower_1a, fg_landscape_flower_2a, fg_landscape_flower_3a, _
		fg_landscape_flower_4a, fg_landscape_gras_1}
	public:
	declare constructor()
	declare function randomImgId() as short
	declare function imgIdOffset() as short
	declare sub resetSpawnTimer()
	declare function update() as boolean
end type

constructor flower_type()
	animSeq = 0
	animTmr.start(animDuration)
	spawnTmr.start(spawnTime)
end constructor

'get as random flower, only first imgage id of animation range
function flower_type.randomImgId() as short
	dim as integer iFlower = rndRange(0, ubound(firstImgId))
	return firstImgId(iFlower)
end function

'get correct flower image id shift based on animation cycle
function flower_type.imgIdOffset() as short
	return animFrame(animSeq)
end function

sub flower_type.resetSpawnTimer()
	spawnTmr.start(spawnTime)
end sub

'update timers, returns true on spawn timer ended
function flower_type.update() as boolean
	'flower animation
	if animTmr.ended() then
		animTmr.start(animDuration)
		animSeq += 1
		if animSeq > ubound(animFrame) then animSeq = animFrame(0)
	end if
	'flower spawing
	if spawnTmr.ended() then
		spawnTmr.start(spawnTime)
		return true
	end if
	return false
end function
