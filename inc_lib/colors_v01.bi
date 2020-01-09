union rgba_union
	value as ulong
	type
		b as ubyte
		g as ubyte
		r as ubyte
		a as ubyte
	end type
end union

function createPixel(r as ubyte, g as ubyte, b as ubyte) as rgba_union
	dim as rgba_union pixel
	pixel.r = r
	pixel.g = g
	pixel.b = b
	return pixel
end function

'hRGB(&hFFF)
'r = (((rgb_ and &hF00) shl 4) or (rgb_ and &hF00)) shl 8
'g = (((rgb_ and &h0F0) shl 4) or (rgb_ and &h0F0)) shl 4
'b = ((rgb_ and &h00F) shl 4) or (rgb_ and &h00F)
#define hRGB(rgb_) ((((((rgb_) and &hF00) shl 4) or ((rgb_) and &hF00)) shl 8) or (((((rgb_) and &h0F0) shl 4) or ((rgb_) and &h0F0)) shl 4) or ((((rgb_) and &h00F) shl 4) or ((rgb_) and &h00F)))

'cRGB(0..15, 0..15, 0..15)
'r = (r shl 4) + r
'g = (g shl 4) + g
'b = (b shl 4) + b
#define cRGB(r,g,b) (((((r) shl 4) + (r)) shl 16) or ((((g) shl 4) + (g)) shl 8) or (((b) shl 4) + (b))) 

'dec -> hex: 10 = A, 11 = B, 12 = C, 13 = D, 14 = E, 15 = F

'https://en.wikipedia.org/wiki/DIN_47100
const as ulong C_BK = cRGB(0,0,0)
const as ulong C_WH = cRGB(15,15,15)

const as ulong C_RD = cRGB(15,0,0)
const as ulong C_GN = cRGB(0,15,0)
const as ulong C_BU = cRGB(0,0,15)

const as ulong C_YL = cRGB(15,15,0)
const as ulong C_MG = cRGB(15,0,15)
const as ulong C_CY = cRGB(0,15,15)

const as ulong C_PK = cRGB(15,0,8)
const as ulong C_OR = cRGB(15,8,0)

const as ulong C_GY_4 = cRGB(4,4,4)
const as ulong C_GY_8 = cRGB(8,8,8)
const as ulong C_GY_12 = cRGB(12,12,12)
const as ulong C_RD_15 = cRGB(15,0,0)
const as ulong C_YE_15 = cRGB(15,15,0)
const as ulong C_MG_15 = cRGB(15,0,15)
const as ulong C_CY_15 = cRGB(0,15,15)
const as ulong C_GN_7 = cRGB(0,7,0)
const as ulong C_GN_11 = cRGB(0,11,0)
const as ulong C_BU_15 = cRGB(0,0,15)
