function rndRange(first as integer, last as integer) as integer
	return int((1 + last - first) * rnd) + first
end function

function rndChoice(choiceArray() as integer) as integer
	return int(rnd * (ubound(choiceArray) + 1))
end function
