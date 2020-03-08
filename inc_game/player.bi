const NUM_IMG_WALK = 4
const NUM_IMG_WINK = 4
const NUM_IMG_CLIMB = 4
const NUM_IMG_FALL = 2
const NUM_IMG_HEALTH = 9
const NUM_IMG_PICK = 2
const NUM_IMG_DRILL_SIDE = 2
const NUM_IMG_DRILL_DOWN = 2
const NUM_IMG_DRILL_UP = 2

const FRAME_TIME_PICK = 0.15
const FRAME_TIME_DRILL = 0.10
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
	'RKEY_NULL '8 = list terminator
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

enum E_MINER_TOOL
	TOOL_LADDER '0
	TOOl_PICK '1
	TOOl_DRILL '2
	TOOL_INVALID '3
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
	dim as map_type ptr pMap_
	dim as image_type ptr pImg 'current image to display
	dim as int2d requestDir
	dim as int2d currentGridPos
	dim as int2d markerGridPos
	dim as int2d actionGridPos
	dim as integer state, prevState
	dim as integer health
	dim as integer numLadders = 10
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
	dim as image_type imgDrillSide(0 to 1, NUM_IMG_DRILL_SIDE-1)
	dim as image_type imgDrillDown(NUM_IMG_DRILL_DOWN-1)
	dim as image_type imgDrillUp(NUM_IMG_DRILL_UP-1)
	dim as image_type imgDead
	public:
	declare function init_() as integer
	declare sub reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	declare sub processKeyInput()
	declare sub processMouseInput()
	declare sub tryAction()
	declare sub update(dt as double) 'update state
	declare sub updatePos(posChange as flt2d) 'update position
	declare sub updateAction()
	declare function tryWalk(xChangeReq as float, byref posChangeAct as flt2d) as integer
	declare function tryClimb(yChangeReq as float, byref posChangeAct as flt2d) as integer
	declare function tryFall(dt as double, byref posChangeAct as flt2d) as integer
	declare function isDead() as integer
	declare function getStateStr() as string
	declare sub draw_()
end type

'copy from image buffer
function player_type.init_() as integer
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
	anim.init(pImg) 'tell the anim class where the player image is
	'assing keys
	rkey.add(FB.SC_LEFT)
	rkey.add(FB.SC_RIGHT)
	rkey.add(FB.SC_UP)
	rkey.add(FB.SC_DOWN)
	rkey.add(FB.SC_PAGEDOWN)
	rkey.add(FB.SC_PAGEUP)
	rkey.add(FB.SC_SPACE)
	return 0
end function

sub player_type.reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	pMap_ = @map
	this.posMap = toFlt2d(posMap + int2d(0, -00)) '1 pixel higer ???
	this.posScr = toFlt2d(posScr + int2d(0, -00)) '1 pixel higer ???
	state = MINER_NONE
	prevState = MINER_NONE
	pImg = @imgWink(0)
	health = MINER_MAX_HEALTH
	selectedTool = TOOL_DRILL
	requestedAction = -1
	requestDir = int2d(0, -1) 'set off-screen
	markerGridPos = int2d(-1, -1) 'set invalid pos
	
end sub

sub player_type.processKeyInput()
	'allow x and y state?
	prevState = state
	'walk left or stop
	if rkey.isDown(RKEY_LEFT) then
		state = MINER_WALK_LEFT 'request left
		requestDir = int2d(-1, 0)
	else
		if prevState = MINER_WALK_LEFT then state = MINER_STAND_LEFT
	end if
	'walk right or stop
	if rkey.isDown(RKEY_RIGHT) then
		state = MINER_WALK_RIGHT 'request right
		requestDir = int2d(+1, 0)
	else
		if prevState = MINER_WALK_RIGHT then state = MINER_STAND_RIGHT
	end if
	'climb up or stop
	if rkey.isDown(RKEY_UP) then
		state = MINER_CLIMB_UP 'request
		requestDir = int2d(0, -1)
	else
		if prevState = MINER_CLIMB_UP then state = MINER_CLIMB_STOP
	end if
	'climb down or stop
	if rkey.isDown(RKEY_DOWN) then
		state = MINER_CLIMB_DOWN 'request
		requestDir = int2d(0, +1)
	else
		if prevState = MINER_CLIMB_DOWN then state = MINER_CLIMB_STOP
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
	
	if rkey.isPressed(RKEY_SPACE) then
		requestedAction = selectedTool
		'logger.add("start action")
		idleWaitTmr.start(5.0)
	end if

	if rkey.isReleased(RKEY_SPACE) then
		requestedAction = -1
		'logger.add("stop action")
		idleWaitTmr.start(5.0)
	end if

	rkey.updateState() 'very important
