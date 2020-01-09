type bitmap_header field = 1
	bfType          as ushort
	bfsize          as ulong
	bfReserved1     as ushort
	bfReserved2     as ushort
	bfOffBits       as ulong
	biSize          as ulong
	biWidth         as ulong
	biHeight        as ulong
	biPlanes        as ushort
	biBitCount      as ushort
	biCompression   as ulong
	biSizeImage     as ulong
	biXPelsPerMeter as ulong
	biYPelsPerMeter as ulong
	biClrUsed       as ulong
	biClrImportant  as ulong
end type
