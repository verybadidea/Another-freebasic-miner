function findAndReplace(txt1 as string, char as string) as string
	dim as string txt2 = txt1
	mid(txt2, instr(txt1, "#"), 1) = char
	return txt2
end function

