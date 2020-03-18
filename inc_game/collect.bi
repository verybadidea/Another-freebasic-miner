const as float V_COLLECTABLE = 200 'speed pixels/s (faster than walk speed)

type collectable_item
	dim as flt2d posMap
	dim as short imgId
end type

'list can grow, but never shrink, for performance, non-sorted
type collectable_list
	private:
	dim as integer numItems
	dim as collectable_item item(any)
	public:
	dim as single radius = 10.0
	declare constructor(startSize as integer)
	declare constructor()
	declare destructor()
	declare sub add(posMap as flt2d, imgId as short)
	declare sub del(index as integer)
	'not essential methods
	declare function numAlloc() as integer
	declare function numInUse() as integer
	declare function getPos(index as integer) as flt2d
	declare sub show()
	'non-list methods
	declare sub draw_(posViewTl as flt2d)
	declare sub update(targetMapPos as flt2d, targetRadius as single, _
		byref resource as resource_type, byref inv as inventory_type, dt as double)
end type

constructor collectable_list(startSize as integer)
	if startSize > 0 then
		redim item(startSize - 1)
	end if
end constructor

constructor collectable_list()
	this.constructor(0)
end constructor

destructor collectable_list()
	erase(item)
end destructor

sub collectable_list.add(posMap as flt2d, imgId as short)
	dim as integer ub = ubound(item)
	'if list is full, increase list size by 1
	if numItems = ub + 1 then
		redim preserve item(numItems)
	end if
	item(numItems).posMap = posMap
	item(numItems).imgId  = imgId
	numItems += 1
end sub

sub collectable_list.del(index as integer)
	'check valid index
	'if index >= 0 andalso index < numItems then
		'move last to del pos
		item(index) = item(numItems - 1)
		numItems -= 1
	'end if
end sub

function collectable_list.numAlloc() as integer
	return ubound(item) + 1
end function

function collectable_list.numInUse() as integer
	return numItems
end function

function collectable_list.getPos(index as integer) as flt2d
	return item(index).posMap
end function

'for debugging
sub collectable_list.show()
	print "--- " & numInUse() & " / " & numAlloc() & " ---"
	for i as integer = 0 to numItems - 1
		print i, item(i).posMap.x, item(i).posMap.y, item(i).imgId
	next
end sub

'draw all in list
sub collectable_list.draw_(posViewTl as flt2d)
	for i as integer = 0 to numItems - 1
		with item(i)
			'draw item
			dim as flt2d posScr = .posMap - posViewTl
			imgBufAll.image(.imgId).drawxym(posScr.x, posScr.y - 16, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
			'circle(posScr.x, posScr.y), radius, rgba(160, 160, 0, 255),,,,f
		end with
	next
end sub

sub collectable_list.update(targetMapPos as flt2d, targetRadius as single, _
	byref resource as resource_type, byref inv as inventory_type, dt as double)
	dim as flt2d deltaPos, velocity
	dim as single distance
	for i as integer = 0 to numItems - 1
		with item(i)
			deltaPos = targetMapPos - .posMap
			velocity = deltaPos.normalise() * V_COLLECTABLE
			.posMap += velocity * dt
			distance = .posMap.dist(targetMapPos)
			if distance < (radius + targetRadius) then
				del(i)
				'add to inventory
				'logger.add("imgId: " & .imgId)
				dim as short resId = resource.resId(.imgId + 22)
				logger.add("collected: " & inv.item(resId).label)
				inv.item(resId).amount += 1
			end if
		end with
	next
end sub
