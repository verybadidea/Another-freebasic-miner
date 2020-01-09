#include once "file.bi"
#include once "file_func_v01.bi"
#include once "bmp_v01.bi"
#include once "int2d_v02.bi"

'===============================================================================

enum image_horz_align
	IHA_LEFT
	IHA_CENTER
	IHA_RIGHT
end enum

enum image_vert_align
	IVA_TOP
	IVA_CENTER
	IVA_BOTTOM
end enum

enum image_draw_mode
	IDM_PSET
	IDM_TRANS
	IDM_ALPHA
end enum

dim shared as integer image_horz_align_default = IHA_LEFT
dim shared as integer image_vert_align_default = IVA_TOP
dim shared as integer image_draw_mode_default = IDM_PSET

type image_type
	dim as any ptr pFbImg
	dim as int2d size, half
	dim as integer hAlign, vAlign, drawMode
	declare sub create(sizeInit as int2d, colorInit as ulong)
	declare function createFromBmp(fileName as string) as integer
	declare function copyTo(byref newImg as image_type) as integer
	declare function hFlipTo(byref newImg as image_type) as integer
	declare sub setProp(hAlign as integer, hAlign as integer, drawMode as integer)
	declare sub drawxy(x as integer, y as integer)
	declare sub drawxym(x as integer, y as integer, _
		iha as image_horz_align = IHA_LEFT, iva as image_vert_align = IVA_TOP, _
		idm as image_draw_mode = IDM_PSET, alphaval as integer = -1)
	declare sub destroy()
	declare destructor()
end type

sub image_type.create(sizeInit as int2d, colorInit as ulong)
	pFbImg = imagecreate(sizeInit.x, sizeInit.y, colorInit)
	size = sizeInit
	half = size \ 2
	setProp(image_horz_align_default, image_vert_align_default, image_draw_mode_default)
end sub

function image_type.createFromBmp(fileName as string) as integer
	dim as bitmap_header bmp_header
	dim as int2d bmpSize
	if fileExists(filename) then
		if ucase(getFileExt(filename)) = "BMP" then
			open fileName for binary as #1
				get #1, , bmp_header
			close #1
			bmpSize.x = bmp_header.biWidth
			bmpSize.y = bmp_header.biHeight
			create(bmpSize, &hff000000)
			bload fileName, pFbImg
			'print "Bitmap loaded: " & filename
			return 0
		else
		'print "Wrong file type: " & filename
		end if
		return -2
	end if
	'print "File not found: " & filename
	return -1
end function

'deep copy, call srcImg.copyTo(newImg), also set draw properties
function image_type.copyTo(byref newImg as image_type) as integer
	if newImg.pFbImg <> 0 then return -1
	newImg.create(size, &hff000000)
	put newImg.pFbImg, (0, 0), pFbImg, pset
	return 0
end function

function image_type.hFlipTo(byref newImg as image_type) as integer
	dim as integer w, h, bypp, pitch
	dim as ulong ptr pPixSrc, pPixDst
	dim as single r, g, b, intensity
	'get source image info and check things
	if imageinfo(pFbImg, w, h, bypp, pitch, pPixSrc) <> 0 then return -1
	if bypp <> 4 then return -2 'only 32-bit images
	if pPixSrc = 0 then return -3
	'create dest image, get info and check things
	if newImg.pFbImg <> 0 then return -4
	newImg.create(int2d(w, h), &hff000000)
	if newImg.pFbImg = 0 then return -5
	if imageinfo(newImg.pFbImg, w, h, bypp, pitch, pPixDst) <> 0 then return -6
	if pPixDst = 0 then return -7
	'do the flip source to destination
	dim as integer xiDst
	pitch shr= 2 'stepping 4 bytes at a time
	for yi as integer = 0 to h - 1
		xiDst = w
		for xi as integer = 0 to w - 1
			xiDst -= 1
			pPixDst[xiDst] = pPixSrc[xi]
		next
		pPixSrc += pitch
		pPixDst += pitch
	next
	newImg.size = size 'call create instead?
	newImg.half = half
	return 0
end function

sub image_type.setProp(hAlign as integer, vAlign as integer, drawMode as integer)
	this.hAlign = hAlign
	this.vAlign = vAlign
	this.drawMode = drawMode
end sub

sub image_type.drawxy(x as integer, y as integer)
	if pFbImg = 0 then exit sub
	select case hAlign
		case IHA_CENTER : x -= half.x
		case IHA_RIGHT : x -= size.x
	end select
	select case vAlign
		case IVA_CENTER : y -= half.y
		case IVA_BOTTOM : y -= size.y
	end select
	select case drawMode
		case IDM_PSET : put (x , y), pFbImg, pset
		case IDM_TRANS : put (x , y), pFbImg, trans
		case IDM_ALPHA : put (x , y), pFbImg, alpha ', alphaval
	end select
