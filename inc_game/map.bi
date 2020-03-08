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

const NUM_VEINS = 500, MIN_VEIN_LEN = 10, MAX_VEIN_LEN = 20
const NUM_CAVES = 100, MIN_CAVE_LEN = 10, MAX_CAVE_LEN = 40

type map_tile
	dim as short health, bgId, fgId, bgProp
	declare sub set(fgId as short, bgId as short, bgProp as short = 0, health as short = -1)
end type

sub map_tile.set(fgId as short, bgId as short, bgProp as short = 0, health as short = -1)
	if fgId >= 0 then this.fgId = fgId
	if bgId >= 0 then this.bgId = bgId
	if bgProp <> 0 then this.bgProp = bgProp 'flags
	if health <> -1 then this.health = health
end sub

'-------------------------------------------------------------------------------

type map_type
	private:
	dim as map_tile mTile(any, any)
	dim as int2d size
	dim as resource_type ptr pRes
	'move this flower stuff elsewhere?
	dim as timer_type flowerSpawnTmr
	dim as double flowerSpawnTime = 5.0
	'move this flower stuff elsewhere?
	dim as timer_type flowerAnimTmr
	dim as integer flowerAnimSeq 'index for flowerAnimFrame()
	dim as double flowerAnimDuration = 0.2
	dim as integer flowerAnimFrame(0 to 3) = {0, 1, 2, 1}
	dim as integer flowerArray(0 to 4) = {fg_landscape_flower_1a, fg_landscape_flower_2a, _
		fg_landscape_flower_3a, fg_landscape_flower_4a, fg_landscape_gras_1}
	public:
	declare constructor(byref resource as resource_type)
	declare function alloc(size as int2d) as integer
	declare sub setRandom()
	declare sub setNormal()
	declare function validPos(pos_ as int2d) as boolean
	declare function tile(pos_ as int2d) byref as map_tile
	declare sub draw_(scrMapDist as flt2d)
	declare sub update() 'update flowers
	declare sub killFlower(pos_ as int2d)
	declare destructor()
end type

constructor map_type(byref resource as resource_type)
	pRes = @resource
end constructor

function map_type.alloc(size as int2d) as integer
	this.size = size
	redim mTile(size.x, size.y)
	flowerAnimSeq = 0
	flowerAnimTmr.start(flowerAnimDuration)
	flowerSpawnTmr.start(flowerSpawnTime)
	return 0
end function

sub map_type.setRandom()
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			with mTile(xi, yi)
				.bgId = rndRange(bg_block_2a, bg_wall_5)
				.fgId = rndRange(fg_artefact_bone_1, fg_tile_deco_2)
				.bgProp = IS_EMPTY
				.health = 1
			end with
		next
	next
end sub

