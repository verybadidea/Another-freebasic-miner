const as short IS_BAD = &h0000
const as short IS_EMPTY = &h0001
const as short IS_FIXED = &h0002
const as short IS_SOLID = &h0004
const as short IS_CLIMB = &h0008
const as short IS_FLOWER = &h0010
const as short IS_INVALID = &h8000
'const as short IS_SUPPORT = &h0008
'const as short IS_INVALID = &h8000
'const as short ALLOW_LADDER

type map_type
	public:
	dim as int2d size
	private:
	dim as short bgId(any, any)
	dim as short fgId(any, any)
	dim as short bgProp(any, any)
	'move this plant stuff elsewehere?
	dim as timer_type plantAnimTmr
	dim as integer plantAnimSeq 'index for plantAnimFrame()
	dim as double plantAnimDuration = 0.2
	dim as integer plantAnimFrame(0 to 3) = {0, 1, 2, 1}
	public:
	declare function alloc(size as int2d) as integer
	declare sub setRandomImages()
	declare function validIndex(x as integer, y as integer) as boolean
	declare function validPos(pos_ as int2d) as boolean
	declare function getBgProp(gridPos as int2d) as short
	declare sub setTile(pos_ as int2d, fgId as short, bgId as short, flags as short = 0)
	declare sub draw_(scrMapDist as flt2d)
	declare destructor()
end type

function map_type.alloc(size as int2d) as integer
	this.size = size
	redim bgId(size.x, size.y)
	redim fgId(size.x, size.y)
	redim bgProp(size.x, size.y)
	plantAnimSeq = 0
	plantAnimTmr.start(plantAnimDuration)
	return 0
end function

sub map_type.setRandomImages()
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			bgId(xi, yi) = rndRange(bg_block_2a, bg_wall_5)
			fgId(xi, yi) = rndRange(fg_artefact_bone_1, fg_tile_deco_2)
			bgProp(size.x, size.y) = IS_EMPTY
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
sub map_type.setTile(pos_ as int2d, fgId as short, bgId as short, flags as short = 0)
	if validPos(pos_) then
		if fgId >= 0 then this.fgId(pos_.x, pos_.y) = fgId
		if bgId >= 0 then this.bgId(pos_.x, pos_.y) = bgId
		if flags <> 0 then bgProp(pos_.x, pos_.y) = flags
	end if
end sub

'Id = 0: do not draw
sub map_type.draw_(scrMapDist as flt2d)
	'move this to map.update() later
	if plantAnimTmr.ended() then
		plantAnimSeq += 1
		if plantAnimSeq > ubound(plantAnimFrame) then plantAnimSeq = plantAnimFrame(0)
		plantAnimTmr.start(plantAnimDuration)
	end if
	'get visible area (Tl = Top-Left, Br = Botton-Right)
	dim as int2d gridPosLt = getGridPos(scrMapDist)
	dim as int2d gridPosBr = getGridPos(scrMapDist + toFlt2d(scr.edge))
	dim as integer imgId
	for yi as integer = gridPosLt.y to gridPosBr.y
		for xi as integer = gridPosLt.x to gridPosBr.x
			dim as int2d tileScrPos = getScrPos(int2d(xi, yi), scrMapDist)
			if validIndex(xi, yi) then
				imgId = bgId(xi, yi)
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_PSET)
				end if
				imgId = fgId(xi, yi) + iif((bgProp(xi, yi) and IS_FLOWER), plantAnimFrame(plantAnimSeq), 0)
				if imgId > 0 andalso imgBufAll.validImage(imgId) then
					imgBufAll.image(imgId).drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
				end if
				'display tile properties bits
				'f1.printTextAk(tileScrPos.x, tileScrPos.y, hex(bgProp(xi, yi)), FHA_CENTER)
			end if
		next
	next
end sub

destructor map_type()
	erase bgId
	erase fgId
	erase bgProp
end destructor

