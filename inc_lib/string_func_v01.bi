function findAndReplace(txt1 as string, char as string) as string
	dim as string txt2 = txt1
	mid(txt2, instr(txt1, "#"), 1) = char
	return txt2
end function

'Note: Uses first char pos = 0
function cutChar(text as string, charPos as integer) as string
	return mid(text, 1, charPos) & mid(text, charPos + 2)
end function

const STR_LF = !"\n"
const STR_DQ = chr(34)
const STR_SQ = chr(39)

function quote(str1 as string) as string
	return STR_DQ + str1 + STR_DQ
end function

sub ucaseList(listStr() as string)
   for i as integer = 0 to ubound(listStr)
      listStr(i) = ucase(listStr(i))
   next
end sub

sub printList(listStr() as string)
	for i as integer = 0 to ubound(listStr)
		print listStr(i) & " ";
	next
	print
end sub

'case sensitive!
function findInList(findStr as string, listStr() as string) as integer
	for i as integer = 0 to ubound(listStr)
		if listStr(i) = findStr then return i 'found
	next
	return -1 'not found
end function

sub colorPrint(text as string, fc as integer)
	color fc, 0
	print text
	color 15, 0
end sub

'concatenate with smart token insertion
function tokcat(str1 as string = "", str2 as string = "", str3 as string = "", str4 as string = "", str5 as string = "") as string
	dim as string retStr = ""
	if len(str1) <> 0 then retStr &= iif(len(retStr) = 0, str1, " + " & str1)
	if len(str2) <> 0 then retStr &= iif(len(retStr) = 0, str2, " + " & str2)
	if len(str3) <> 0 then retStr &= iif(len(retStr) = 0, str3, " + " & str3)
	if len(str4) <> 0 then retStr &= iif(len(retStr) = 0, str4, " + " & str4)
	if len(str5) <> 0 then retStr &= iif(len(retStr) = 0, str5, " + " & str5)
	return retStr
end function

'concatenate with dump token insertion
function simplecat(str1 as string = "", str2 as string = "", str3 as string = "", str4 as string = "", str5 as string = "") as string
	dim as string retStr = ""
	retStr &= str1
	retStr &= " + " & str2
	retStr &= " + " & str3
	retStr &= " + " & str4
	retStr &= " + " & str5
	return retStr
end function

'count chars in string
function countInStr(text as string, charStr as string) as integer
	dim as ubyte char = charStr[0]
	dim as integer count = 0
	for i as integer = 0 to len(text) - 1
		if text[i] = char then count += 1
	next
	return count
end function

'count capitals in string
function countCapStr(text as string) as integer
	dim as integer count = 0
	for i as integer = 0 to len(text) - 1
		if text[i] >= asc("A") and text[i] <= asc("Z") then count += 1
	next
	return count
end function

function dynamicAdd(dynListStr() as string, addSTr as string) as integer
	dim as integer ub = ubound(dynListStr)
	redim preserve dynListStr(ub + 1)
	dynListStr(ub + 1) = addSTr
	return ub + 1
end function