sub map_type.setNormal()
	'setup a simple random map
	dim as int2d gridPos
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			gridPos = int2d(xi, yi)
			if (xi = 0) or (xi = size.x - 1) then
				'set left/right hard borders
				tile(gridPos).set(0, bg_border, IS_SOLID or IS_FIXED)
			else
				if yi = 0 then
					'no bg image on top row
					tile(gridPos).set(0, 0, IS_EMPTY)
				elseif yi = size.y - 1 then
					'set left/right bottom border
					tile(gridPos).set(0, bg_border, IS_SOLID or IS_FIXED)
				else 
					if yi = 1 then
						'second row grass covered dirt block
						tile(gridPos).set(0, rndRange(bg_surface_1, bg_surface_3), IS_SOLID, 5)
					else
						'normal dirt blocks
						tile(gridPos).set(0, rndRange(bg_earth_0, bg_earth_3), IS_SOLID, 5)
					end if
					if rnd < 0.2 then
						'random gaps
						tile(gridPos).set(0, bg_shadow, IS_EMPTY, 0)
					end if
					if rnd < 0.2 then
					'random ladder
						tile(gridPos).set(fg_construction_ladder, bg_shadow, IS_CLIMB, 1)
					end if
				end if
			end if
		next
	next
	'place plants & grass at top row
	dim as integer yi = 0
	for xi as integer = 0 to size.x - 1
		'check block below
		if (tile(int2d(xi, yi + 1)).bgProp and IS_SOLID) then
			if (tile(int2d(xi, yi)).bgProp and IS_EMPTY) then
				if rnd > 0.5 then continue for
				dim as integer imgId = flowerArray(rndChoice(flowerArray()))
				tile(int2d(xi, yi)).set(imgId, 0, IS_FLOWER, 1)
			end if
		end if
	next
	'create resource / mineral veins
	dim as move_def_type move
	dim as int2d blockPos
	dim as integer iMove, badMove, imgId, veinLen, iResource
	for iVein as integer = 0 to NUM_VEINS - 1
		'random start position (within borders)
		blockPos.x = rndRange(1, size.x - 2)
		blockPos.y = rndRange(2, size.y - 2)
		'disallow one direction
		badMove = rndRange(0, 3)
		'random resource (for now, make heigt dependent)
		'imgId = resourceArray(rndChoice(resourceArray()))
		'height dependent resource
		iResource = (blockPos.y * pRes->numRes()) \ size.y
		if iResource < 0 or iResource >= pRes->numRes() then logger.add("map_type.setNormal()")
		imgId = pRes->imgId(iResource)
		veinLen = rndRange(MIN_VEIN_LEN, MAX_VEIN_LEN)
		for iBlock as integer = 0 to veinLen - 1
			if inRange(blockPos.x, 1, size.x - 2) andalso inRange(blockPos.y, 2, size.y - 2) then
				'set the resource on map
				if tile(blockPos).bgProp = IS_SOLID then
					tile(blockPos).set(imgId, -1, IS_SOLID or IS_RESOURCE)
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
	'create some caves
	dim as integer caveLen
	for iCave as integer = 0 to NUM_CAVES - 1
		blockPos.x = rndRange(1, size.x - 2)
		blockPos.y = rndRange(2, size.y - 2)
		caveLen = rndRange(MIN_CAVE_LEN, MAX_CAVE_LEN)
		for iBlock as integer = 0 to caveLen - 1
			'if validPos(blockPos) then
			if inRange(blockPos.x, 1, size.x - 2) andalso inRange(blockPos.y, 2, size.y - 2) then
				'clear fg block
				tile(blockPos).set(0, bg_shadow, IS_EMPTY, 0)
			else
				continue for 'next cave
			end if
			'make a step in random direction
			blockPos += move.dir_(rndRange(0, 3))
		next
	next
end sub

function map_type.validPos(pos_ as int2d) as boolean
	if pos_.x < 0 or pos_.x >= size.x then return false
	if pos_.y < 0 or pos_.y >= size.y then return false
	return true
end function

function map_type.tile(pos_ as int2d) byref as map_tile
	return(mTile(pos_.x, pos_.y))
end function

'Id = 0: do not draw
sub map_type.draw_(scrMapDist as flt2d)
	'get visible area (Tl = Top-Left, Br = Botton-Right)
	dim as int2d gridPos
	dim as int2d gridPosLt = getGridPos(scrMapDist)
	dim as int2d gridPosBr = getGridPos(scrMapDist + toFlt2d(scr.edge))
	dim as integer imgId
	for yi as integer = gridPosLt.y to gridPosBr.y
		for xi as integer = gridPosLt.x to gridPosBr.x
			gridPos = int2d(xi, yi)
			dim as int2d tileScrPos = getScrPos(gridPos, scrMapDist)
			if validPos(gridPos) then
				'draw background tiles
				imgId = tile(gridPos).bgId
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_PSET)
				end if
				'draw foreground tiles, flowers / grass animated
				imgId = tile(gridPos).fgId + iif((tile(gridPos).bgProp and IS_FLOWER), flowerAnimFrame(flowerAnimSeq), 0)
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
				end if
				'draw cracks on damaged blocks
				if (tile(gridPos).bgProp and IS_SOLID) then
					dim as integer damage = 4 - tile(gridPos).health
					if damage >= 0 and damage < 4 then 'range: 0...3
						imgId = fg_tile_damage_1 + damage
						imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
					end if
				end if
				'display tile properties bits
				f1.printTextAk(tileScrPos.x, tileScrPos.y, hex(tile(gridPos).bgProp), FHA_CENTER)
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
			if (tile(int2d(xi, yi + 1)).bgProp and IS_SOLID) then
				if (tile(int2d(xi, yi)).bgProp and IS_EMPTY) then
					dim as integer imgId = flowerArray(rndChoice(flowerArray()))
					tile(int2d(xi, yi)).set(imgId, 0, IS_FLOWER, 1)
					exit for
				end if
			end if
		next
	end if
end sub

'realy?
sub map_type.killFlower(pos_ as int2d)
	if validPos(pos_) then
		if (tile(pos_).bgProp and IS_FLOWER) then
			tile(pos_).set(0, -1, IS_EMPTY) 'bgProp)
			'reset to prevent accidental direct re-spawn
			flowerSpawnTmr.start(flowerSpawnTime)
		end if
	end if
end sub

destructor map_type()
	erase(mTile)
end destructor

