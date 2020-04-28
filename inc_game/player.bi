type tool_type
	dim as short imgId
	dim as short amount
end type

enum E_MINER_TOOL
	TOOL_LADDER
	TOOl_SABER
	TOOl_PICK
	TOOl_DRILL
	TOOL_SPADE
	TOOL_JETPACK
	TOOl_CARROT_SEED
	TOOl_GRAPE_SEED
	TOOl_TOMATO_SEED
	TOOL_INVALID
end enum

dim shared as tool_type tool(TOOL_INVALID - 1) = {_
	(ol_item_ladder, 20), _
	(ol_item_saber, 1), _
	(ol_item_pick, 1), _
	(ol_item_drill, 1), _
	(ol_item_spade, 1), _
	(ol_item_jetpack, 0), _
	(ol_item_seed_carrot, 10), _
	(ol_item_seed_grape, 10), _
	(ol_item_seed_tomato, 10)}

'-------------------------------------------------------------------------------

const NUM_IMG_WALK = 4
const NUM_IMG_WINK = 4
const NUM_IMG_CLIMB = 4
const NUM_IMG_FALL = 2
const NUM_IMG_HEALTH = 9
const NUM_IMG_PICK = 2
const NUM_IMG_SPADE = 2
const NUM_IMG_DRILL_SIDE = 2
const NUM_IMG_DRILL_DOWN = 2
const NUM_IMG_DRILL_UP = 2

const FRAME_TIME_PICK = 0.15
const FRAME_TIME_DRILL = 0.10
const FRAME_TIME_SPADE = 0.15
const FRAME_TIME_IDLE = 0.10
const FRAME_TIME_WALK = 0.15
const FRAME_TIME_FALL = 0.15
const FRAME_TIME_CLIMB = 0.10

enum E_MINER_KEY
	RKEY_NONE '0 = invalid key
	RKEY_LEFT '1
	RKEY_RIGHT '2
	RKEY_UP '3
	RKEY_DOWN '4
	RKEY_PAGEUP '5
	RKEY_PAGEDOWN '6
	RKEY_SPACE '7
	RKEY_TAB '7
	'RKEY_NULL '9 = list terminator
end enum

enum E_MINER_STATE
	MINER_NONE '0
	MINER_IDLE '1
	MINER_WALK_LEFT '2
	MINER_WALK_RIGHT '3
	MINER_STAND_LEFT '4
	MINER_STAND_RIGHT '5
	MINER_CLIMB_UP '6
	MINER_CLIMB_DOWN '7
	MINER_CLIMB_STOP '8
	'MINER_BUSY '
	MINER_FALL '
	MINER_DEAD '
end enum

const as integer MINER_MAX_HEALTH = NUM_IMG_HEALTH - 1
const as integer MINER_HALF_WIDTH = 16 'pixels
const as integer MINER_LADDER_DIST = 18 'pixels
const as integer MINER_FEET_DIST = 32 'pixels
const as integer MINER_HAED_DIST = 24 'pixels
const as float MINER_WALK_SPEED = 150 'pixels/s
const as float MINER_CLIMB_SPEED = 75 'pixels/s
const as float MINER_MAX_FALL_SPEED = 400 'pixels/s
const as float MINER_MIN_FALL_DIST = 3 'pixels