end sub

sub player_type.processMouseInput()
	'dim as mousetype mouse
	'dim as integer mouseEvent
	'mouseEvent = handleMouse(mouse)
end sub

sub player_type.tryAction() 'perform action
	if pMap_->validPos(markerGridPos) then
		select case requestedAction
		case TOOL_LADDER
			if (pMap_->tile(markerGridPos).bgProp and (IS_SOLID or IS_CLIMB)) = 0 then
				if numLadders > 0 then
					numLadders -= 1
					dim as integer bgImgId = iif(markerGridPos.y = 0, -1, bg_shadow)
					pMap_->tile(markerGridPos).set(fg_construction_ladder, bgImgId, IS_CLIMB, 1)
				end if
			end if
		case TOOL_PICK
			if requestDir.y = 0 then 'left or right only, not up or down
				if actionTmr.isActive = false then
					if (pMap_->tile(markerGridPos).bgProp and (IS_EMPTY or IS_FIXED)) = 0 then
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
					logger.add("" & pMap_->tile(markerGridPos).bgProp)
					if (pMap_->tile(markerGridPos).bgProp and (IS_EMPTY or IS_FIXED)) = 0 then
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
		case else
			'logger.add("Invalid action")
		end select
	end if
end sub

'update position & state
sub player_type.update(dt as double)
	dim as flt2d posChange = flt2d(0, 0) 'pixels
	select case state
	case MINER_NONE 'initial state
		state = MINER_IDLE 'triggers idle timer below
	case MINER_WALK_LEFT
		state = tryWalk(-MINER_WALK_SPEED * dt, posChange) 'can set MINER_STAND_LEFT
	case MINER_WALK_RIGHT
		state = tryWalk(+MINER_WALK_SPEED * dt, posChange) 'can set MINER_STAND_RIGHT
	case MINER_STAND_LEFT
		if idleWaitTmr.ended() then state = MINER_IDLE
	case MINER_STAND_RIGHT
		if idleWaitTmr.ended() then state = MINER_IDLE
	case MINER_FALL
	case MINER_CLIMB_UP
		state = tryClimb(-MINER_CLIMB_SPEED * dt, posChange) 'can set MINER_CLIMB_STOP or MINER_IDLE
	case MINER_CLIMB_DOWN
		state = tryClimb(+MINER_CLIMB_SPEED * dt, posChange) 'can set MINER_CLIMB_STOP or MINER_IDLE
	case MINER_CLIMB_STOP
	case MINER_IDLE
		if idleWaitTmr.ended() then
			anim.start(@imgWink(0), NUM_IMG_WINK, 2, FRAME_TIME_IDLE) 'start idle animation 
			idleWaitTmr.start(5.0 + rnd * 10.0) 'restart wait
		end if
	end select

	tryAction()
	updateAction()

	select case state 'needs to be after previous select case
	case MINER_CLIMB_UP, MINER_CLIMB_DOWN, MINER_CLIMB_STOP
		'no falling when on ladder
	case else
		state = tryFall(dt, posChange) 'can set MINER_FALL or MINER_IDLE
	end select

	'update posMap, posScr, curentGridPos, targetGridPos
	updatePos(posChange)
	
	'start/stop animations/timers on state change
	if state <> prevState then
		'leaving state
		select case prevState
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
		if pMap_->validPos(actionGridPos) = false then logger.add("invalid actionGridPos: BAD")
		'pMap_->health(actionGridPos.x, actionGridPos.y) -= 1
		pMap_->tile(actionGridPos).health -= 1
		'remove tile
		if pMap_->tile(actionGridPos).health <= 0 then
			if pMap_->tile(actionGridPos).bgProp and IS_RESOURCE then
				logger.add("Resource collected: " & pMap_->tile(actionGridPos).fgId)
			end if
			'logger.add(str(pMap_->getBgProp(actionGridPos)))
			pMap_->tile(actionGridPos).set(0, bgImgId, IS_EMPTY)
			requestedAction = -1
			'check flower above & remove
			pMap_->killFlower(actionGridPos + int2d(0, -1))
		end if
		dim as integer standDir = iif(requestDir.x < 0, DIR_LE, DIR_RI)
		anim.stop_(@imgWalk(standDir, 0))
	end if
