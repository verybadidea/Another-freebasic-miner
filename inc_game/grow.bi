type plant_type
	dim as short fistImgId
	dim as short numImg
	dim as double frameIntervalTime
end type

enum E_PLANT
	PL_CARROT '0
	PL_GRAPE '1
	PL_TOMATO '2
	PL_INVALID ' 3
end enum

dim shared as plant_type plant(PL_INVALID - 1) = {_
	(pl_carrot_0, 4, 5.0), _
	(pl_grape_0, 11, 5.0), _
	(pl_tomato_0, 8, 5.0)}

'-------------------------------------------------------------------------------

type plant_grow_item
	dim as integer plantId
	dim as int2d gridPos
	'dim as boolean active
	dim as double nextImageTime
	dim as integer imgIndex
end type

'-------------------------------------------------------------------------------

'list can grow, but never shrink, for performance, non-sorted
type plant_grow_list
	private:
	dim as map_type ptr pMap
	dim as integer numItems
	dim as plant_grow_item item(any)
	public:
	dim as single radius = 10.0
	declare constructor(byref map as map_type, startSize as integer)
	declare destructor()
	declare sub add(gridPos as int2d, plantId as integer)
	declare sub del(index as integer)
	declare function findByPos(gridPos as int2d) as integer
	'not essential methods
	declare function numAlloc() as integer
	declare function numInUse() as integer
	'non-list methods
	declare sub update()
end type

constructor plant_grow_list(byref map as map_type, startSize as integer)
	pMap = @map
	if startSize > 0 then
		redim item(startSize - 1)
	end if
end constructor

destructor plant_grow_list()
	erase(item)
end destructor

sub plant_grow_list.add(gridPos as int2d, plantId as integer)
	dim as integer ub = ubound(item)
	'if list is full, increase list size by 1
	if numItems = ub + 1 then
		redim preserve item(numItems)
	end if
	item(numItems).gridPos = gridPos
	item(numItems).plantId = plantId
	'item(numItems).active = TRUE
	item(numItems).nextImageTime = timer + plant(plantId).frameIntervalTime
	item(numItems).imgIndex = 0
	numItems += 1
	logger.add("numPlants:" & numItems)
end sub

sub plant_grow_list.del(index as integer)
	'check valid index
	'if index < 0 or index >= numItems then error
	'move last items into place
	item(index) = item(numItems - 1)
	numItems -= 1
end sub

function plant_grow_list.findByPos(gridPos as int2d) as integer
	for i as integer = 0 to numItems - 1
		if gridPos = item(i).gridPos then return i
	next
	return -1
end function

function plant_grow_list.numAlloc() as integer
	return ubound(item) + 1
end function

function plant_grow_list.numInUse() as integer
	return numItems
end function

sub plant_grow_list.update()
	for i as integer = 0 to numItems - 1
		with item(i)
			if timer > .nextImageTime then
				if .imgIndex >= plant(.plantId).numImg - 1 then
					'remove from list
					'del(i)
					'logger.add("plant deleted with index:" & i)
				else
					'update frame, nextImageTime
					.imgIndex += 1
					.nextImageTime = timer + plant(.plantId).frameIntervalTime
					'update image on map
					dim as short imgId = plant(.plantId).fistImgId + .imgIndex
					pMap->tile(.gridPos).set(imgId, -1)
					logger.add("plant image updated, index:" & .imgIndex)
				end if
			end if
		end with
	next
end sub