type player_type
	public:
	dim as flt2d posMap 'position in map / world [pixels]
	dim as flt2d posScr 'position on screen [pixels]
	private:
	dim as registered_key rkey
	dim as map_type ptr pMap
	dim as flower_type ptr pFlower
	dim as image_type ptr pImg 'current image to display
	dim as inventory_type ptr pInv
	dim as collect_list ptr pCollectList
	dim as plant_grow_list ptr pPlGrowList
	dim as boolean showInv = TRUE
	dim as int2d requestDir
	dim as int2d currentGridPos
	dim as int2d markerGridPos
	dim as int2d actionGridPos
	dim as integer state, lastState 'prevState
	dim as integer health
	'dim as integer numLadders = 10
	dim as integer selectedTool, actionTool 'remember when action timer has ended
	dim as integer requestedAction
	dim as float fallSpeed = 0 'pixels/s
	dim as timer_type idleWaitTmr, actionTmr
	dim as anim_type anim
	dim as image_type imgWalk(0 to 1, NUM_IMG_WALK-1)
	dim as image_type imgWink(NUM_IMG_WINK-1)
	dim as image_type imgClimb(NUM_IMG_CLIMB-1)
	dim as image_type imgFall(NUM_IMG_FALL-1)
	dim as image_type imgHealth(NUM_IMG_HEALTH-1)
	dim as image_type imgPick(0 to 1, NUM_IMG_PICK-1)
	dim as image_type imgSpade(0 to 1, NUM_IMG_SPADE-1)
	dim as image_type imgDrillSide(0 to 1, NUM_IMG_DRILL_SIDE-1)
	dim as image_type imgDrillDown(NUM_IMG_DRILL_DOWN-1)
	dim as image_type imgDrillUp(NUM_IMG_DRILL_UP-1)
	dim as image_type imgDead
	public:
	declare function init(byref flower as flower_type, _
		byref inv as inventory_type, byref collectList as collect_list, _
		byref plGrowList as plant_grow_list) as integer
	declare sub reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	declare function loadImg() as integer
	declare sub setKeys()
	declare sub processKeyInput()
	declare sub processMouseInput()
	declare sub update(dt as double) 'update state
	declare sub updatePos(posChange as flt2d) 'update position
	declare sub updateAction()
	declare sub tryAction()
	declare sub tryWalk(xChangeReq as float, byref posChangeAct as flt2d)
	declare sub tryClimb(yChangeReq as float, byref posChangeAct as flt2d)
	declare sub tryFall(dt as double, byref posChangeAct as flt2d)
	declare function isDead() as boolean
	declare function isStanding(checkState as integer) as boolean
	declare function isWalking(checkState as integer) as boolean
	declare function isClimbing(checkState as integer) as boolean
	declare function getStateStr() as string
	declare sub draw_()
end type

'copy from image buffer
function player_type.init(byref flower as flower_type, _
	byref inv as inventory_type, byref collectList as collect_list, _
	byref plGrowList as plant_grow_list) as integer
	if loadImg() <> 0 then return -1
	anim.init(pImg) 'tell the anim class where the player image is
	setKeys() 'assing keys
	pFlower = @flower
	pInv = @inv
	pCollectList = @collectList
	pPlGrowList = @plGrowList
	return 0
end function

sub player_type.reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	pMap = @map
	this.posMap = toFlt2d(posMap + int2d(0, -00)) '1 pixel higer ???
	this.posScr = toFlt2d(posScr + int2d(0, -00)) '1 pixel higer ???
	state = MINER_NONE
	pImg = @imgWink(0)
	health = MINER_MAX_HEALTH
	selectedTool = TOOL_DRILL
	requestedAction = -1
	requestDir = int2d(0, -1) 'set off-screen
	markerGridPos = int2d(-1, -1) 'set invalid pos
end sub

