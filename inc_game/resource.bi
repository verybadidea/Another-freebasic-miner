type resource_type
	public:
	dim as short imgId(0 to 9) = {fg_resource_salt, fg_resource_cole, _
		fg_resource_iron, fg_resource_gold, fg_resource_silver, fg_resource_lazurite, _
		fg_resource_platin, fg_resource_ruby, fg_resource_uranium, fg_resource_sapphire}
	dim as short resId(fg_resource_cole to fg_resource_yorbinium)
	declare constructor()
	declare function numRes() as integer
end type

constructor resource_type()
	'set all invalid
	for i as integer = lbound(resId) to ubound(resId)
		resId(i) = -1
	next
	'set known resources, lookup table
	for i as integer = 0 to ubound(imgId)
		resId(imgId(i)) = i
	next
end constructor

function resource_type.numRes() as integer
	return ubound(imgId) + 1
end function

'-------------------------------------------------------------------------------

enum E_INV_CAT
	INV_CAT_NONE
	INV_CAT_RES
	INV_CAT_BLOCK 'bg item
	INV_CAT_OBJECT 'fg item
end enum

type inventory_item
	dim as long amount
	dim as long category
	dim as string label
	declare constructor()
	declare constructor(amount as long, category as long, label as string)
end type

constructor inventory_item()
	this.constructor(0, 0, "no_item")
end constructor

'-------------------------------------------------------------------------------

constructor inventory_item(amount as long, category as long, label as string)
	this.amount = amount
	this.category = category
	this.label = label
end constructor

type inventory_type
	dim as inventory_item item(any)
	declare constructor()
	declare function numItems() as integer
end type

constructor inventory_type()
	redim item(0 to 9)
	item(0) = inventory_item(0, INV_CAT_RES, "salt")
	item(1) = inventory_item(0, INV_CAT_RES, "coal")
	item(2) = inventory_item(0, INV_CAT_RES, "iron")
	item(3) = inventory_item(0, INV_CAT_RES, "gold")
	item(4) = inventory_item(0, INV_CAT_RES, "silver")
	item(5) = inventory_item(0, INV_CAT_RES, "lazurite")
	item(6) = inventory_item(0, INV_CAT_RES, "platin")
	item(7) = inventory_item(0, INV_CAT_RES, "ruby")
	item(8) = inventory_item(0, INV_CAT_RES, "uranium")
	item(9) = inventory_item(0, INV_CAT_RES, "sapphire")
end constructor

function inventory_type.numItems() as integer
	return ubound(item) + 1
end function
