const DIR_RIGHT = 0, DIR_LEFT = 1

const NUM_IMG_WALK = 4
const NUM_IMG_WINK = 4
const NUM_IMG_CLIMB = 4
const NUM_IMG_FALL = 2
const NUM_IMG_HEALTH = 9
const NUM_IMG_PICK = 2

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
	MINER_FALL '9
	MINER_DEAD '10
end enum

enum E_TOOL
	TOOL_LADDER '0
	TOOl_PICK '1
	TOOL_INVALID '2
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
	dim as timer_type idleWaitTmr
	private:
	dim as multikey_type mkey
	dim as map_type ptr pMap_
	dim as image_type ptr pImg 'current image to display
	dim as int2d requestDir  = int2d(0, 0)
	dim as int2d targetGridPos = int2d(-1, -1)
	dim as integer state, prevState
	dim as integer health
	dim as integer numLadders = 10
	dim as integer selectedTool
	dim as float fallSpeed = 0 'pixels/s
	dim as anim_type anim
	dim as image_type imgWalk(0 to 1, NUM_IMG_WALK-1)
	dim as image_type imgWink(NUM_IMG_WINK-1)
	dim as image_type imgClimb(NUM_IMG_CLIMB-1)
	dim as image_type imgFall(NUM_IMG_FALL-1)
	dim as image_type imgHealth(NUM_IMG_HEALTH-1)
	dim as image_type imgPick(NUM_IMG_PICK-1)
	dim as image_type imgDead
	public:
	declare function init_() as integer
	declare sub reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	declare sub draw_()
	declare sub processKeyInput()
	declare sub processMouseInput()
	declare sub update(dt as double) 'update state
	declare sub updatePos(posChange as flt2d) 'update position
	declare function tryWalk(xChangeReq as float, byref posChangeAct as flt2d) as integer
	declare function tryClimb(yChangeReq as float, byref posChangeAct as flt2d) as integer
	declare function tryFall(dt as double, byref posChangeAct as flt2d) as integer
	declare function isDead() as integer
	declare function getStateStr() as string
end type

'copy from image buffer
function player_type.init_() as integer
	for i as integer = 0 to NUM_IMG_WINK - 1
		if imgBufAll.validImage(act_wink_1 + i) = false then return -1
		imgBufAll.image(act_wink_1 + i).copyTo(imgWink(i))
	next
	for i as integer = 0 to NUM_IMG_WALK - 1
		if imgBufAll.validImage(act_walk_1 + i) = false then return -2
		imgBufAll.image(act_walk_1 + i).copyTo(imgWalk(DIR_LEFT, i))
		imgBufAll.image(act_walk_1 + i).hFlipTo(imgWalk(DIR_RIGHT, i))
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
		imgBufAll.image(act_pick_1 + i).copyTo(imgPick(i))
	next
	if imgBufAll.validImage(act_dead) = false then return -6
	imgBufAll.image(act_dead).copyTo(imgDead)
	'healthbar
	for i as integer = 0 to NUM_IMG_HEALTH - 1
		if imgBufAll.validImage(ol_health_0 + i) = false then return -7
		imgBufAll.image(ol_health_0 + i).copyTo(imgHealth(i))
	next
	anim.init(pImg)
	return 0
end function

sub player_type.reset_(byref map as map_type, posMap as int2d, posScr as int2d)
	pMap_ = @map
	this.posMap = toFlt2d(posMap + int2d(0, -00)) '1 pixel higer
	this.posScr = toFlt2d(posScr + int2d(0, -00)) '1 pixel higer
	state = MINER_NONE
	prevState = MINER_NONE
	pImg = @imgWink(0)
	health = MINER_MAX_HEALTH
	selectedTool = TOOL_PICK
end sub

sub player_type.draw_()
	'highlight target tile with dashed square
	if pMap_->validPos(targetGridPos) then
		dim as int2d targetScrPos = getScrPos(targetGridPos, posMap - posScr)
		line(targetScrPos.x - GRID_HALF_X - 1, targetScrPos.y - GRID_HALF_Y - 1)_
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
	end select
end sub

