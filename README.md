# Another-freebasic-miner
https://freebasic.net/forum/viewtopic.php?f=15&t=28025

Status: **Work in progress**

Control keys:

* |up|, |down|, |left|, |right| arrow keys
* |space| for build / destroy action
* |pageup|, |pagedown| to change action / tool
* |escape| to exit

Todo:
* Set marker invalid when swithing to idle?
* Make collectable object, not part of map? Objects disapear after 30 seconds? blink last 10 second?
* Check player object distance.
* make imgBufAll not shared
* Use salt for? Food?
* growing trees/fruit plants
* Collect a resource, show resource object ball -> items list? can drop as well?
* Block movement / changing marker pos during action (e.g drilling)
* Allow building ladder at current tile?
* Build ladders while climbing
* Do not move on ladder when standing and pressing down (for drilling)
* Rock layers
* Dynamite: Place, pick-up, ignite, can fall, damages players, countdown, explosions, different sizes
* Drill is faster, but no resource
* shovel action, required for flower removal?
* Quick tool selection keys: 1 = pick axe, 2 = drill, etc.
* Make unsupported ladders and flowers drop? and drop collatables
* Improve draw tool indicator code
* Change of player class stores images, less variabes
* Container / class for player images?
* separate keys for build & destroy
* Use <tab> to switch between build and destroy?
* Use mousewheel to change tool / build selection?
* Auto update destroy indicator? pick, drill, shovel, ... No?
* change from damage to health, init, remove public
* Freeze miner during action?
* Block movement during action, e.g. pick axe. Or stop action on move. State Busy?
* reset idle on any key press (e.g. escape)' and start action anim
* draw square centered? What?
* add grass to all top blocks? (grass dirt block, not grass flower)
* invertory:
  * Stuff that can be placed: blocks, ladders, lamps
    * background stuff: blocks
    * foreground stuff: ladders, lamps
  * Stuff that cannot be placed: pick axe, dynamite, food, coal. Why not?
* Show bagpack with number of items
* use player size struct, AABB? note: height not centered with tile
* fix size of images? 66x66 ?
* Add screenshot to wiki
* build stuff
* Display player red on getting damaged
* map load/save + player stuff
* map editor
* add sound
* Change anim.start(), supply array instead of first image + numImages
* Two fg layers needed: for cracks + diamands? Or draw cracks only depending on block healthe/damage.
* clean up image.bi : alignment struct -> single center flag, vert/horz combined
* font.bi : change pTrim to struct, and use redim
* font.bi : add vert align
* ladders build animation
* mouse cursor, aiming direction?
* sky tiles?
* ladder bridge issue (climbing vs walking, in font of / behind ladder)
* loop world left-right
* item menu
* elevator
* lighting
* enemies
* day/night
* Main menu
* item conversion and crafting
* check 0_plans_todo_ideas_0
* Goal steps:
* 1.food for energy restore
* 2.wood home and ladders and signs for storage
* 3.factory for smelting?
* 4.build spaceship, go to next world, more difficult, end goal go home, display universe

Don't:

* mapPos: dived by grid size?
* plants in object class, needs update, add, remove, etc.
* Change NUM_IMG_WALK to MINER_IMG_WALK, use namespace?
* make map shared?

Done:

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

no long pause
start with something simple each day
don't worry to much about the design, implement first then improve
