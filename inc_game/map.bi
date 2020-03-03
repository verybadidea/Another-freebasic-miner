const as short IS_BAD = &h0000
const as short IS_EMPTY = &h0001
const as short IS_FIXED = &h0002
const as short IS_SOLID = &h0004
const as short IS_CLIMB = &h0008
const as short IS_FLOWER = &h0010
const as short IS_RESOURCE = &h0020
const as short IS_INVALID = &h8000
'const as short IS_SUPPORT = &h0008
'const as short IS_INVALID = &h8000
'const as short ALLOW_LADDER

type map_type
	public:
	dim as int2d size
	dim as short health(any, any)
	private:
	dim as short bgId(any, any)
	dim as short fgId(any, any)
	dim as short bgProp(any, any)
	'move this flower stuff elsewehere?
	dim as timer_type flowerSpawnTmr
	dim as double flowerSpawnTime = 5.0
	'move this flower stuff elsewehere?
	dim as timer_type flowerAnimTmr
	dim as integer flowerAnimSeq 'index for flowerAnimFrame()
	dim as double flowerAnimDuration = 0.2
	dim as integer flowerAnimFrame(0 to 3) = {0, 1, 2, 1}
	public:
	declare function alloc(size as int2d) as integer
	declare sub setRandom()
	declare sub setNormal()
	declare function validIndex(x as integer, y as integer) as boolean
	declare function validPos(pos_ as int2d) as boolean
	declare function getBgProp(gridPos as int2d) as short
	declare sub setTile(pos_ as int2d, fgId as short, bgId as short, flags as short = 0, health_ as short = -1)
	declare sub draw_(scrMapDist as flt2d)
	declare sub update() 'update flowers
	declare sub killFlower(pos_ as int2d)
	declare destructor()
end type

function map_type.alloc(size as int2d) as integer
	this.size = size
	redim bgId(size.x, size.y)
	redim fgId(size.x, size.y)
	redim bgProp(size.x, size.y)
	redim health(size.x, size.y)
	flowerAnimSeq = 0
	flowerAnimTmr.start(flowerAnimDuration)
	flowerSpawnTmr.start(flowerSpawnTime)
	return 0
end function

sub map_type.setRandom()
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			bgId(xi, yi) = rndRange(bg_block_2a, bg_wall_5)
			fgId(xi, yi) = rndRange(fg_artefact_bone_1, fg_tile_deco_2)
			bgProp(size.x, size.y) = IS_EMPTY
			health(size.x, size.y) = 1
		next
	next
end sub

sub map_type.setNormal()
	'setup a simple random map
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			if (xi = 0) or (xi = size.x - 1) then
				'set left/right hard borders
				setTile(int2d(xi, yi), 0, bg_border, IS_SOLID or IS_FIXED)
			else
				if yi = 0 then
					'no bg image on top row
					setTile(int2d(xi, yi), 0, 0, IS_EMPTY)
				elseif yi = size.y - 1 then
					'set left/right bottom border
					setTile(int2d(xi, yi), 0, bg_border, IS_SOLID or IS_FIXED)
				else 
					if yi = 1 then
						'second row grass covered dirt block
						setTile(int2d(xi, yi), 0, rndRange(bg_surface_1, bg_surface_3), IS_SOLID, 5)
					else
						'normal dirt blocks
						setTile(int2d(xi, yi), 0, rndRange(bg_earth_0, bg_earth_3), IS_SOLID, 5)
					end if
					'~ if rnd < 0.2 then
						'~ 'random gaps
						'~ setTile(int2d(xi, yi), 0, bg_shadow, IS_EMPTY, 0)
					'~ end if
					'~ if rnd < 0.2 then
					'~ 'random ladder
						'~ setTile(int2d(xi, yi), fg_construction_ladder, bg_shadow, IS_CLIMB, 1)
					'~ end if
				end if
			end if
		next
	next
	'place plants & grass at top row
	dim as integer yi = 0
	for xi as integer = 0 to size.x - 1
		'check block below
		if (getBgProp(int2d(xi, yi + 1)) and IS_SOLID) then
			if (getBgProp(int2d(xi, yi)) and IS_EMPTY) then
				if rnd > 0.5 then continue for
				dim as integer imgId = flowerArray(rndChoice(flowerArray()))
				setTile(int2d(xi, yi), imgId, 0, IS_FLOWER, 1)
			end if
		end if
	next
	'place resources
	'~ for yi as integer = 2 to size.y - 1
		'~ for xi as integer = 0 to size.x - 1
			'~ if getBgProp(int2d(xi, yi)) = IS_SOLID then
				'~ if rnd > 0.3 then continue for
				'~ dim as integer imgId = resourceArray(rndChoice(resourceArray()))
				'~ setTile(int2d(xi, yi), imgId, -1, IS_SOLID or IS_RESOURCE)
			'~ end if
		'~ next
	'~ next
	'create resource / minera veins
	dim as move_def_type move
	dim as int2d blockPos
	dim as integer badMove, iMove, imgId
	dim as integer numVeins = 300, maxVeinLen
	for iVein as integer = 0 to numVeins - 1
		'random start position (within borders)
		blockPos.x = rndRange(1, size.x - 2)
		blockPos.y = rndRange(2, size.y - 2)
		'disallow one direction
		badMove = rndRange(0, 3)
		'random resource (for now, make heigt dependent)
		imgId = resourceArray(rndChoice(resourceArray()))
		maxVeinLen = rndRange(10, 20)
		for iBlock as integer = 0 to maxVeinLen - 1
			'if validPos(blockPos) then
			if inRange(blockPos.x, 1, size.x - 2) andalso inRange(blockPos.y, 2, size.y - 2) then
				'set the resource on map
				if getBgProp(blockPos) = IS_SOLID then
					setTile(blockPos, imgId, -1, IS_SOLID or IS_RESOURCE)
				end if
			else
				continue for 'next vein
			end if
			'make a step in random (allowed) direction
			do
				iMove = rndRange(0, 3)
			loop while iMove = badMove
			blockPos += move.dir_(iMove)
		next
	next