end sub

sub image_type.drawxym(x as integer, y as integer, _
	iha as image_horz_align = IHA_LEFT, iva as image_vert_align = IVA_TOP, _
	idm as image_draw_mode = IDM_PSET, alphaval as integer = -1)
	'
	if pFbImg = 0 then exit sub
	select case iha
		case IHA_CENTER : x -= half.x
		case IHA_RIGHT : x -= size.x
	end select
	select case iva
		case IVA_CENTER : y -= half.y
		case IVA_BOTTOM : y -= size.y
	end select
	select case idm
		case IDM_PSET : put (x , y), pFbImg, pset
		case IDM_TRANS : put (x , y), pFbImg, trans
		case IDM_ALPHA
		if alphaval = -1 then
			 put (x , y), pFbImg, alpha
		else
			put (x , y), pFbImg, alpha, alphaval
		end if
	end select
end sub

sub image_type.destroy()
	if (pFbImg <> 0) then
		imagedestroy(pFbImg)
		pFbImg = 0
	end if
end sub

destructor image_type()
	destroy()
end destructor

'~ function loadImages(pImg as image_type ptr, fileNameTemplate as string, numImg as integer) as integer
	'~ dim as integer i, result
	'~ dim as string fileName
	'~ for i = 0 to numImg-1
		'~ fileName = findAndReplace(fileNameTemplate, str(i + 1))
		'~ result = pImg[i].createFromBmp(fileName)
		'~ logToFile(fileName & " - " & iif(result = 0, "OK", "FAIL"))
		'~ if result <> 0 then return -1
	'~ next
	'~ return 0
'~ end function

'~ function flipImages(pImgSrc as image_type ptr, pImgDst as image_type ptr, numImg as integer) as integer
	'~ for i as integer = 0 to numImg-1
		'~ if pImgSrc[i].hFlipTo(pImgDst[i]) <> 0 then return -1
	'~ next
	'~ return 0
'~ end function

'===============================================================================

'~ type area_type
	'~ dim as integer x1, y1
	'~ dim as integer x2, y2
'~ end type

'~ function imageGrayInt(pFbImg as any ptr, area as area_type, intOffs as integer) as integer
	'~ dim as integer w, h, bypp, pitch
	'~ dim as integer xi, yi, intensity
	'~ dim as any ptr pPixels
	'~ dim as rgba_union ptr pRow
	'~ if imageinfo(pFbImg, w, h, bypp, pitch, pPixels) <> 0 then return -1
	'~ if bypp <> 4 then return -2 'only 32-bit images
	'~ if pPixels = 0 then return -3
	'~ if area.x1 < 0 or area.x1 >= w then return -4
	'~ if area.y1 < 0 or area.y1 >= h then return -5
	'~ if area.x2 < 0 or area.x2 >= w then return -6
	'~ if area.y2 < 0 or area.y2 >= h then return -7
	'~ for yi = area.y1 to area.y2
		'~ pRow = pPixels + yi * pitch
		'~ for xi = area.x1 to area.x2
			'~ intensity = cint(0.3 * pRow[xi].r + 0.5 * pRow[xi].g + 0.2 * pRow[xi].b) + intOffs
			'~ if intensity < 0 then intensity = 0
			'~ if intensity > 255 then intensity = 255
			'~ pRow[xi].r = intensity
			'~ pRow[xi].g = intensity
			'~ pRow[xi].b = intensity
		'~ next
	'~ next
	'~ return 0
'~ end function

'~ sub dimScreen(dimFactor as single)
	'~ dim as integer w, h, pitch, xi, yi
	'~ dim as rgba_union ptr pRow
	'~ ScreenInfo w, h, , , pitch
	'~ dim as any ptr pPixels = ScreenPtr()
	'~ if pPixels = 0 then exit sub
	'~ for yi = 0 to h-1
		'~ pRow = pPixels + yi * pitch
		'~ for xi = 0 to w-1
			'~ pRow[xi].r *= dimFactor
			'~ pRow[xi].g *= dimFactor
			'~ pRow[xi].b *= dimFactor
			'~ 'pRow[xi].r shr= 1
			'~ 'pRow[xi].g shr= 1
			'~ 'pRow[xi].b shr= 1
			'~ 'if pRow[xi].r > 0 then pRow[xi].r -= 1
			'~ 'if pRow[xi].g > 0 then pRow[xi].g -= 1
			'~ 'if pRow[xi].b > 0 then pRow[xi].b -= 1
		'~ next
	'~ next
'~ end sub

'~ sub clearScreen()
	'~ dim as integer w, h, pitch, xi, yi
	'~ ScreenInfo w, h, , , pitch
	'~ line(0, 0) - (w-1, h-1), C_BLACK, bf
'~ end sub
