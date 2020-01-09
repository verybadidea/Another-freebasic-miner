#include once "dir.bi"
#include once "image_v03.bi"

type image_buffer_type
	dim as integer numImages
	dim as image_type image(any)
	dim as string imageFileName(any)
	declare destructor()
	declare function addFile(fileName as string) as integer
	declare function loadDir(path as string) as integer
	declare function getImageIdByName(fileName as string) as integer
	'declare function validId(id as integer) as boolean
	declare function validImage(id as integer) as boolean
end type

destructor image_buffer_type()
	erase image, imageFileName
	numImages = 0
end destructor

function image_buffer_type.addFile(fileName as string) as integer
	redim preserve imageFileName(numImages)
	imageFileName(numImages) = fileName
	numImages += 1
	return 0
end function

function image_buffer_type.loadDir(path as string) as integer
	numImages = 0
	'get list of bmp files
	dim as string fileName = dir(path + "*.bmp", fbArchive)
	if fileName = "" then return -1 'No files found in path
	while (len(filename) > 0)
		addFile(path + fileName)
		fileName = dir()
	wend
	'bubble sort file names
	for i as integer = 0 to numImages - 1
		for j as integer = i + 1 to numImages - 1
			if imageFileName(i) > imageFileName(j) then
				swap imageFileName(i), imageFileName(j)
			end if
		next
	next
	'allocate & load the images
	redim image(numImages)
	for i as integer = 0 to numImages - 1
		if (image(i).createFromBmp(imageFileName(i)) <> 0) then return -1
		'print imageFileName(i)
	next
	return 0
end function

function image_buffer_type.getImageIdByName(fileName as string) as integer
	for i as integer = 0 to ubound(imageFileName)
		if imageFileName(i) = fileName then return i
	next
	return -1
end function

'~ function image_buffer_type.validId(id as integer) as boolean
	'~ if id >= 0 and id <= ubound(image) then return true
	'~ return false
'~ end function

function image_buffer_type.validImage(id as integer) as boolean
	if id < 0 or id > ubound(image) then return false
	if image(id).pFbImg = 0 then return false
	return true
end function
