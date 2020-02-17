function getFilePath(fullFileName as string) as string
	dim as integer sepPos = instrrev(fullFileName, any "/\")
	return mid(fullFileName, 1, sepPos)
end function

function getFileName(fullFileName as string) as string
	dim as integer sepPos = instrrev(fullFileName, any "/\")
	return mid(fullFileName, sepPos + 1)
end function

function getFileNoExt(fullFileName as string) as string
	dim as integer sepPos = instrrev(fullFileName, any "/\")
	dim as string fileName = mid(fullFileName, sepPos + 1)
	sepPos = instrrev(fileName, any ".")
	return mid(fileName, 1, sepPos - 1)
end function

function getFileExt(fullFileName as string) as string
	dim as integer sepPos = instrrev(fullFileName, any ".")
	return mid(fullFileName, sepPos + 1)
end function

function changeFileExt(fullFileName as string, newExt as string) as string
	dim as integer sepPos = instrrev(fullFileName, any ".")
	return mid(fullFileName, 1, sepPos) & newExt
end function

'~ 'make class, or static logFileName
'~ sub logToFile(text as string, logFileName as string)
	'~ if logFileName <> "" then
		'~ dim as integer fileNum
		'~ fileNum = freefile
		'~ if open(logFileName, for append, as fileNum) = 0 then 
			'~ print #fileNum, time & " " & text
			'~ close fileNum
		'~ end if
	'~ else
		'~ print time & " " & text
	'~ end if
'~ end sub