end sub

function player_type.tryWalk(xChangeReq as float, byref posChangeAct as flt2d) as integer
	dim as integer newState = state
	dim as integer playerEdgeOffset = iif(xChangeReq < 0, -MINER_HALF_WIDTH, +MINER_HALF_WIDTH) 'left or right side of payer
	dim as integer tileEgdeOffset = iif(xChangeReq < 0, +GRID_HALF_X, -GRID_HALF_X) 'right or left side of tile
	dim as int2d targetGridPosHead = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y - MINER_HAED_DIST + 1)
	dim as int2d targetGridPosFeet = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y + MINER_FEET_DIST - 1)
	if (pMap_->tile(targetGridPosHead).bgProp and IS_SOLID) or (pMap_->tile(targetGridPosFeet).bgProp and IS_SOLID) then
		dim as float xPosChangeHead = (targetGridPosHead.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		dim as float xPosChangeFeet = (targetGridPosfeet.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		posChangeAct.x = iif(abs(xPosChangeHead) < abs(xPosChangeFeet), xPosChangeHead, xPosChangeFeet) '-5 > -3 ? no, ret -3
		newState = iif(xChangeReq < 0, MINER_STAND_LEFT, MINER_STAND_RIGHT)
		'logger.add("cannot walk there, something in the way")
	else
		posChangeAct.x = xChangeReq
	end if
	return newState
end function

function player_type.tryClimb(yChangeReq as float, byref posChangeAct as flt2d) as integer
	dim as integer newState = state
	dim as integer playerEdgeOffset = iif(yChangeReq < 0, -MINER_HAED_DIST, +MINER_FEET_DIST)
	dim as integer tileEgdeOffset = iif(yChangeReq < 0, +GRID_HALF_Y, -GRID_HALF_Y)
	'check current tile can be climbed
	'dim as int2d currentGridPos = getGridPos(posMap)
	if pMap_->tile(currentGridPos).bgProp and IS_CLIMB then
		'check not to far from ladder
		dim as int2d tileScrPos = getScrPos(currentGridPos, posMap - posScr)
		if abs(tileScrPos.x - posScr.x) < MINER_LADDER_DIST then
			'check target position
			dim as int2d targetGridPos = getGridPosXY(posMap.x, posMap.y + playerEdgeOffset + yChangeReq)
			if (pMap_->validPos(targetGridPos) = false) orelse _
				(pMap_->tile(targetGridPos).bgProp and IS_CLIMB) = 0 then
				logger.add("cannot climb, end of ladder")
				posChangeAct.y = (targetGridPos.y * GRID_SIZE_Y + tileEgdeOffset) - (posMap.y + playerEdgeOffset)
				newState = MINER_CLIMB_STOP
				'newState = iif(yChangeReq < 0, MINER_CLIMB_STOP, MINER_IDLE) '+y = down
			else
				posChangeAct.y = yChangeReq
			end if
			'snap to center of ladder
			if prevState <> state then
				 posChangeAct.x = (targetGridPos.x * GRID_SIZE_X) - posMap.x
			end if
		else
			'logger.add("cannot climb, too far from ladder")
			newState = MINER_IDLE
		end if
	else
		'logger.add("cannot climb, no ladder at current tile")
		newState = MINER_IDLE
	end if
	return newState
end function

function player_type.tryFall(dt as double, byref posChangeAct as flt2d) as integer
	dim as integer newState = state
	dim as float fallDist = iif(GRAVITY * dt > MINER_MIN_FALL_DIST, GRAVITY * dt, MINER_MIN_FALL_DIST)
	dim as int2d targetGridPosLefoot = getGridPosXY(posMap.x - MINER_HALF_WIDTH + 1, posMap.y + MINER_FEET_DIST + fallDist)
	dim as int2d targetGridPosRifoot = getGridPosXY(posMap.x + MINER_HALF_WIDTH - 1, posMap.y + MINER_FEET_DIST + fallDist)
	'nothing solid below both feet?
	if (pMap_->tile(targetGridPosLefoot).bgProp and IS_SOLID) = 0 and (pMap_->tile(targetGridPosRifoot).bgProp and IS_SOLID) = 0 then
		if prevState <> MINER_FALL then
			logger.add("start falling")
			fallSpeed = 0.0
		else
			'logger.add("still falling")
			fallSpeed += GRAVITY * dt
			if fallSpeed > MINER_MAX_FALL_SPEED then fallSpeed = MINER_MAX_FALL_SPEED
		end if
		newState = MINER_FALL
		posChangeAct.y += fallSpeed * dt
		'if posChangeAct.y > fallDist then logger.add("BAD BAD BAD " & posChangeAct.y)
	else 'small correction
		'logger.add("small correction")
		dim as float yPosChangeLeFoot = (targetGridPosLefoot.y * GRID_SIZE_Y - GRID_HALF_Y) - (posMap.y + MINER_FEET_DIST)
		dim as float yPosChangeRiFoot = (targetGridPosRifoot.y * GRID_SIZE_Y - GRID_HALF_Y) - (posMap.y + MINER_FEET_DIST)
		'get smallest distance, remember down = positive y-direction
		posChangeAct.y += iif(yPosChangeLeFoot < yPosChangeRiFoot, yPosChangeLeFoot, yPosChangeRiFoot)
		'if prevState = MINER_FALL then retVal = ACT_FALL_END
		if prevState = MINER_FALL then
			newState = MINER_IDLE
			if fallSpeed = MINER_MAX_FALL_SPEED then
				health -= 1
				if health > 0 then
					logger.add("fall damage!")
				else
					health = 0
					logger.add("dead!")
					newState = MINER_DEAD
				end if
			end if
		end if
	end if
	return newState
end function

function player_type.isDead() as integer
	return iif(health <= 0, true, false)
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
	if pMap_->validPos(markerGridPos) then
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
	line(scr.edge.x - 85, scr.edge.y - 85)-step(63 + 14, 63 + 14), rgba(127,127,127,255), b
	line(scr.edge.x - 84, scr.edge.y - 84)-step(63 + 12, 63 + 12), rgba(63,63,63,255), b
	line(scr.edge.x - 83, scr.edge.y - 83)-step(63 + 10, 63 + 10), rgba(0,0,0,127), bf
	select case selectedTool
	case TOOL_LADDER
		imgBufAll.image(fg_construction_ladder).drawxym(scr.edge.x - 80 + 32, scr.edge.y - 80 + 32, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
		f1.printTextAk(scr.edge.x - 80 + 64, scr.edge.y - 90 + 50, str(numLadders), FHA_RIGHT)
	case TOOL_PICK
		imgBufAll.image(ol_item_pick).drawxym(scr.edge.x - 80 + 32, scr.edge.y - 80 + 32, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
	case TOOL_DRILL
		imgBufAll.image(ol_item_drill).drawxym(scr.edge.x - 80 + 32, scr.edge.y - 80 + 32, IHA_CENTER, IVA_CENTER, IDM_ALPHA)
	end select
	'some debug info
	locate 1,1: print getStateStr();
	locate 2,1: print getGridPos(posMap);
	'locate 3,1: print format(miner.idleWaitTmr.timeLeft(), "0.0");
	locate 3,1: print requestDir;
end sub