function player_type.loadImg() as integer
	for i as integer = 0 to NUM_IMG_WINK - 1
		if imgBufAll.validImage(act_wink_1 + i) = false then return -1
		imgBufAll.image(act_wink_1 + i).copyTo(imgWink(i))
	next
	for i as integer = 0 to NUM_IMG_WALK - 1
		if imgBufAll.validImage(act_walk_1 + i) = false then return -2
		imgBufAll.image(act_walk_1 + i).copyTo(imgWalk(DIR_LE, i))
		imgBufAll.image(act_walk_1 + i).hFlipTo(imgWalk(DIR_RI, i))
	next
	for i as integer = 0 to NUM_IMG_CLIMB - 1
		if imgBufAll.validImage(act_climb_1 + i) = false then return -3
		imgBufAll.image(act_climb_1 + i).copyTo(imgClimb(i))
	next
	for i as integer = 0 to NUM_IMG_FALL - 1
		if imgBufAll.validImage(act_fall_1 + i) = false then return -4
		imgBufAll.image(act_fall_1 + i).copyTo(imgFall(i))
	next
	for i as integer = 0 to NUM_IMG_PICK - 1
		if imgBufAll.validImage(act_pick_1 + i) = false then return -5
		imgBufAll.image(act_pick_1 + i).copyTo(imgPick(DIR_LE, i))
		imgBufAll.image(act_pick_1 + i).hFlipTo(imgPick(DIR_RI, i))
	next
	for i as integer = 0 to NUM_IMG_SPADE - 1
		if imgBufAll.validImage(act_dig_1 + i) = false then return -5
		imgBufAll.image(act_dig_1 + i).copyTo(imgSpade(DIR_LE, i))
		imgBufAll.image(act_dig_1 + i).hFlipTo(imgSpade(DIR_RI, i))
	next
	for i as integer = 0 to NUM_IMG_DRILL_SIDE - 1
		if imgBufAll.validImage(act_drill_1 + i) = false then return -6
		imgBufAll.image(act_drill_1 + i).copyTo(imgDrillSide(DIR_LE, i))
		imgBufAll.image(act_drill_1 + i).hFlipTo(imgDrillSide(DIR_RI, i))
	next
	for i as integer = 0 to NUM_IMG_DRILL_DOWN - 1
		if imgBufAll.validImage(act_drill_down_1 + i) = false then return -6
		imgBufAll.image(act_drill_down_1 + i).copyTo(imgDrillDown(i))
	next
	for i as integer = 0 to NUM_IMG_DRILL_UP - 1
		if imgBufAll.validImage(act_drill_up_1 + i) = false then return -6
		imgBufAll.image(act_drill_up_1 + i).copyTo(imgDrillUp(i))
	next
	if imgBufAll.validImage(act_dead) = false then return -9
	imgBufAll.image(act_dead).copyTo(imgDead)
	'healthbar
	for i as integer = 0 to NUM_IMG_HEALTH - 1
		if imgBufAll.validImage(ol_health_0 + i) = false then return -10
		imgBufAll.image(ol_health_0 + i).copyTo(imgHealth(i))
	next
	return 0
end function

sub player_type.setKeys()
	rkey.add(FB.SC_LEFT)
	rkey.add(FB.SC_RIGHT)
	rkey.add(FB.SC_UP)
	rkey.add(FB.SC_DOWN)
	rkey.add(FB.SC_PAGEDOWN)
	rkey.add(FB.SC_PAGEUP)
	rkey.add(FB.SC_SPACE)
	rkey.add(FB.SC_TAB)
end sub

sub player_type.processKeyInput()
	lastState = state
	'allow x and y state?
	'walk left or stop
	if rkey.isDown(RKEY_LEFT) then
		requestDir = int2d(-1, 0)
		state = MINER_WALK_LEFT 'request left
	else
		if lastState = MINER_WALK_LEFT then state = MINER_STAND_LEFT
	end if
	'walk right or stop
	if rkey.isDown(RKEY_RIGHT) then
		requestDir = int2d(+1, 0)
		state = MINER_WALK_RIGHT 'request right
	else
		if lastState = MINER_WALK_RIGHT then state = MINER_STAND_RIGHT
	end if
	'climb up or stop
	if rkey.isDown(RKEY_UP) then
		requestDir = int2d(0, -1)
		state = MINER_CLIMB_UP 'request
	else
		if lastState = MINER_CLIMB_UP then state = MINER_CLIMB_STOP
	end if
	'climb down or stop
	if rkey.isDown(RKEY_DOWN) then
		requestDir = int2d(0, +1)
		state = MINER_CLIMB_DOWN 'request
	else
		if lastState = MINER_CLIMB_DOWN then state = MINER_CLIMB_STOP
	end if
	if rkey.isPressed(RKEY_PAGEDOWN) then
		'anim.stop_(@imgWink(0))
		idleWaitTmr.start(5.0)
		selectedTool += 1
		if selectedTool >= TOOL_INVALID then selectedTool = 0 'first tool
		'logger.add("Selected tool: " & selectedTool)
	end if
	if rkey.isPressed(RKEY_PAGEUP) then
		'anim.stop_(@imgWink(0))
		idleWaitTmr.start(5.0)
		selectedTool -= 1
		if selectedTool < 0 then selectedTool = TOOL_INVALID - 1 'last tool
		'logger.add("Selected tool: " & selectedTool)
	end if
	'start tool
	if rkey.isPressed(RKEY_SPACE) then
		requestedAction = selectedTool
		'logger.add("start action")
		idleWaitTmr.start(5.0)
	end if
	'stop tool
	if rkey.isReleased(RKEY_SPACE) then
		requestedAction = -1
		'logger.add("stop action")
		idleWaitTmr.start(5.0)
	end if
	'showInv = rkey.isDown(RKEY_TAB)
	if rkey.isPressed(RKEY_TAB) then
		showInv = (not showInv)
	end if
	rkey.updateState() 'very important
