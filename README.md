# Another-freebasic-miner
https://freebasic.net/forum/viewtopic.php?f=15&t=28025

Status: **Work in progress**

Control keys:

* |up|, |down|, |left|, |right| arrow keys
* |space| for build / destroy action
* |pageup|, |pagedown| to change action / tool
* |escape| to exit

Todo:

* pick axe animation
* break stuff animation sprites on tiles, time
* reset idle on any key press (e.g. escape)' and start action anim
* draw square centered ?
* plant supporting block removed? remove plant
* add grass to all top blocks?
* invertory
* use player size struct, AABB? note: height not centered with tile
* fix size of images? 66x66 ?
* build stuff
* shovel action
* make map shared?
* map load/save
* map editor
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
* growing trees/fruit plants
* enemies
* day/night
* item conversion and crafting
* check 0_plans_todo_ideas_0
* build spaceship, go to next world, more difficult, end goal go home, display universe

Don't:

* mapPos: dived by grid size?
* plants in object class, needs update, add, remove, etc.

Done:

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
* 16-02-2020: load all images into 1 array, change enum
* 17-02-2020: use in map image index for Bg,Fg instead of poninters?
* 17-02-2020: plants, flowers, Animate all plants synchrone

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