end sub

function map_type.validIndex(x as integer, y as integer) as boolean
	if x < 0 or x >= size.x then return false
	if y < 0 or y >= size.y then return false
	return true
end function

function map_type.validPos(pos_ as int2d) as boolean
	if pos_.x < 0 or pos_.x >= size.x then return false
	if pos_.y < 0 or pos_.y >= size.y then return false
	return true
end function

'prevent out-of-bounds, good?
function map_type.getBgProp(gridPos as int2d) as short
	if validPos(gridPos) then
		return bgProp(gridPos.x, gridPos.y)
	else
		'logger.add("map_type.getBgProp(): out-of-bounds")
		return IS_INVALID 'good return value?
	end if
end function

'Id < 0: do not set/change
sub map_type.setTile(pos_ as int2d, fgId as short, bgId as short, flags as short = 0, health_ as short = -1)
	if validPos(pos_) then
		if fgId >= 0 then this.fgId(pos_.x, pos_.y) = fgId
		if bgId >= 0 then this.bgId(pos_.x, pos_.y) = bgId
		if flags <> 0 then bgProp(pos_.x, pos_.y) = flags
		if health_ <> -1 then health(pos_.x, pos_.y) = health_
	end if
end sub

'Id = 0: do not draw
sub map_type.draw_(scrMapDist as flt2d)
	'get visible area (Tl = Top-Left, Br = Botton-Right)
	dim as int2d gridPosLt = getGridPos(scrMapDist)
	dim as int2d gridPosBr = getGridPos(scrMapDist + toFlt2d(scr.edge))
	dim as integer imgId
	for yi as integer = gridPosLt.y to gridPosBr.y
		for xi as integer = gridPosLt.x to gridPosBr.x
			dim as int2d tileScrPos = getScrPos(int2d(xi, yi), scrMapDist)
			if validIndex(xi, yi) then
				'draw background tiles
				imgId = bgId(xi, yi)
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_PSET)
				end if
				'draw foreground tiles, flowers / grass animated
				imgId = fgId(xi, yi) + iif((bgProp(xi, yi) and IS_FLOWER), flowerAnimFrame(flowerAnimSeq), 0)
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
				end if
				'draw cracks on damaged blocks
				if (bgProp(xi, yi) and IS_SOLID) then
					dim as integer damage = 4 - health(xi, yi)
					if damage >= 0 and damage < 4 then 'range: 0...3
						imgId = fg_tile_damage_1 + damage
						imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
					end if
				end if
				'display tile properties bits
				'f1.printTextAk(tileScrPos.x, tileScrPos.y, hex(bgProp(xi, yi)), FHA_CENTER)
				'f1.printTextAk(tileScrPos.x, tileScrPos.y, str(health(xi, yi)), FHA_CENTER)
			end if
		next
	next
end sub

'move to different class?
sub map_type.update() 'update flowers
	'flower animation
	if flowerAnimTmr.ended() then
		flowerAnimTmr.start(flowerAnimDuration)
		flowerAnimSeq += 1
		if flowerAnimSeq > ubound(flowerAnimFrame) then flowerAnimSeq = flowerAnimFrame(0)
	end if
	'flower spawing
	if flowerSpawnTmr.ended() then
		flowerSpawnTmr.start(flowerSpawnTime)
		dim as integer xi, yi = 0 'top row
		for i as integer = 0 to 4 'try 5 positions
			xi = rndRange(0, size.x - 1)
			if (getBgProp(int2d(xi, yi + 1)) and IS_SOLID) then
				if (getBgProp(int2d(xi, yi)) and IS_EMPTY) then
					dim as integer imgId = flowerArray(rndChoice(flowerArray()))
					setTile(int2d(xi, yi), imgId, 0, IS_FLOWER, 1)
					exit for
				end if
			end if
		next
	end if
end sub

'realy?
sub map_type.killFlower(pos_ as int2d)
	if validPos(pos_) then
		if (getBgProp(pos_) and IS_FLOWER) then
			setTile(pos_, 0, -1, IS_EMPTY) 'bgProp)
			'reset to prevent accidental direct re-spawn
			flowerSpawnTmr.start(flowerSpawnTime)
		end if
	end if
end sub

destructor map_type()
	erase bgId
	erase fgId
	erase bgProp
end destructor