end sub

sub player_type.processMouseInput()
	'dim as mousetype mouse
	'dim as integer mouseEvent
	'mouseEvent = handleMouse(mouse)
end sub

'update position & state
sub player_type.update(dt as double)
	dim as flt2d posChange = flt2d(0, 0) 'pixels
	select case state
	case MINER_NONE
		'triggers idle timer below (next loop), after initial state
		state = MINER_IDLE
	case MINER_WALK_LEFT
		tryWalk(-MINER_WALK_SPEED * dt, posChange) 'can set MINER_STAND_LEFT
	case MINER_WALK_RIGHT
		tryWalk(+MINER_WALK_SPEED * dt, posChange) 'can set MINER_STAND_RIGHT
	case MINER_CLIMB_UP
		tryClimb(-MINER_CLIMB_SPEED * dt, posChange) 'can set MINER_CLIMB_STOP or MINER_IDLE
	case MINER_CLIMB_DOWN
		tryClimb(+MINER_CLIMB_SPEED * dt, posChange) 'can set MINER_CLIMB_STOP or MINER_IDLE
	case MINER_CLIMB_STOP
	case MINER_STAND_LEFT
		if idleWaitTmr.ended() then state = MINER_IDLE
	case MINER_STAND_RIGHT
		if idleWaitTmr.ended() then state = MINER_IDLE
	case MINER_IDLE
		if idleWaitTmr.ended() then
			anim.start(@imgWink(0), NUM_IMG_WINK, 2, FRAME_TIME_IDLE) 'start idle animation 
			idleWaitTmr.start(5.0 + rnd * 10.0) 'restart wait
		end if
	end select

	'needs to be after previous select case
	if isClimbing(state) = FALSE then tryFall(dt, posChange)

	'update posMap, posScr, curentGridPos, targetGridPos
	updatePos(posChange)

	tryAction()
	updateAction()
	
	'start/stop animations/timers on state change
	if state <> lastState then
		'leaving state
		select case lastState
		case MINER_IDLE, MINER_STAND_LEFT, MINER_STAND_RIGHT
		case else
			idleWaitTmr.stop_()
		end select
		'entering state, start/stop animation
		select case state
		case MINER_IDLE
			anim.stop_(@imgWink(0))
			idleWaitTmr.start(5.0)
		case MINER_WALK_LEFT
			anim.start(@imgWalk(DIR_LE, 0), NUM_IMG_WALK, -1, FRAME_TIME_WALK)
		case MINER_WALK_RIGHT
			anim.start(@imgWalk(DIR_RI, 0), NUM_IMG_WALK, -1, FRAME_TIME_WALK)
		case MINER_STAND_LEFT
			anim.stop_(@imgWalk(DIR_LE, 0))
			idleWaitTmr.start(5.0) 
		case MINER_STAND_RIGHT
			anim.stop_(@imgWalk(DIR_RI, 0))
			idleWaitTmr.start(5.0) 
		case MINER_CLIMB_UP
			anim.start(@imgClimb(0), NUM_IMG_CLIMB, -1, FRAME_TIME_CLIMB)
		case MINER_CLIMB_DOWN
			anim.start(@imgClimb(0), NUM_IMG_CLIMB, -1, FRAME_TIME_CLIMB)
		case MINER_CLIMB_STOP
			'animStop(0)
			anim.stop_(@imgClimb(0))
		case MINER_FALL
			anim.start(@imgFall(0), NUM_IMG_FALL, -1, FRAME_TIME_FALL)
		case MINER_DEAD
			anim.stop_(@imgDead)
		end select
	end if

	anim.update(dt)

