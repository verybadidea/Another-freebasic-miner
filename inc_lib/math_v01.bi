const as single M_PI = 3.141592654
const as single M_PI_2 = M_PI * 2
const as single M_PI_HALF = M_PI / 2
const as single M_RAD = 180 / M_PI

function rad2deg(radians as single) as single
	return radians * M_RAD
end function

function deg2rad(degrees as single) as single
	return degrees / M_RAD
end function
