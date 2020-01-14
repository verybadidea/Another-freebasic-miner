123

#include once "../../_code_lib_new_/screen_v03.bi"
#include once "../../_code_lib_new_/keyboard_v01.bi"
#include once "../../_code_lib_new_/image_v03.bi"
#include once "../../_code_lib_new_/image_buffer_v01.bi"
#include once "../../_code_lib_new_/string_v01.bi"
#include once "../../_code_lib_new_/int2d_v02.bi"
#include once "../../_code_lib_new_/sgl2d_v03.bi"
#include once "../../_code_lib_new_/dbl2d_v03.bi"
#include once "../../_code_lib_new_/event_timer_v01.bi"
#include once "../../_code_lib_new_/loop_timer_v01.bi"
#include once "../../_code_lib_new_/int2d_flt2d_v01.bi"
#include once "../../_code_lib_new_/file_func_v01.bi"
#include once "../../_code_lib_new_/logger_v01.bi"
#include once "../../_code_lib_new_/font_v02.bi"
'#include once "../../_code_lib_new_/mouse_v01.bi"

'~ #include once "inc_lib/screen_v03.bi"
'~ #include once "inc_lib/keyboard_v01.bi"
'~ #include once "inc_lib/image_v03.bi"
'~ #include once "inc_lib/image_buffer_v01.bi"
'~ #include once "inc_lib/string_v01.bi"
'~ #include once "inc_lib/int2d_v02.bi"
'~ #include once "inc_lib/sgl2d_v03.bi"
'~ #include once "inc_lib/dbl2d_v03.bi"
'~ #include once "inc_lib/event_timer_v01.bi"
'~ #include once "inc_lib/loop_timer_v01.bi"
'~ #include once "inc_lib/int2d_flt2d_v01.bi"
'~ #include once "inc_lib/file_func_v01.bi"
'~ #include once "inc_lib/logger_v01.bi"
'~ #include once "inc_lib/mouse_v01.bi"

'#define float single
'#define flt2d sgl2d
'#define toFlt2d toSgl2d

#define float double
#define flt2d dbl2d
#define toFlt2d toDbl2d

const SLEEP_MS = 1 'default 1 (max FPS), higher values for testing, e.g 15 (~60Hz), or 50 (~20Hz)
const GRID_SIZE_X = 64, GRID_HALF_X = GRID_SIZE_X \ 2
const GRID_SIZE_Y = 64, GRID_HALF_Y = GRID_SIZE_Y \ 2
const as float GRAVITY = 1000 'pixels/s^2

dim shared as screen_type scr = screen_type(800, 600, fb.GFX_ALPHA_PRIMITIVES) '1024, 768
dim shared as int2d screenBorder = scr.size \ 3 'pixels
dim shared as logger_type logger = logger_type("", 5, 1.0) 'gamelog.txt
dim shared as image_buffer_type imgBufBg 'image buffer background tiles
dim shared as image_buffer_type imgBufFg 'image buffer foreground tiles / overlay objects
dim shared as image_buffer_type imgBufAct 'image buffer actor / miner
dim shared as image_buffer_type imgBufOl 'image buffer GUI overlay
dim shared as font_type f1

#include once "inc_game/image_enum.bi"
#include once "inc_game/grid.bi"
#include once "inc_game/map.bi"
#include once "inc_game/anim.bi"
#include once "inc_game/player.bi"

'-------------------------------------------------------------------------------

function rndRange(first as integer, last as integer) as integer
	return int((1 + last - first) * rnd) + first
end function

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
screenlock
scr.dimScreen(0.8)
screenunlock
sleep 1000
end

enum E_INPUT_STATE
	INPUT_PLAYER
	INPUT_PAUSE_MENU
end enum