end sub

sub player_type.updatePos(posChange as flt2d)
	posMap += posChange
	posScr += posChange
	currentGridPos = getGridPos(posMap)
	'keep player somewhat centered on screen
	if posScr.x < screenBorder.x then posScr.x = screenBorder.x
	if posScr.x > scr.edge.x - screenBorder.x then posScr.x = scr.edge.x - screenBorder.x
	if posScr.y < screenBorder.y then posScr.y = screenBorder.y
	if posScr.y > scr.edge.y - screenBorder.y then posScr.y = scr.edge.y - screenBorder.y
	'determine targetGridPos
	select case state
	case MINER_IDLE, MINER_STAND_LEFT, MINER_STAND_RIGHT, MINER_CLIMB_STOP
		markerGridPos = currentGridPos + requestDir
		if abs(markerGridPos.x * GRID_SIZE_X - posMap.x) > (GRID_SIZE_X + 10) or _
			abs(markerGridPos.y * GRID_SIZE_Y - posMap.y) > (GRID_SIZE_Y + 10) then
			'too far away, set current position
			markerGridPos = currentGridPos
		end if
	case else
		markerGridPos = int2d(-1, -1) 'invalid position
	end select
end sub

sub player_type.updateAction()
	'pick axe action done
	if actionTmr.ended() then
		dim as integer bgImgId = iif(markerGridPos.y = 0, -1, bg_shadow)
		if pMap->validPos(actionGridPos) = false then
			logger.add("player_type.updateAction(): Fatal error")
		end if
		pMap->tile(actionGridPos).health -= 1
		'remove tile
		if pMap->tile(actionGridPos).health <= 0 then
			requestedAction = -1 'reset action
			'check if resource
			if pMap->tile(actionGridPos).flags and IS_RESOURCE then
				dim as short fgId = pMap->tile(actionGridPos).fgId
				'logger.add("Resource found: " & pRes->resId(fgId))
				dim as flt2d actionMapPos = flt2d(actionGridPos.x * GRID_SIZE_X, actionGridPos.y * GRID_SIZE_Y)
				pCollectList->add(actionMapPos, fgId)
			end if
			'clear tile
			pMap->tile(actionGridPos).set(0, bgImgId, IS_EMPTY)
			'check flower above & remove
			dim as int2d aboveGridPos = actionGridPos + int2d(0, -1)
			if pMap->validPos(aboveGridPos) then
				if (pMap->tile(aboveGridPos).flags and IS_FLOWER) then
					pMap->tile(aboveGridPos).set(0, -1, IS_EMPTY)
					pFlower->resetSpawnTimer()
				end if
			end if
		end if
		dim as integer standDir = iif(requestDir.x < 0, DIR_LE, DIR_RI)
		anim.stop_(@imgWalk(standDir, 0))
	end if
end sub

