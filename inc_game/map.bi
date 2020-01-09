const as ushort IS_SOLID = &h0001
const as ushort IS_CLIMB = &h0002
const as ushort IS_SUPPORT = &h0002
const as ushort IS_INVALID = &h8000
'const as ushort ALLOW_LADDER

type map_type
	dim as int2d size
	dim as image_type ptr bgImg(any, any) 'use pointer of make copy?
	dim as image_type ptr fgImg(any, any) 'use pointer of make copy?
	dim as ushort bgProp(any, any)
	declare function alloc(size as int2d) as integer
	declare sub setRandomImages(imBufBg as image_buffer_type, imBufFg as image_buffer_type)
	declare function validIndex(x as integer, y as integer) as boolean
	declare function validPos(pos_ as int2d) as boolean
	declare function getBgProp(gridPos as int2d) as ushort
	'declare sub setBgImg(x as integer, y as integer, pImg as image_type ptr)
	'declare sub setFgImg(x as integer, y as integer, pImg as image_type ptr)
	declare sub setTile(pos_ as int2d, pFgImg as image_type ptr, pBgImg as image_type ptr, flags as ushort)
	declare sub draw_(scrMapDist as flt2d)
	declare destructor()
end type

function map_type.alloc(size as int2d) as integer
	this.size = size
	redim bgImg(size.x, size.y)
	redim fgImg(size.x, size.y)
	redim bgProp(size.x, size.y)
	return 0
end function

sub map_type.setRandomImages(imBufBg as image_buffer_type, imBufFg as image_buffer_type)
	for yi as integer = 0 to size.y - 1
		for xi as integer = 0 to size.x - 1
			bgImg(xi, yi) = @imBufBg.image(int(rnd * imBufBg.numImages))
			fgImg(xi, yi) = @imBufFg.image(int(rnd * imBufFg.numImages))
			bgProp(size.x, size.y) = 0
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
function map_type.getBgProp(gridPos as int2d) as ushort
	if validPos(gridPos) then
		return bgProp(gridPos.x, gridPos.y)
	else
		'logger.add("map_type.getBgProp(): out-of-bounds")
		return IS_INVALID 'good return value?
	end if
end function

'~ sub map_type.setBgImg(x as integer, y as integer, pImg as image_type ptr)
	'~ if validIndex(x, y) then
		'~ bgImg(x, y) = pImg
	'~ else
		'~ logToFile("map_type.setBgImg: out-of-bounds", "gamelog.txt")
	'~ end if
'~ end sub

'~ sub map_type.setFgImg(x as integer, y as integer, pImg as image_type ptr)
	'~ if validIndex(x, y) then
		'~ fgImg(x, y) = pImg
	'~ else
		'~ logToFile("map_type.setFgImg: out-of-bounds", "gamelog.txt")
	'~ end if
'~ end sub

sub map_type.setTile(pos_ as int2d, pFgImg as image_type ptr, pBgImg as image_type ptr, flags as ushort)
	if validPos(pos_) then
		if pFgImg <> 0 then fgImg(pos_.x, pos_.y) = pFgImg
		if pBgImg <> 0 then bgImg(pos_.x, pos_.y) = pBgImg
		bgProp(pos_.x, pos_.y) = flags
	end if
end sub

sub map_type.draw_(scrMapDist as flt2d)
	'get visible area (Tl = Top-Left, Br = Botton-Right)
	dim as int2d gridPosLt = getGridPos(scrMapDist)
	dim as int2d gridPosBr = getGridPos(scrMapDist + toFlt2d(scr.edge))
	for yi as integer = gridPosLt.y to gridPosBr.y
		for xi as integer = gridPosLt.x to gridPosBr.x
			dim as int2d tileScrPos = getScrPos(int2d(xi, yi), scrMapDist)
			if validIndex(xi, yi) then
				if bgImg(xi, yi) <> 0 then
					bgImg(xi, yi)->drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_PSET)
				else
					'line(tileScrPos.x - GRID_HALF_X, tileScrPos.y - GRID_HALF_Y)-step(GRID_SIZE_X - 1, GRID_SIZE_Y - 1),rgba(0, 255, 255, 255), b
				end if
				if fgImg(xi, yi) <> 0 then fgImg(xi, yi)->drawxym(tileScrPos.x, tileScrPos.y, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
			end if
		next
	next
end sub

destructor map_type()
	erase bgImg
	erase fgImg
	erase bgProp
end destructor

