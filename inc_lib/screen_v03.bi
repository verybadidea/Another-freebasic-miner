#include once "fbgfx.bi"
#include once "colors_v01.bi"
#include once "int2d_v02.bi"

type screen_type ' pretty dumb graphics class
	private:
		'dim as fb.Image ptr pFbImg
		dim as integer wPage, vPage 'work page, visible page
	public:
		'dim as long w, h 'size
		dim as int2d size
		dim as int2d cntr 'center
		dim as int2d edge
		dim as long gfxFlags
		declare constructor(w as long, h as long, flags as long)
		declare sub activate()
		declare sub flipPage()
		'~ declare sub equalPage()
		declare sub clearScreen(colour as ulong)
		declare sub dimScreen(dimFactor as single) '0...1 
end type

constructor screen_type(w as long, h as long, flags as long)
	size = int2d(w, h)
	cntr = int2d(w \ 2, h \ 2)
	edge = int2d(w - 1, h - 1)
	gfxFlags = flags
end constructor

sub screen_type.activate()
	screenres size.x, size.y, 32, 2, gfxFlags
	width size.x \ 8, size.y \ 16 'bigger font
	'pFbImg = ImageCreate(w, h)
	wPage = 0
	vPage = 0
	screenset wPage, vPage
	wPage = 1
end sub

sub screen_type.flipPage()
	screenset wPage, vPage
	wPage xor= 1
	vPage xor= 1
end sub

'~ sub screen_type.equalPage()
	'~ screenset wPage, vPage
	'~ screencopy wPage, vPage
	'~ wPage xor= 1
	'~ vPage xor= 1
'~ end sub

sub screen_type.clearScreen(colour as ulong)
	line(0, 0)-(size.x - 1, size.y - 1), colour, bf
end sub

sub screen_type.dimScreen(dimFactor as single)
	dim as integer pitch, xi, yi
	dim as rgba_union ptr pRow
	'get (0, 0)-(w - 1, h - 1), pFbImg
	'if imageinfo(pFbImg, , , , pitch, pPixels) <> 0 then exit sub
	ScreenInfo , , , , pitch
	dim as any ptr pPixels = ScreenPtr()
	if pPixels = 0 then exit sub
	for yi = 0 to size.y - 1
		pRow = pPixels + yi * pitch
		for xi = 0 to size.x - 1
			pRow[xi].r *= dimFactor
			pRow[xi].g *= dimFactor
			pRow[xi].b *= dimFactor
		next
	next
	'put (0, 0), pFbImg, pset
end sub
