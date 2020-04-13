# Another-freebasic-miner
https://freebasic.net/forum/viewtopic.php?f=15&t=28025

Status: **Work in progress**

Control keys:

* |up|, |down|, |left|, |right| arrow keys
* |space| for build / destroy action
* |pageup|, |pagedown| to change action / tool
* |tab| to show inventory
* |escape| to exit

Todo (bugs & changes):
* make getMapPos(gridPos) function
* More images, better ordered, e.g. trees
* Block movement / changing marker pos during action (e.g drilling)
* Allow building ladder at current tile? Key to set current tile? ENTER?
* Build ladders while climbing?
* Improve draw tool indicator code
* Change of player class stores images, less variabes
* Container / class for player images?
* fix size of images? 66x66 ?
* Freeze miner during action?
* Block movement during action, e.g. pick axe. Or stop action on move. State Busy?
* reset idle on any key press (e.g. escape)' and start action anim
* Add screenshot to wiki
* clean up image.bi : alignment struct -> single center flag, vert/horz combined
* font.bi : change pTrim to struct, and use redim
* font.bi : add vert align
* Drill is faster, but no resource
* Resize object and move sprites to different folder?
* Set marker invalid when swithing to idle?
* make imgBufAll not shared

Todo (features):
* Build space for house and spaceship
* Background images, sky tiles?
* Use salt for? Food?
* growing trees/fruit plants
* Rock layers
* Dynamite: Place, pick-up, ignite, can fall, damages players, countdown, explosions, different sizes
* Shovel action, required for flower removal? -> collect plant?
* Make unsupported ladders and flowers drop? and drop collatables
* Auto update destroy indicator? pick, drill, shovel, ... No?
* add grass to all top blocks? (grass dirt block, not grass flower)
* Display player red on getting damaged
* map load/save + player stuff
* map editor
* add sound
* ladders build animation
* ladder bridge issue (climbing vs walking, in font of / behind ladder)
* loop world left-right
* item menu
* elevator
* lighting
* enemies
* day/night
* Main menu
* item conversion and crafting
* UI:
  * separate keys for build & destroy
  * Quick tool selection keys: 1 = pick axe, 2 = drill, etc.
  * Use <tab> to switch between build and destroy?
  * Use mousewheel to change tool / build selection?
  * mouse cursor, aiming direction?
* invertory:
  * Stuff that can be placed: blocks, ladders, lamps
    * background stuff: blocks
    * foreground stuff: ladders, lamps
  * Stuff that cannot be placed: pick axe, dynamite, food, coal. Why not?
  * Show bagpack with number of items, total?
* Goal steps:
  * 1.food for energy restore
  * 2.wood home and ladders and signs for storage (present losing on death)
  * 3.factory for smelting?
  * 4.build spaceship, go to next world, more difficult, end goal go home, display universe
  * check 0_plans_todo_ideas_0

Don't/obsolete:
* mapPos: dived by grid size?
* plants in object class, needs update, add, remove, etc.
* Change NUM_IMG_WALK to MINER_IMG_WALK, use namespace?
* make map shared?
* Make collectable object, not part of map? Objects disapear after 30 seconds? blink last 10 second?
* Two fg layers needed: for cracks + diamands? Or draw cracks only depending on block healthe/damage.
* In processKeyInput() do not set state, request (then no need for prevState as well?), requestState?

Unclear:
* change from damage to health, init, remove public
* draw square centered? What?
* use player size struct, AABB? note: height not centered with tile
* build stuff
* Change anim.start(), supply array instead of first image + numImages
* Check player object distance?
* Collect a resource, show resource object ball -> items list? can drop as well?

Done:
* 13-04-2020: Miner does not move on to ladder when standing and pressing down (for drilling down)
* 13-04-2020: miner::isStanding(), isWalking(), isClimbing() added
* 13-04-2020: miner::tryWalk(), tryClimb(), tryFall() do not set state via return
* 05-04-2020: Fix -22, +22, change resource: resourceImgId(i), collectImgId(i)
* 12-03-2020: Only show inventory while <tab> is pressed
* 12-03-2020: Flower stuff cleaned up
* 08-03-2020: map_tile class added, map_type changes
* 04-03-2020: Generate Caves, random walk
* 03-03-2020: Minneral / resource veins added
* 03-03-2020: Map creation stuff moved to map class
* 02-03-2020: Map view mode added
* 01-03-2020: Flower spawning timer and map.killFlower() added
* 01-03-2020: frame time constants added in player class
* 29-02-2020: resourceArray added
* 28-02-2020: remove plant / flower when supporting block removed
* 28-02-2020: property targetGridPos renamed to markerGridPos
* 28-02-2020: currentGridPos now property of player class
* 25-02-2020: No drilling on ladder allowed
* 25-02-2020: Switched from ext_multikey to registered_key
* 22-02-2020: break stuff animation sprites on tiles
* 22-02-2020: Block health (damage) added
* 22-02-2020: pick axe animation
* 17-02-2020: plants, flowers, Animate all plants synchrone
* 17-02-2020: use in map image index for Bg, Fg instead of poninters?
* 16-02-2020: load all images into 1 array, change enum
* animation class
* start fall speed + incremental fall speed + max fall speed?
* bug: wall climbing (when when falling from ladder)
* function: update player position, call after state handling, posChange as flt2d
* falling animation
* add falling state, use falling accelleration in this state
* ladder message: cannot build there, no more ladders
* display action location
* fall damage, health bar
* miner variables to const
* make image buffers shared
* ladders: show amount available
* display bgProp on tiles
* move draw tool to miner class
* break stuff

<u>Notes</u>

	mogrify -verbose -format bmp *.png
	rm *.png
	convert -verbose test.bmp -crop 64x64+1+1 test.bmp
	mogrify -verbose -crop 64x64+1+1 *.bmp
	healthbar:
	convert -verbose -crop 120x16+37+108 test.bmp test2.bmp
	mogrify -verbose -crop 120x16+37+108 *.bmp
	ls -lU
	https://en.wikipedia.org/wiki/Markdown
	git status
	git add *
	git status
	git commit -m 'message'
	git push origin master
	git status
	https://minecraft.gamepedia.com/Controls

no long pause (it happens)
start with something simple each day
don't worry to much about the design, implement first then improve

main()
* miner.processKeyInput()
* miner.update()
* viewer.update()
* flower.update()
* collectList.update()
* map.draw_()
* collectList.draw_()
* miner.draw_()

miner.update()
* state = tryWalk()
* state = tryClimb()
* tryAction()
* updateAction()
* state = tryFall()
* updatePos()
* start/stop animations/timers
* anim.update()

