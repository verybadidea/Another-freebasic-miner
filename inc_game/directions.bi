enum DIRECTIONS_ENUM
	DIR_LE '0
	DIR_RI '1
	DIR_UP '2
	DIR_DN '3
end enum

type move_def_type
	dim as int2d dir_(0 to 3) = {int2d(0, -1), int2d(0, +1), int2d(+1, 0), int2d(-1, 0)}
	'~ dim as int2d ptr pLe = @dir_(0)
	'~ dim as int2d le = int2d(0, -1)
	'~ dim as int2d ri = int2d(0, +1)
	'~ dim as int2d up = int2d(+1, 0)
	'~ dim as int2d dn = int2d(-1, 0)
end type