function main() as string
	dim as player_type miner
	dim as E_INPUT_STATE inputState = INPUT_PLAYER

	if imgBufBg.loadDir("images/tiles_bg/") <> 0 then return "imgBufBg.loadDir(images/tiles_bg/) <> 0"
	logger.add("Background images loaded: " & imgBufBg.numImages)
	if imgBufFg.loadDir("images/tiles_fg/") <> 0 then return "imgBufFg.loadDir(images/tiles_fg/) <> 0"
	logger.add("Foreground images loaded: " & imgBufFg.numImages)
	if imgBufAct.loadDir("images/actor/") <> 0 then return "imgBufAct.loadDir(images/actor/) <> 0"
	logger.add("Actor images loaded: " & imgBufAct.numImages)
	if imgBufOl.loadDir("images/overlay/") <> 0 then return "imgBufOl.loadDir(images/overlay/) <> 0"
	logger.add("Overlay images loaded: " & imgBufOl.numImages)

	dim as map_type map
	map.alloc(int2d(20, 30))
	'map.setRandomImages(imgBufBg, imgBufFg)

	'setup a simple ramdom map
	for yi as integer = 0 to map.size.y - 1
		for xi as integer = 0 to map.size.x - 1
			if (xi = 0) or (xi = map.size.x - 1) then
				'set left/right hard borders
				map.setTile(int2d(xi, yi), 0, @imgBufBg.image(bg_border), IS_SOLID)
			else
				if yi <> 0 then 'no bg image on top tow
					if yi = 1 then 'second row grass
						map.setTile(int2d(xi, yi), 0, @imgBufBg.image(rndRange(bg_surface_1, bg_surface_3)), IS_SOLID)
					else
						map.setTile(int2d(xi, yi), 0, @imgBufBg.image(rndRange(bg_earth_0, bg_earth_3)), IS_SOLID)
					end if
					if rnd < 0.2 then 'random gaps
						map.setTile(int2d(xi, yi), 0, @imgBufBg.image(bg_shadow), 0)
					end if
					if rnd < 0.4 then 'random ladder
						map.setTile(int2d(xi, yi), @imgBufFg.image(fg_construction_ladder), @imgBufBg.image(bg_shadow), IS_CLIMB)
					end if
				end if
			end if
		next
	next

	dim as integer result = miner.init_()
	if result <> 0 then return "miner.init: " & result
	dim as int2d posMap = int2d(10 * GRID_SIZE_X, 0 * GRID_SIZE_Y) '= int2d((map.size.x * GRID_SIZE_X) \ 2, (map.size.y * GRID_SIZE_Y) \ 2)
	miner.reset_(map, posMap, scr.cntr)

	dim as loop_timer_type loopTimer
	dim as integer quit = 0
	dim as string quitStr = "Quit, no reason"

	loopTimer.init()
	while quit = 0

		if inkey = KEY_ESC then quit = 1 : quitStr = "Quit, user abort request"

		select case inputState
		case INPUT_PLAYER
			miner.processKeyInput()
		case else
		end select
		
		miner.update(loopTimer.getdt())

		screenlock
		
		scr.clearScreen(rgba(0, 0, 0, 255))
		map.draw_(miner.posMap - miner.posScr)
		'locate 2,2: print loopTimer.getRunTime()
		locate 1,1: print miner.getStateStr()
		dim as int2d playerGrid = getGridPos(miner.posMap)
		locate 2,1: print playerGrid
		'highlight target tile
		if map.validPos(miner.targetGridPos) then
			dim as int2d tileScrPos = getScrPos(miner.targetGridPos, miner.posMap - miner.posScr)
			line(tileScrPos.x - GRID_HALF_X - 1, tileScrPos.y - GRID_HALF_Y - 1)-step(GRID_SIZE_X, GRID_SIZE_Y), rgba(255, 255, 255, 255), b, &b1010101010101010
		end if
		miner.draw_()

		line(0, scr.size.y - 1)-step(scr.size.x - 1, -logger.numEntries * 16), rgba(0, 0, 0, 127), bf
		for i as integer = 0 to logger.numEntries - 1
			draw string(2, (scr.size.y + 1) - (logger.numEntries - i) * 16), logger.entry(i), rgba(240, 224, 0, 255)
		next
		line(scr.edge.x - 86, scr.edge.y - 86)-step(63 + 12, 63 + 12), rgba(127,127,127,255), b
		line(scr.edge.x - 85, scr.edge.y - 85)-step(63 + 10, 63 + 10), rgba(63,63,63,255), b
		line(scr.edge.x - 84, scr.edge.y - 84)-step(63 + 8, 63 + 8), rgba(0,0,0,127), bf
		imgBufFg.image(fg_construction_ladder).drawxym(scr.edge.x - 80, scr.edge.y - 80, IHA_LEFT, IVA_TOP, IDM_ALPHA)
		f1.printTextAk(scr.edge.x - 80 + 64, scr.edge.y - 90 + 50, str(miner.numLadders), FHA_RIGHT)
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

'-------------------------------------------------------------------------------

'todo
' ladders: show amount available
' break stuff
' plants, flowers
' invertory
' use player size struct, AABB? note: height not centered with tile
' fix size of images? 66x66 ?
' build stuff
' shovel action
' make map shared?
' map load/save
' map editor
' clean up image.bi : alignment struct
' font.bi : change pTrim to struct, and use redim
' font.bi : add vert align
' ladders build animation
' mouse cursor, aiming direction
' sky tiles?
' ladder bridge issue (climbing vs walking, in font of / behind ladder)
' loop world left-right
' item menu
' elevator
' lighting
' plant animations
' growing trees/fruit plants
' enemies
' day/night
' item conversion and crafting
' check 0_plans_todo_ideas_0

'dont
' mapPos: dived by grid size?

'done
' animation class
' start fall speed + incremental fall speed + max fall speed?
' bug: wall climbing (when when falling from ladder)
' function: update player position, call after state handling, posChange as flt2d
' falling animation
' add falling state, use falling accelleration in this state
' ladder message: cannot build there, no more ladders
' display action location
' fall damage, health bar
' miner variables to const
' make image buffers shared

'-------------------------------------------------------------------------------

'mogrify -verbose -format bmp *.png
'rm *.png
'convert -verbose test.bmp -crop 64x64+1+1 test.bmp
'mogrify -verbose -crop 64x64+1+1 *.bmp
'healthbar:
'convert -verbose -crop 120x16+37+108 test.bmp test2.bmp
'mogrify -verbose -crop 120x16+37+108 *.bmp

'-------------------------------------------------------------------------------

