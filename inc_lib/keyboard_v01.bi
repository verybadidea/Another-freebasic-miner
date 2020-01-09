type key_type
	dim as string label(0 to 127) = _
		{"", "ESCAPE", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "MINUS", "EQUALS", "BACKSPACE", _
		"TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "LEFTBRACKET", "RIGHTBRACKET", "ENTER", _
		"CONTROL", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SEMICOLON", "QUOTE", _
		"TILDE", "LSHIFT", "BACKSLASH", "Z", "X", "C", "V", "B", "N", "M", "COMMA", "PERIOD", "SLASH", "RSHIFT", _
		"MULTIPLY", "ALT", "SPACE", "CAPSLOCK", _
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", _
		"NUMLOCK", "SCROLLLOCK", "HOME", "UP", "PAGEUP", "", "LEFT", "", "RIGHT", "PLUS", "END", "DOWN", "PAGEDOWN", _
		"INSERT", "DELETE", "", "", "", "F11", "F12", "", "", "LWIN", "RWIN", "MENU"}
end type

'dim shared as key_type key

const as string KEY_UP = chr(255, 72) 'H
const as string KEY_DN = chr(255, 80) 'P
const as string KEY_LE = chr(255, 75) 'K
const as string KEY_RI = chr(255, 77) 'M
const as string KEY_BACK = chr(8)
const as string KEY_ENTER = chr(13)
const as string KEY_ESC = chr(27)
const as string KEY_SPACE = chr(32) '0x20
const as string KEY_BACK = chr(8)
const as string KEY_TAB = chr(9)
const as string KEY_W = chr(&h77) 'w
const as string KEY_A = chr(&h61) 'a
const as string KEY_S = chr(&h73) 's
const as string KEY_D = chr(&h64) 'd

function waitForKey() as string
	dim as string key = inkey
	while key = ""
		key = inkey
		sleep 1,1
	wend
	return key
end function

sub clearKeyBuffer()
	while inkey <> "": wend
end sub

#include once "fbgfx.bi"

'Class for extended multikey functionality
type multikey_type
	private:
		m_oldKey(127) as boolean
		m_newKey(127) as boolean
	public:
		declare function down(byval as long) as boolean
		declare function pressed(byval as long) as boolean
		declare function released(byval as long) as boolean
end type

'Returns whether a key is being held
function multikey_type.down(byval index as long) as boolean
	return cbool(multiKey(index))
end function

'Returns whether a key was pressed
function multikey_type.pressed(byval index as long) as boolean
	m_oldKey(index) = m_newKey(index)
	m_newKey(index) = cbool(multiKey(index))
	return (m_oldKey(index) = false) andalso (m_newKey(index) = true)
end function

'Returns whether a key was released
function multikey_type.released(byval index as long) as boolean
	m_oldKey(index) = m_newKey(index)
	m_newKey(index) = cbool(multiKey(index))
	return (m_oldKey(index) = true) andalso (m_newKey(index) = false)
end function