sub player_type.tryAction() 'perform action
	if pMap->validPos(markerGridPos) then
		select case requestedAction
		case TOOL_LADDER
			if (pMap->tile(markerGridPos).flags and (IS_SOLID or IS_CLIMB)) = 0 then
				'if numLadders > 0 then
				if tool(TOOL_LADDER).amount > 0 then
					'numLadders -= 1
					tool(TOOL_LADDER).amount -= 1
					dim as integer bgImgId = iif(markerGridPos.y = 0, -1, bg_shadow)
					pMap->tile(markerGridPos).set(fg_construction_ladder, bgImgId, IS_CLIMB, 1)
				end if
			end if
		case TOOL_PICK
			if requestDir.y = 0 then 'left or right only, not up or down
				if actionTmr.isActive = false then
					if (pMap->tile(markerGridPos).flags and (IS_EMPTY or IS_FIXED)) = 0 then
						dim as integer pickDir = iif(requestDir.x < 0, DIR_LE, DIR_RI)
						anim.start(@imgPick(pickDir, 0), NUM_IMG_PICK, 1, FRAME_TIME_PICK)
						actionTmr.start(NUM_IMG_PICK * FRAME_TIME_PICK) '2 * 0.15
						actionGridPos = markerGridPos
						actionTool = requestedAction
					end if
				end if
			end if
		case TOOL_DRILL
			if actionTmr.isActive = false then
				select case state
				case MINER_IDLE, MINER_STAND_LEFT, MINER_STAND_RIGHT
					if (pMap->tile(markerGridPos).flags and (IS_EMPTY or IS_FIXED)) = 0 then
						select case requestDir.y
						case 0 'left or right
							dim as integer drillDir = iif(requestDir.x < 0, DIR_LE, DIR_RI)
							anim.start(@imgDrillSide(drillDir, 0), NUM_IMG_DRILL_SIDE, 1, FRAME_TIME_DRILL)
							actionTmr.start(NUM_IMG_DRILL_SIDE * FRAME_TIME_DRILL) '2 * 0.10
						case -1 'up
							anim.start(@imgDrillUp(0), NUM_IMG_DRILL_UP, 1, FRAME_TIME_DRILL)
							actionTmr.start(NUM_IMG_DRILL_UP * FRAME_TIME_DRILL) '2 * 0.10
						case +1 'down
							anim.start(@imgDrillDown(0), NUM_IMG_DRILL_DOWN, 1, FRAME_TIME_DRILL)
							actionTmr.start(NUM_IMG_DRILL_DOWN * FRAME_TIME_DRILL) '2 * 0.10
						end select
						actionGridPos = markerGridPos
						actionTool = requestedAction
					end if
				case else
					'no drilling while climbing, falling or walking
				end select
			end if
		case TOOl_CARROT_SEED '3
			if tool(selectedTool).amount > 0 then
				if (pMap->tile(markerGridPos).flags and IS_EMPTY) then
					if (pMap->tile(markerGridPos + int2d(0, 1)).flags and IS_SOLID) then
						pMap->tile(markerGridPos).set(plant(PL_CARROT).fistImgId, 0, IS_PLANT, 1)
						tool(selectedTool).amount -= 1
						pPlGrowList->add(markerGridPos, PL_CARROT)
					end if
				end if
			else
				logger.add("No more carrot seed")
			end if
		case TOOl_GRAPE_SEED '4
		case TOOl_TOMATO_SEED '5
		case else
			'logger.add("Invalid action")
		end select
	end if
end sub