sub player_type.processKeyInput()
	'allow x and y state?
	prevState = state
	'walk left or stop
	if mkey.down(FB.SC_LEFT) then
		state = MINER_WALK_LEFT 'request left
		requestDir = int2d(-1, 0)
	else
		if prevState = MINER_WALK_LEFT then state = MINER_STAND_LEFT
	end if
	'walk right or stop
	if mkey.down(FB.SC_RIGHT) then
		state = MINER_WALK_RIGHT 'request right
		requestDir = int2d(+1, 0)
	else
		if prevState = MINER_WALK_RIGHT then state = MINER_STAND_RIGHT
	end if
	'climb up or stop
	if mkey.down(FB.SC_UP) then 'ymove request up
		state = MINER_CLIMB_UP 'request
		requestDir = int2d(0, -1)
	else
		if prevState = MINER_CLIMB_UP then state = MINER_CLIMB_STOP
	end if
	'climb down or stop
	if mkey.down(FB.SC_DOWN) then 'ymove request up
		state = MINER_CLIMB_DOWN 'request
		requestDir = int2d(0, +1)
	else
		if prevState = MINER_CLIMB_DOWN then state = MINER_CLIMB_STOP
	end if
	if mkey.pressed(FB.SC_PAGEDOWN) then
		'anim.stop_(@imgWink(0))
		idleWaitTmr.start(5.0)
		selectedTool += 1
		if selectedTool >= TOOL_INVALID then selectedTool = 0 'first tool
		'logger.add("Selected tool: " & selectedTool)
	end if
	if mkey.pressed(FB.SC_PAGEUP) then
		'anim.stop_(@imgWink(0))
		idleWaitTmr.start(5.0)
		selectedTool -= 1
		if selectedTool < 0 then selectedTool = TOOL_INVALID - 1 'last tool
		'logger.add("Selected tool: " & selectedTool)
	end if
	
	if mkey.pressed(FB.SC_SPACE) then
		'anim.stop_(@imgWink(0))
		idleWaitTmr.start(5.0)
		if pMap_->validPos(targetGridPos) then
			select case selectedTool
			case TOOL_LADDER
				if (pMap_->getBgProp(targetGridPos) and (IS_SOLID or IS_CLIMB)) = 0 then
					if numLadders > 0 then
						numLadders -= 1
						dim as integer bgImgId = iif(targetGridPos.y = 0, -1, bg_shadow)
						pMap_->setTile(targetGridPos, fg_construction_ladder, bgImgId, IS_CLIMB)
					else
						logger.add("No more ladders")
					end if
				else
					logger.add("Cannot build there")
				end if
			case TOOL_PICK
				if (pMap_->getBgProp(targetGridPos) and (IS_EMPTY or IS_FIXED)) = 0 then
					dim as integer bgImgId = iif(targetGridPos.y = 0, -1, bg_shadow)
					pMap_->setTile(targetGridPos, 0, bgImgId, IS_EMPTY)
					logger.add("Destroy OK")
				else
					logger.add("Cannot destroy that: " & pMap_->getBgProp(targetGridPos))
				end if
			end select
		end if
	end if
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
			anim.start(@imgWink(0), NUM_IMG_WINK, 2, 0.15) 'start idle animation 
			idleWaitTmr.start(5.0 + rnd * 10.0) 'restart wait
		end if
	end select

	select case state 'needs to be after previuos select case
	case MINER_CLIMB_UP, MINER_CLIMB_DOWN, MINER_CLIMB_STOP
		'no falling when on ladder
	case else
		state = tryFall(dt, posChange) 'can set MINER_FALL or MINER_IDLE
	end select

	updatePos(posChange) 'update posMap & posScr

	select case state
	case MINER_IDLE, MINER_STAND_LEFT, MINER_STAND_RIGHT, MINER_CLIMB_STOP
		dim as int2d currentGridPos = getGridPos(posMap)
		targetGridPos = currentGridPos + requestDir
		if abs(targetGridPos.x * GRID_SIZE_X - posMap.x) > (GRID_SIZE_X + 10) or _
			abs(targetGridPos.y * GRID_SIZE_Y - posMap.y) > (GRID_SIZE_Y + 10) then
			'too far away, set current position
			targetGridPos = currentGridPos
		end if
	case else
		targetGridPos = int2d(-1, -1) 'invalid position
	end select
	
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
			anim.start(@imgWalk(DIR_LEFT, 0), NUM_IMG_WALK, -1, 0.15)
		case MINER_WALK_RIGHT
			anim.start(@imgWalk(DIR_RIGHT, 0), NUM_IMG_WALK, -1, 0.15)
		case MINER_STAND_LEFT
			anim.stop_(@imgWalk(DIR_LEFT, 0))
			idleWaitTmr.start(5.0) 
		case MINER_STAND_RIGHT
			anim.stop_(@imgWalk(DIR_RIGHT, 0))
			idleWaitTmr.start(5.0) 
		case MINER_CLIMB_UP
			anim.start(@imgClimb(0), NUM_IMG_CLIMB, -1, 0.10)
		case MINER_CLIMB_DOWN
			anim.start(@imgClimb(0), NUM_IMG_CLIMB, -1, 0.10)
		case MINER_CLIMB_STOP
			'animStop(0)
			anim.stop_(@imgClimb(0))
		case MINER_FALL
			anim.start(@imgFall(0), NUM_IMG_FALL, -1, 0.15)
		case MINER_DEAD
			anim.stop_(@imgDead)
		end select
	end if

	anim.update(dt)

