'map -> grid
'get grid / tile id for a position on map
function getGridPos(mapPos as flt2d) as int2d
	dim as int2d gridPos
	gridPos.x = cint(mapPos.x / GRID_SIZE_X)
	gridPos.y = cint(mapPos.y / GRID_SIZE_Y)
	return gridPos
end function

function getGridPosXY(xMap as single, yMap as single) as int2d
	dim as int2d gridPos
	gridPos.x = cint(xMap / GRID_SIZE_X)
	gridPos.y = cint(yMap / GRID_SIZE_Y)
	return gridPos
end function

'grid -> screen
'get screen postion center of a grid position 
function getScrPos(gridPos as int2d, scrMapDist as flt2d) as int2d
	dim as int2d scrPos
	scrPos.x = gridPos.x * GRID_SIZE_X - scrMapDist.x
	scrPos.y = gridPos.y * GRID_SIZE_Y - scrMapDist.y
	return scrPos
end function

'~ function getScrPos(gridPos as int2d, playerScrPos as flt2d, playerMapPos as flt2d) as int2d
	'~ dim as int2d scrPos
	'~ scrPos.x = (playerScrPos.x - playerMapPos.x) + gridPos.x * GRID_SIZE_X
	'~ scrPos.y = (playerScrPos.y - playerMapPos.y) + gridPos.y * GRID_SIZE_Y
	'~ return scrPos
'~ end function
