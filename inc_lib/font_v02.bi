#include once "file.bi"
'#include once "bmp.bi"

enum font_trim_enum
	FT_LE 'left
	FT_RI 'right
	FT_TO 'top
	FT_BO 'bottom
end enum

enum font_draw_mode
	FDM_PSET
	FDM_TRANS
	FDM_ALPHA
end enum

enum font_horz_align
	FHA_LEFT
	FHA_CENTER
	FHA_RIGHT
end enum

type font_type
	dim as integer minSpacing = 6, offsetSpacing = 0
	dim as integer drawMode = FDM_ALPHA', hAlign = FHA_LEFT
	dim as integer xSize, ySize
	dim as integer xSprites, ySprites
	dim as integer numSprites
	dim as integer leTrim = 0, riTrim = 0, toTrim = 0, boTrim = 0
	dim as any ptr ptr pSpriteArray = 0
	dim as integer ptr pTrim(FT_LE to FT_BO) 'change to struct, and use redim
	declare destructor()
	declare sub destroy()
	declare sub manualTrim(ri as integer, le as integer, top as integer, bo as integer)
	declare sub autoTrim()
	declare function load(fileName as string, ySprites as integer, xSprites as integer) as integer
	declare sub printTextFw(x as integer, y as integer, text as string)
	declare sub printTextAk(x as integer, y as integer, text as string, hAlign as integer)
	declare sub setProp(minSpacing as integer, offsetSpacing as integer, drawMode as integer) 
	declare sub inputText(byref text as string, key as string, maxLength as integer)
	declare function pixLength(text as string) as integer
end type

destructor font_type()
	destroy()
end destructor

sub font_type.destroy()
	for i as integer = 0 to numSprites-1
		if(pSpriteArray[i] <> 0) then
			imagedestroy(pSpriteArray[i])
			pSpriteArray[i] = 0
		end if
	next
	if (pSpriteArray <> 0) then
		deallocate(pSpriteArray)
		pSpriteArray = 0
	end if
	for i as integer = FT_LE to FT_BO
		if (pTrim(i) <> 0) then
			deallocate(pTrim(i))
			pTrim(i) = 0
		end if
	next
end sub

sub font_type.manualTrim(le as integer, ri as integer, top as integer, bo as integer)
  'manual trim, use to reduce character spacing in bitmap
  leTrim = le
  riTrim = ri
  toTrim = top
  boTrim = bo
end sub

sub font_type.autoTrim()
	for i as integer = FT_LE to FT_BO
		pTrim(i) = allocate(numSprites * sizeof(integer))
	next
	dim as integer trimPos
	for iChar as integer = 0 to numSprites-1
		'scan form top
		trimPos = 1
		for y as integer = 1 to ySize-2
			for x as integer = 1 to xSize-2
				if point(x, y, pSpriteArray[iChar]) and &hff000000 <> 0 then exit for, for
			next
			trimPos += 1
		next
		pTrim(FT_TO)[iChar] = trimPos
		'scan form bottom
		trimPos = 1'ySize-1
		for y as integer = ySize-2 to 1 step -1
			for x as integer = 1 to xSize-2
				if point(x, y, pSpriteArray[iChar]) and &hff000000 <> 0 then exit for, for
			next
			trimPos +=1'-= 1
		next
		pTrim(FT_BO)[iChar] = trimPos
		'scan form left
		trimPos = 1
		for x as integer = 1 to xSize-2
			for y as integer = 1 to ySize-2
				if point(x, y, pSpriteArray[iChar]) and &hff000000 <> 0 then exit for, for
			next
			trimPos += 1
		next
		pTrim(FT_LE)[iChar] = trimPos
		'scan form Right
		trimPos = 1'xSize-1
		for x as integer = xSize-2 to 1 step -1
			for y as integer = 1 to ySize-2
				if point(x, y, pSpriteArray[iChar]) and &hff000000 <> 0 then exit for, for
			next
			trimPos +=1'-= 1
		next
		pTrim(FT_RI)[iChar] = trimPos
	next
end sub