sub player_type.tryWalk(xChangeReq as float, byref posChangeAct as flt2d)
	dim as integer playerEdgeOffset = iif(xChangeReq < 0, -MINER_HALF_WIDTH, +MINER_HALF_WIDTH) 'left or right side of payer
	dim as integer tileEgdeOffset = iif(xChangeReq < 0, +GRID_HALF_X, -GRID_HALF_X) 'right or left side of tile
	dim as int2d targetGridPosHead = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y - MINER_HAED_DIST + 1)
	dim as int2d targetGridPosFeet = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y + MINER_FEET_DIST - 1)
	if (pMap->tile(targetGridPosHead).flags and IS_SOLID) or (pMap->tile(targetGridPosFeet).flags and IS_SOLID) then
		dim as float xPosChangeHead = (targetGridPosHead.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		dim as float xPosChangeFeet = (targetGridPosfeet.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		posChangeAct.x = iif(abs(xPosChangeHead) < abs(xPosChangeFeet), xPosChangeHead, xPosChangeFeet) '-5 > -3 ? no, ret -3
		state = iif(xChangeReq < 0, MINER_STAND_LEFT, MINER_STAND_RIGHT)
		'logger.add("cannot walk there, something in the way")
	else
		posChangeAct.x = xChangeReq
		state = iif(xChangeReq < 0, MINER_WALK_LEFT, MINER_WALK_RIGHT)
	end if
end sub

'can climb?
'	near ladder?
'		can climb target?
'			change y
'			snap x to ladder
'			CLIMBING UP/DOWN
'		else:
'			lastState = CLIMBING?
'				change y (limited)
'				CLIMBING STOP
'			else:
'				IDLE
'	else:
'		IDLE
'else:
'	IDLE

sub player_type.tryClimb(yChangeReq as float, byref posChangeAct as flt2d)
	dim as integer playerEdgeOffset = iif(yChangeReq < 0, -MINER_HAED_DIST, +MINER_FEET_DIST)
	dim as integer tileEgdeOffset = iif(yChangeReq < 0, +GRID_HALF_Y, -GRID_HALF_Y)
	'can climb? (check current tile can be climbed)
	if pMap->tile(currentGridPos).flags and IS_CLIMB then
		'near ladder? (check not to far from ladder)
		dim as int2d tileScrPos = getScrPos(currentGridPos, posMap - posScr)
		if abs(tileScrPos.x - posScr.x) < MINER_LADDER_DIST then
			'can climb target? (check target position can be climbed)
			dim as int2d targetGridPos = getGridPosXY(posMap.x, posMap.y + playerEdgeOffset + yChangeReq)
			if (pMap->validPos(targetGridPos) = TRUE) andalso ((pMap->tile(targetGridPos).flags and IS_CLIMB) = IS_CLIMB) then
				posChangeAct.y = yChangeReq
				'snap to center of ladder
				posChangeAct.x = (targetGridPos.x * GRID_SIZE_X) - posMap.x
				state = iif(yChangeReq < 0, MINER_CLIMB_UP, MINER_CLIMB_DOWN)
			else
				if isClimbing(lastState) then 
					'logger.add("cannot climb, end of ladder")
					posChangeAct.y = (targetGridPos.y * GRID_SIZE_Y + tileEgdeOffset) - (posMap.y + playerEdgeOffset)
					state = MINER_CLIMB_STOP
				else
					state = MINER_IDLE
				end if
			end if
		else
			'logger.add("cannot climb, too far from ladder")
			state  = MINER_IDLE
		end if
	else
		'logger.add("cannot climb, no ladder at current tile")
		state  = MINER_IDLE
	end if
end sub

sub player_type.tryFall(dt as double, byref posChangeAct as flt2d)
	dim as float fallDist = iif(GRAVITY * dt > MINER_MIN_FALL_DIST, GRAVITY * dt, MINER_MIN_FALL_DIST)
	dim as int2d targetGridPosLefoot = getGridPosXY(posMap.x - MINER_HALF_WIDTH + 1, posMap.y + MINER_FEET_DIST + fallDist)
	dim as int2d targetGridPosRifoot = getGridPosXY(posMap.x + MINER_HALF_WIDTH - 1, posMap.y + MINER_FEET_DIST + fallDist)
	'nothing solid below both feet?
	if (pMap->tile(targetGridPosLefoot).flags and IS_SOLID) = 0 and (pMap->tile(targetGridPosRifoot).flags and IS_SOLID) = 0 then
		if lastState <> MINER_FALL then 'needs to check against lastState, state already changed by e.g. tryWalk
			'logger.add("start falling")
			fallSpeed = 0.0
		else
			'logger.add("still falling")
			fallSpeed += GRAVITY * dt
			if fallSpeed > MINER_MAX_FALL_SPEED then fallSpeed = MINER_MAX_FALL_SPEED
		end if
		state = MINER_FALL
		posChangeAct.y += fallSpeed * dt
	else 'small correction, touch floor
		'logger.add("small correction")
		dim as float yPosChangeLeFoot = (targetGridPosLefoot.y * GRID_SIZE_Y - GRID_HALF_Y) - (posMap.y + MINER_FEET_DIST)
		dim as float yPosChangeRiFoot = (targetGridPosRifoot.y * GRID_SIZE_Y - GRID_HALF_Y) - (posMap.y + MINER_FEET_DIST)
		'get smallest distance, remember down = positive y-direction
		posChangeAct.y += iif(yPosChangeLeFoot < yPosChangeRiFoot, yPosChangeLeFoot, yPosChangeRiFoot)
		if state = MINER_FALL then
			state = MINER_IDLE
			if fallSpeed = MINER_MAX_FALL_SPEED then
				health -= 1
				if health > 0 then
					logger.add("fall damage!")
				else
					health = 0
					logger.add("dead!")
					state = MINER_DEAD
				end if
			end if
		end if
	end if
end sub

function player_type.isDead() as boolean
	return iif(health <= 0, TRUE, FALSE)
end function

function player_type.isStanding(checkState as integer) as boolean
	if checkState = MINER_STAND_LEFT then return TRUE
	if checkState = MINER_STAND_RIGHT then return TRUE
	return FALSE
end function

function player_type.isWalking(checkState as integer) as boolean
	if checkState = MINER_WALK_LEFT then return TRUE
	if checkState = MINER_WALK_RIGHT then return TRUE
	return FALSE
end function

function player_type.isClimbing(checkState as integer) as boolean
	if checkState = MINER_CLIMB_UP then return TRUE
	if checkState = MINER_CLIMB_DOWN then return TRUE
	if checkState = MINER_CLIMB_STOP then return TRUE
	return FALSE
end function

'change to array?
function player_type.getStateStr() as string
	select case state
		case MINER_NONE : return "MINER_NONE"
		case MINER_IDLE : return "MINER_IDLE"
		case MINER_WALK_LEFT : return "MINER_WALK_LEFT"
		case MINER_WALK_RIGHT : return "MINER_WALK_RIGHT"
		case MINER_STAND_LEFT : return "MINER_STAND_LEFT"
		case MINER_STAND_RIGHT : return "MINER_STAND_RIGHT"
		case MINER_CLIMB_UP : return "MINER_CLIMB_UP"
		case MINER_CLIMB_DOWN : return "MINER_CLIMB_DOWN"
		case MINER_CLIMB_STOP : return "MINER_CLIMB_STOP"
		case MINER_FALL : return "MINER_FALL"
		case MINER_DEAD : return "MINER_DEAD"
	end select
	return "MINER_ILLEGAL_STATE"
end function

sub player_type.draw_()
	'highlight target tile with dashed square
	if pMap->validPos(markerGridPos) then
		dim as int2d markerScrPos = getScrPos(markerGridPos, posMap - posScr)
		line(markerScrPos.x - GRID_HALF_X - 1, markerScrPos.y - GRID_HALF_Y - 1)_
			-step(GRID_SIZE_X, GRID_SIZE_Y), rgba(255, 255, 255, 255), b, &b1010101010101010
	end if
	'draw miner image
	pImg->drawxy(posScr.x, posScr.y)
	'draw health bar
	if health >= 0 and health <= MINER_MAX_HEALTH then
		imgHealth(health).drawxym(scr.edge.x - 10 , 10, IHA_RIGHT, IVA_TOP, IDM_ALPHA)
	end if
	'draw tool indicator
	dim as integer xoffs = 52, yoffs = 52, xmarg = 42, ymarg = 42
	dim as integer xcpos = scr.edge.x - xoffs, ycpos = scr.edge.y - yoffs
	line(xcpos - (xmarg - 0), ycpos - (ymarg - 0))-(xcpos + (xmarg + 0), ycpos + (ymarg + 0)), rgba(127,127,127,255), b
	line(xcpos - (xmarg - 1), ycpos - (ymarg - 1))-(xcpos + (xmarg + 1), ycpos + (ymarg + 1)), rgba(63,63,63,255), b
	line(xcpos - (xmarg - 2), ycpos - (ymarg - 2))-(xcpos + (xmarg + 2), ycpos + (ymarg + 2)), rgba(0,0,0,127), bf
	imgBufAll.image(tool(selectedTool).imgId).drawxym(xcpos, ycpos, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
	f1.printTextAk(xcpos + xmarg - 6, ycpos + ymarg - 28, str(tool(selectedTool).amount), FHA_RIGHT)

	locate 1,1: print getStateStr()
	locate 2,1: print getGridPos(posMap)
	'locate 3,1: print format(miner.idleWaitTmr.timeLeft(), "0.0")
	'locate 3,1: print requestDir
	'display inventory, move to main?
	if showInv then
		for i as integer = 0 to pInv->numItems() - 1
			f1.printTextAk(10, 100 + i * 20, pInv->item(i).label & ": " & pInv->item(i).amount, FHA_LEFT)
		next
	end if
end sub
