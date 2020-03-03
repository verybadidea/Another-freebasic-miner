'~ type intRange
	'~ dim as integer min, max
'~ end type

function inRange(value as integer, min as integer, max as integer) as boolean
	if value < min then return false
	if value > max then return false
	return true
end function

function rndRange(first as integer, last as integer) as integer
	return int((1 + last - first) * rnd) + first
end function

function rndChoice(choiceArray() as integer) as integer
	return int(rnd * (ubound(choiceArray) + 1))
end function