end sub

sub player_type.updatePos(posChange as flt2d)
	posMap += posChange
	posScr += posChange
	'keep player somewhat centered on screen
	if posScr.x < screenBorder.x then posScr.x = screenBorder.x
	if posScr.x > scr.edge.x - screenBorder.x then posScr.x = scr.edge.x - screenBorder.x
	if posScr.y < screenBorder.y then posScr.y = screenBorder.y
	if posScr.y > scr.edge.y - screenBorder.y then posScr.y = scr.edge.y - screenBorder.y
end sub

function player_type.tryWalk(xChangeReq as float, byref posChangeAct as flt2d) as integer
	dim as integer newState = state
	dim as integer playerEdgeOffset = iif(xChangeReq < 0, -MINER_HALF_WIDTH, +MINER_HALF_WIDTH) 'left or right side of payer
	dim as integer tileEgdeOffset = iif(xChangeReq < 0, +GRID_HALF_X, -GRID_HALF_X) 'right or left side of tile
	dim as int2d targetGridPosHead = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y - MINER_HAED_DIST + 1)
	dim as int2d targetGridPosFeet = getGridPosXY(posMap.x + playerEdgeOffset + xChangeReq, posMap.y + MINER_FEET_DIST - 1)
	if (pMap_->getBgProp(targetGridPosHead) and IS_SOLID) or (pMap_->getBgProp(targetGridPosFeet) and IS_SOLID) then
		dim as float xPosChangeHead = (targetGridPosHead.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		dim as float xPosChangeFeet = (targetGridPosfeet.x * GRID_SIZE_X + tileEgdeOffset) - (posMap.x + playerEdgeOffset)
		posChangeAct.x = iif(abs(xPosChangeHead) < abs(xPosChangeFeet), xPosChangeHead, xPosChangeFeet) '-5 > -3 ? no, ret -3
		newState = iif(xChangeReq < 0, MINER_STAND_LEFT, MINER_STAND_RIGHT)
		logger.add("cannot walk there, something in the way")
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
	dim as int2d currentGridPos = getGridPos(posMap)
	if pMap_->getBgProp(currentGridPos) and IS_CLIMB then
		'check not to far from ladder
		dim as int2d tileScrPos = getScrPos(currentGridPos, posMap - posScr)
		if abs(tileScrPos.x - posScr.x) < MINER_LADDER_DIST then
			'check target position
			dim as int2d targetGridPos = getGridPosXY(posMap.x, posMap.y + playerEdgeOffset + yChangeReq)
			if (pMap_->getBgProp(targetGridPos) and IS_CLIMB) = 0 then
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
			logger.add("cannot climb, too far from ladder")
			newState = MINER_IDLE
		end if
	else
		logger.add("cannot climb, no ladder at current tile")
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
	if (pMap_->getBgProp(targetGridPosLefoot) and IS_SOLID) = 0 and (pMap_->getBgProp(targetGridPosRifoot) and IS_SOLID) = 0 then
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
		case MINER_FALL: : return "MINER_FALL"
		case MINER_DEAD: : return "MINER_DEAD"
	end select
	return "MINER_ILLEGAL_STATE"
end function

