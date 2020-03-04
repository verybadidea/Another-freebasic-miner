#include once "string.bi"

#include once "inc_lib/screen_v03.bi"
#include once "inc_lib/keyboard_v01.bi"
#include once "inc_lib/registered_key_02.bi"
#include once "inc_lib/image_v03.bi"
#include once "inc_lib/image_buffer_v03.bi"
#include once "inc_lib/string_func_v01.bi"
#include once "inc_lib/int2d_v02.bi"
#include once "inc_lib/sgl2d_v03.bi"
#include once "inc_lib/dbl2d_v03.bi"
#include once "inc_lib/int2d_flt2d_v01.bi"
#include once "inc_lib/logger_v01.bi"
#include once "inc_lib/event_timer_v01.bi"
#include once "inc_lib/loop_timer_v01.bi"
#include once "inc_lib/file_func_v02.bi"
#include once "inc_lib/font_v02.bi"
#include once "inc_lib/rnd_func_v01.bi"
'#include once "inc_lib/mouse_v01.bi"

'#define float single
'#define flt2d sgl2d
'#define toFlt2d toSgl2d

#define float double
#define flt2d dbl2d
#define toFlt2d toDbl2d

const SLEEP_MS = 1 'default 1 (max FPS), higher values for testing, e.g 15 (~60Hz), or 30 (~30Hz)
const GRID_SIZE_X = 64, GRID_HALF_X = GRID_SIZE_X \ 2
const GRID_SIZE_Y = 64, GRID_HALF_Y = GRID_SIZE_Y \ 2
const as float GRAVITY = 1000 'pixels/s^2

dim shared as screen_type scr = screen_type(800, 600, fb.GFX_ALPHA_PRIMITIVES) '1024, 768
dim shared as int2d screenBorder = scr.size \ 3 'pixels, move to player class?
dim shared as image_buffer_type imgBufAll
dim shared as font_type f1
dim shared as logger_type logger = logger_type("", 5, 1.0) 'gamelog.txt

#include once "inc_game/image_enum.bi"
#include once "inc_game/directions.bi"
#include once "inc_game/grid.bi"
#include once "inc_game/map.bi"
#include once "inc_game/anim.bi"
#include once "inc_game/player.bi"
#include once "inc_game/viewer.bi"

'-------------------------------------------------------------------------------

declare function main() as string

scr.activate() 'set screen
image_vert_align_default = IVA_CENTER
image_horz_align_default = IHA_CENTER
image_draw_mode_default = IDM_ALPHA

f1.manualTrim(4, 2, 4, 2)
f1.load("images/fonts/Berlin_sans32b.bmp", 16, 16)
f1.autoTrim()
f1.setProp(8, -2, FDM_ALPHA)

randomize 345 'timer

dim as string quitStr
logger.add("start main()")
quitStr = main()
logger.add(quitStr)
print quitStr
screenlock
scr.dimScreen(0.8)
screenunlock
sleep 10000
end

enum E_INPUT_STATE
	INPUT_PLAYER
	INPUT_VIEW_MODE
	INPUT_PAUSE_MENU
end enum

function loadImagesFromFile(dirName as string) as integer
	dim as integer numLoaded = imgBufAll.loadDir(dirName)
	if numLoaded <= 0 then return -1
	logger.add(dirName & " " & numLoaded)
	return 0
end function

function main() as string
	dim as player_type miner
	dim as viewer_type viewer
	dim as E_INPUT_STATE inputState = INPUT_PLAYER 'INPUT_VIEW_MODE
	dim as flt2d viewPosTl 'top-left

	dim as integer numLoaded = 0
	dim as string dirName

	if loadImagesFromFile("images/") <> 0 then return "Error: No actor images"
	if loadImagesFromFile("images/actor/") <> 0 then return "Error: No actor images"
	if loadImagesFromFile("images/tiles_bg/") <> 0 then return "Error: No background images"
	if loadImagesFromFile("images/tiles_fg/") <> 0 then return "Error: No foreground images"
	if loadImagesFromFile("images/overlay/") <> 0 then return "Error: No overlay images"
	logger.add("Total images loaded: " & imgBufAll.numImages)

	dim as map_type map
	map.alloc(int2d(300, 100))
	'map.setRandom()
	map.setNormal()
	
	dim as integer result = miner.init_()
	if result <> 0 then return "miner.init: " & result
	dim as int2d posMap = int2d(10 * GRID_SIZE_X, 0 * GRID_SIZE_Y) '= int2d((map.size.x * GRID_SIZE_X) \ 2, (map.size.y * GRID_SIZE_Y) \ 2)
	miner.reset_(map, posMap, scr.cntr)

	viewer.init_()
	viewer.reset_(posMap)

	dim as loop_timer_type loopTimer
	dim as integer quit = 0
	dim as string quitStr = "Quit, no reason"

	loopTimer.init()
	while quit = 0

		if inkey = KEY_ESC then quit = 1 : quitStr = "Quit, user abort request"

		select case inputState
		case INPUT_PLAYER
			miner.processKeyInput()
		case INPUT_VIEW_MODE
			viewer.processKeyInput()
		case else
		end select
		
		miner.update(loopTimer.getdt())
		viewer.update(loopTimer.getdt())
		map.update()

		select case inputState
		case INPUT_PLAYER
			viewPosTl = miner.posMap - miner.posScr
		case INPUT_VIEW_MODE
			viewPosTl = viewer.posMap
		case else
		end select

		screenlock
		
		scr.clearScreen(rgba(0, 0, 0, 255))
		map.draw_(viewPosTl)
		'locate 2,2: print loopTimer.getRunTime()
		'in-game logger
		line(0, scr.size.y - 1)-step(scr.size.x - 1, -logger.numEntries * 16), rgba(0, 0, 0, 127), bf
		for i as integer = 0 to logger.numEntries - 1
			draw string(2, (scr.size.y + 1) - (logger.numEntries - i) * 16), logger.entry(i), rgba(240, 224, 0, 255)
		next
		miner.draw_()
		'f1.printTextAk(scr.cntr.x, scr.cntr.y, "Lang verhaal hierzo: Bla bla", FHA_RIGHT)

		'scr.flipPage()
		screenunlock
		if miner.isDead() then quit = 1 : quitStr = "Quit, player died"

		sleep SLEEP_MS
		loopTimer.update()
		logger.updateClearTimer()
	wend
	return quitStr
end function