function font_type.load(fileName as string, ySprites as integer, xSprites as integer) as integer
	dim as bitmap_header bmpHeader
	dim as any ptr bmpData
	dim as integer xi, yi, i = 0
	dim as integer x1, y1
	dim as integer xPitch, yPitch
	if fileExists(filename) then
		open fileName for binary as #1
			get #1, , bmpHeader
		close #1
		bmpData = imagecreate(bmpHeader.biWidth, bmpHeader.biHeight)
		bload fileName, bmpData
		'print "Bitmap loaded: " & filename
		numSprites = xSprites * ySprites
		xPitch = (bmpHeader.biWidth \ xSprites)
		yPitch = (bmpHeader.biHeight \ ySprites)
		xSize = xPitch - (riTrim + leTrim)
		ySize = yPitch - (toTrim + boTrim)
		'create sprite pointers
		pSpriteArray = callocate(numSprites, sizeof(any ptr))
		for yi = 0 to ySprites-1
			for xi = 0 to xSprites-1
				pSpriteArray[i] = imagecreate(xSize, ySize)
				x1 = xi * xPitch + leTrim
				y1 = yi * yPitch + toTrim
				get bmpData, (x1, y1)-step(xSize - 1, ySize - 1), pSpriteArray[i]
				i += 1
			next
		next
		imagedestroy(bmpData)
		return 0
	end if
	return -1
end function

'Fixed width
sub font_type.printTextFw(x as integer, y as integer, text as string)
	if pSpriteArray = 0 then exit sub 'not init / loaded
	dim as integer i, textLen = len(text)
	dim as ubyte ptr pText = strptr(text)
	for i = 0 to textLen-1
		select case drawMode
			case FDM_PSET  : put (x + i * xSize, y), pSpriteArray[pText[i]], pset
			case FDM_TRANS : put (x + i * xSize, y), pSpriteArray[pText[i]], trans
			case FDM_ALPHA : put (x + i * xSize, y), pSpriteArray[pText[i]], alpha
		end select
	next
end sub

function font_type.pixLength(text as string) as integer
	dim as ubyte ptr pText = strptr(text)
	dim as integer textLen = len(text)
	dim as integer charNum, charWidth, pixLen
	for i as integer = 0 to textLen-1
		charNum = pText[i]
		charWidth = xSize - (pTrim(FT_LE)[charNum] + pTrim(FT_RI)[charNum])
		if charWidth < 0 then charWidth = 0
		if charWidth < minSpacing then charWidth = minSpacing 'minimum spacing, for white characters
		pixLen += (charWidth + offsetSpacing) 'some extra or less spacing
	next
	return pixLen
end function

'Auto kern
sub font_type.printTextAk(x as integer, y as integer, text as string, hAlign as integer)
	if pSpriteArray = 0 then exit sub 'not init / loaded
	if pTrim(0) = 0 then exit sub 'not init, call autoTrim
	dim as integer i, textLen = len(text)
	dim as ubyte ptr pText = strptr(text)
	dim as integer charNum, charWidth, charLeft, pixLen
	if hAlign <> FHA_LEFT then
		pixLen = pixLength(text)
		if hAlign = FHA_CENTER then x -= pixLen \ 2
		if hAlign = FHA_RIGHT then x -= pixLen
	end if
	for i = 0 to textLen-1
		charNum = pText[i]
		charLeft = pTrim(FT_LE)[charNum]
		charWidth = xSize - (charLeft + pTrim(FT_RI)[charNum])
		if charWidth < 0 then charWidth = 0
		select case drawMode
			case FDM_PSET  : put (x, y), pSpriteArray[charNum], (charLeft, 0)-step(charWidth-1, ySize-1), pset
			case FDM_TRANS : put (x, y), pSpriteArray[charNum], (charLeft, 0)-step(charWidth-1, ySize-1), trans
			case FDM_ALPHA : put (x, y), pSpriteArray[charNum], (charLeft, 0)-step(charWidth-1, ySize-1), alpha
		end select
		if charWidth < minSpacing then charWidth = minSpacing 'minimum spacing, for white characters
		x += (charWidth + offsetSpacing) 'some extra or less spacing
	next
end sub

sub font_type.setProp(minSpacing as integer, offsetSpacing as integer, drawMode as integer)
	this.minSpacing = minSpacing
	this.offsetSpacing = offsetSpacing
	this.drawMode = drawMode
	'this.hAlign = hAlign
end sub

sub font_type.inputText(byref text as string, key as string, maxLength as integer)
	select case key
	case chr(27) 'escape
	case chr(13) 'enter
	case chr(33) to chr(126) 'somewhat normal characters
		if len(text) < maxLength then text += key
	case chr(8) 'backspace
		if len(text) > 0 then text = left(text, len(text) - 1)
	case else
	end select
end sub
