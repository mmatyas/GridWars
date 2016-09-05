GridWars - April 19, 2006

Get latest version here:  http://www.incitti.com/Blitz/

---------------------------------------------------------------------------
Programmed by - Mark Incitti 2006
---------------------------------------------------------------------------

Thanks:
---------------------------------------------------------------------------
Swith	- thank you for the music, the song I'm singing
taumel	- thanks for the cool grid effects and the bloom effect on the gfx sets
mentil	- thanks for your analysis of Geometry Wars and code bits
RiK	- thanks for coding suggestions and all the Mac builds
svrman  - thanks for gfx sets
PVB	- thanks for the download space!

Everyone else @ yakyak & blitzbasic 
	- thanks to all that contributed critiques & suggestions.

Always open for more comments and suggestions.





Instructions:
------------------------------------------------------------------------------
Run GridWars.exe
ESC to bring up options menu -> Configure to your setup
Shoot everything.
Collect powerups.




Recommended Settings:
------------------------------------------------------------------------------
Screen 		1024X768
Playfield 	1024X768
Scroll 		Off
Inertia		50%
GFX		High
Stars		400
Particles	Lines
Grid 		Pattern 4, Blue
Control		Dual Analog




Controls:
------------------------------------------------------------------------------
Joystick - 8 directional digital fire/move + bomb + config
Dual Analog - 360 degree fire/move + bomb + config
Mouse - 360 degree move, LMB fire, RMB bomb  (ESC key for config)
Keyboard - WASD move, LEFT/RIGHT/UP/DOWN fire, SPACE bomb, ESC config
Hybrid - Mouse fire/aim, WASD move, SPACE bomb

ESC - Options/Configuration

F3 - cycle through available grid types (20!)
F4 - cycle through number of stars  (0-1000)
F5 - toggle particle gravity
F6 - cycle through particle styles

F1 - enable cheatmode
*F2 - toggle god mode
*1 - side shooters
*2 - back shooters
*3 - super shots
*4 - bouncy shots
*x - extra cannon
*z - faster shots
*s - shield powerups
*p - pause/freeze
*o - resume/step(while holding P)

* when cheat is on
(No hiscore entry when cheating!)



Building using BMax:
------------------------------------------------------------------------------
Compile grid.bmx (BlitzMax - www.blitzbasic.com)
Should work fine on PC, Mac
Linux version untested.
 




Config:
---------------------------------------------------------------------------
Here's an explanation of the various things in the config.txt file.
Be careful editing these values (very dependent on [<Label>] followed by value on next line)
Most of these are configurable through the various options menus.
*these can only be changed manually.

[Windowed]
True (windowed) / False (fullscreen)


[Control Type]
Dual Analog / Mouse / Joypad / Keyboard / Hybrid


[Hybrid Config]
0 (Keys Move, Mouse Aim/Fire) / 1 (Mouse Move, Keys Fire) / 2 (Keys move, Mouse/keys fire (centered))


[Joypad Config]
0 (D-pad Move, buttons Fire) / 1 (D-pad Fire, buttons Move)


[Joypad Left]
[Joypad Up]
[Joypad Right]
[Joypad Down]
[Joypad Option]
[Joypad Bomb]
0-15 


[Autofire]
0 (Off) / 1 (On)


[Key Bomb]
[Key Move Left]
[Key Move Right]
[Key Move Up]
[Key Move Down]
[Key Fire Left]
[Key Fire Right]
[Key Fire Up]
[Key Fire Down]
Ascii codes


[SFX Volume]
[Music Volume]
0 (off) - 100 (Max)


[Grid Style]
0-12


[Grid Red]
[Grid Green]
[Grid Blue]
0-255


[Grid Opacity]
0-100


[Grid Spacing]
0 (4 pixels) / 1 (8 pixels) / 2 (16 pixels) / 3 (32 pixels)


*[Full Grid]
0 (only draw what's on screen) / 1 (Draw whole grid)


[Gfx Set]
0 (no bloom) / 1 (Low - smaller size) / 2 (Medium) / 3 (Larger size, full bloom)


[Show Stars]
0-10000 (number of stars in background)


[Scroll]
0 (Off) / 1 (On) 


[Playfield Width]
[Playfield Height]
These can be set to whatever you want,
try to keep it in multiples of 64 or matching a screen resolution

[Screen Width]
[Screen Height]
These can be set to whatever you want,
All the standard resolutions are included from 640X480 to 5120X4096


*[Particle Count]
200-50000


*[Particle Life]
30-100


[Particle Gravity]
0 (Off) / 1 (On)


*[Particle Decay]
0.80 - 0.99


[Particle Style]
0 (Lines) / 1 (small image) / 2 (Large image) / 3 (transformed image)


[Mouse Sensitivity]
0-100 (more sensitive)


[Mouse Fire]
[Mouse Bomb]
1 (LMB) / 2 (RMB) / 3 (MMB)


[Difficulty]
0 (Easy) / 1 (Medium) / 2 (Hard)


[Inertia]
0-100






History:
---------------------------------------------------------------------------
- Apr 19 5.4
		- pulsing blackhole
		- re-arrange order of generators
		- fix Multiplier going to 11X
		- move & shrink X Multiplier display
		- change multiplier amounts
		- reduce blackhole 'harvesting' points
		
- Apr 03 5.3
		- handle fuzzy numbers from digital joy values
		- warning sound when shield going out

- Mar 28 5.2
		- fix typo in joystick fire deadzone
		
- Mar 14 5.1
		- fix gfxset save/load
		- build with BMax 1.18 (minor changes to BASS interface)
		- added 'sound set' - user or default 
		- place your own sounds in 'sounds/user' folder
		

- Mar 13 5.0
		- slightly longer snakes 
		- MAX particles set to 50K 
		- MAX stars set to 10K
		- particle gravity changes
		- blackhole only pull when active
		- User gfx folder (for mods)
		- new icon - thanks SimpleMan46
		- added 1280X854

- Mar 8 4.9
		 - colours in external file for easier moding
		 - new grid pattern

- Mar 7  4.8
		- slow down greenies again
		- bigger player explosion
		- grid modifications
		- adjust spawn again (prevent them appearing too close)
					
- Mar 4  4.7
		- menu linewidth fixes
		- grid effect extend to right and lower edges


- Mar 1  4.6
		- better default scores
		- fix multispawn blackholes
		- less particle radius pull on blackholes

- Feb 28 4.5
		- linux buildable
		- check 32/24/16 depth for gfx 
		- modify particle orbit on title
		- P-Key during score to show settings string
		- fixed hybrid drift
		- menu fixes
		- baby cube spawn fix

- Feb 27 4.4
		- safexy rework (create range = min 160) - random circle
		- green avoid reduced to 1.2 from 1.25
		- particle draw speedup
		- added grid 9 (dense blue mesh) back in
		- icon

- Feb 26 4.3
		- particle glow - group line/image draws
		- eobet's solid player gfx
		- secure score table - coded info on settings
		- added glow to player trail
		- added back in the code from Feb 16 3.2 (powersave mode disable)
		and rebuilt modules - seems to work here - needs testing
		- fuseball's modified deadzone zeroing
		
- Feb 26 4.2
		- taumel's enhanced particle glow
		- grid pattern organize
		- grid, stars, particle, colours added to video menu
		

- Feb 24 4.1
		- fix hiscore entry with joypad
		- minor menu fixes (centering)
		- changes to bomb display (mentil)
		- P for pause (Hold P and press O for single stepping) in cheatmode only
		- frame timer display in cheatmode
		- another particle effect (taumel)
		- color cycle on the shield
		- bump the max players in reserve to 9

- Feb 23 4.0
		- more grid updates - taumel
		- modified menu/mouse behaviour
		- more screen and playfield sizes
		- limit max shield size
		- re-jig early spawning patterns

- Feb 22 3.9
		- slow down the green avoidance
		- new hybrid mode (cursor around player) + fire keys too
		- more resolutions and playfield sizes
		- add windowed on/off to game menu

- Feb 21 3.8
		- added nobloom/solid gfx from svrman
		- increased grid dimensions for max resolutions / 4
		- moved the automatic 180 scaling out to config
		- added taumel's new grid patterns 
		
- Feb 20 3.7
		- removed thecall to GetGfxModes() which was crashing
		on many PCs - reverted back to fixed list of resolutions
		(If I'm missing any common ones, let me know)
		- reduced points powerup value to 2000
		
- Feb 19 3.6
		- scale menus based on screen res
		- separated the playfield list from screen size list
		- set playfield to whatever size you like in config

- Feb 18 3.5
		- sun/gravity tweaks
		- menu mouse stuff
		- new hybrid mode changes
		- sun debris born with smaller freeze time
		- all available screen resolutions	

- Feb 17 3.4
		- some grid optimizations from taumel
		- removed 60Hz from monitor check
		- added mouse input to options menus
				

- Feb 17 V3.3
		- fix free man cap to 9 not 8
		- speed adjustments all around
		- gravity effect visuals
		- added this readme file
				
- Feb 16 V3.2
		- separate snake head/tail gfx
		- another particle effect
		- low/med/high graphics selection
		- added 1280X800
		- added the following to   glgraphics.win32.c  at line 84
		
/* added Feb 16, 2006 - MI start */
/* prevent screensaver and powersave coming 
   on during fullscreen with joy input only */		
	case WM_SYSCOMMAND:
		if (wp==SC_SCREENSAVE) return 1;
		if (wp==SC_MONITORPOWER) return 1;
		break;		
/* added Feb 16, 2006 - MI end */		

Update: Trying this instead

Import "-luser32"
Extern "win32"
	Function SystemParametersInfoW(stuff1:Int,Stuff2:Int,Stuff3:Int,Stuff4:Int) = "SystemParametersInfoW@16"
EndExtern
Const SPI_SETSCREENSAVEACTIVE:Int = 17
Const SPIF_SENDWININICHANGE:Int = 2
SystemParametersInfoW(SPI_SETSCREENSAVEACTIVE, 0, Null, SPIF_SENDWININICHANGE)

		- check if gfx setting available before trying
		- if a game setting change ends game - enter score in correct table

				
		
- Feb 15 3.1
		- fixed missing range check in SafeXY
		- added 1920X1200 screen/playfield sizes
		- parallax star brightness 
		- removed TAB quick-exit

- Feb 14 3.0
		- brighter particle, doubled up
		- fixes to player/bomb display
		- bomb/player cap at 9
		- sped up medium difficulty
		
- Feb 14 2.9
		- biger/flashier mouse target
		- reduced shot png to 32X32
		- F7 toggles debug
		- Full grid - on/off
		
- Feb 14 2.8
		- enhanced bloom gfx (Tamuel)
		- bouncy shots
		- minor gravity tweaks
		- more functionality in hi-score name entry (Rev)
		- particle lines/img toggle (F6)

- Feb 13 2.7
		- debug mode (evils shot style)
		- some diff gfx from tamuel
		- diff behaviour for gravity particles
		- particledecay (0.1 to 0.9999)  0.95 is normal, .96 slower
		- ESC in menus
		- menu alignments
		- move mouse to 0,0 to keep screen saver away?
		
- Feb 12 2.6
		- fixes to size stuff
		- easy/med/hard fixes (xtra lives, bombs, shot#)
		- (menu work still todo)
		- added tamuel's groovy grid stuff
		- #, letter key entry for high scores
		- particle gravity (F5 on/off)
		- particle count (100-10000)
		- particle life (20-200) 
		- game reset confirm

- Feb 11 2.5
		- scroll on/off
		- screen and playfield size options
		(reloads gfx after screen size change)
		- F4 toggles through 0,100,200,...1000 stars
		- super shots (only destroyed by walls)
		- more gravity/pull
		- hi score entry tweaks
		- fixes to edge of grid
		- speed adjustments

- Feb 10 2.4
		- sound pan
		- multiplier amounts changed
		- more player pull 
		- blackhole bonus score changes
		
		
- Feb 9  2.3
		- increase alpha of points
		- increase names to 8 characters, allow 32-126
		- added easy/med/hard score tables
		- changed grid to hilight every 4th line, 16*4 pixels wide
		- adjust scroll box even smaller
		- bonus player and bombs awarded as powerups
		- default move keys WASD
		grid styles (F3 cycles through)  
		0 = dots, 			1 = rainbow dots
		2 = minimal lines,	3 = rainbow minimal lines
		4 = max lines, 		5 = rainbow max lines
		6 = checkerboard,	7 = rainbow checkerboard
		8 = none
		colour(r,g,b 0-255) and opacity(0-100) set in the config file
		- fixed sfx for shot hitting edge
		- fixed checkerboard grid
		- fixed exit program (no longer pops up save hi-score)
		- fireworks tweaks
		- F4 toggles stars on/off
		- cube woble adjustments
		
- Feb 9  2.2 
		- alpha fixes
		- message display stuff
		- fine tune minimal grid display
		- tweak some gfx
		- add sfx for shot hitting edge
		- add confirm for End Game

- Feb 8  2.1
		- keep previous name
		- various gxoff, gyoff fixes
		- powerups seek toward player
		- parallax stars
		- points display
		- account for playfield in hybrid code

- Feb 7   2.0
		- bigger playfield

- Feb 6	  1.9
		- split main file up - added control.bmx
		- re-jig the sunloop sound stuff
		- allow style to go to 8 (no grid)
		- menus use static background
		- added GL Quad Lines

- Feb 6   1.8
		- the GL build
		- minor changes to sun explosion
		- grid color/lines info saved
		- new image for whitestar

- Feb 2   1.7
		- black holes grow faster as gcount increments
		- mouse sensitivity work
		- inertia work
		- purple cube movement adjustments
		- player death disrupts grid
		- powerup birth pokes grid
		- mouse buttons assignable
		- delay time fixed in all routines
		
- Feb 2   1.6b
		- fixed dual config screen stuff

- Feb 1   1.6
		- updated more gfx (svrman)
		- changed size of whitestar to 49X49
		to avoid scaling it each time
		- snakes form from 1 spot
		- cycle colours grid/line - F3 
		(rainbow dots/rainbow lines/fixed dots/fixed lines)
		- grid colour and opacity in config -opacity means rainbow!
		- sun repels shots
		- use filtered images
		- birth locations moved toward center
		- sun explosion debris is faster
		- more gfx tweaks (snake, triangle)
		- purple cube swirl modified
		- optional inertia
		- mouse sensitivity
		- can press option during get ready
		- moved autofire to Game settings
		
		
- Jan 31  1.5
		- added axis12,13,14,15
		- more push to triangles when shot

- Jan 30  1.4
		- assign bomb and option buttons for joys
		- music (PC only at the moment)
		- fixed button issues
		- more polish
		- fixed music/sfx volume settings save/load
		- fixed more menu issues
		- added End Game option

- Jan 29  1.2
		- faster particles
		- gravity changes
		- fixes to settings/menus
		- shot speed adjustments
		- sfx tweaks
		- friends and enemies screens

- Jan 26  1.1
		- faster shots
		- tweak powerups again
		- more gravity
		- keyboard config read fix

- Jan 25  1.0
		- fixes to config save/load
		- added dead band to analog controls
		- bigger bomb effect
		- fade top and bottom when player near
		- no red spawners
		- more indigo triangles instead
		- red clones don't have shields up at birth
		- max 8 clones at once
		- no sun spawners
		- power up changes (again)
		- difficulty settings adjusted (HARD is now harder)
		- bonded triangles pushed by shots

- Jan 23
		- improved grid effects 
		- powerup gfx changes (thx svrman)
		- powerup birth timing changes (po*mult*mult)
		- New circle gfx (thx svrman)
		- shots push grid
		- sun pulls grid
		- split into multiple files
		
- Jan 21
		- shield powerup
		- control fixes
		- more particles
		- shot fragments
		- shot image
		- joypad config screen
		- mouse config screen
		- hybrid config screen

- Jan 19
		- images
		- powerup changes
		- timed side And back shooters
		- particle array[1000]- Object reuse, counter
		- hybrid control  keys-move, mouse aim/fire
		
- Jan 18
		- re-arrange sfx load stuff, cleanup
				
- Jan 17
		- prelim keyboard/mouse/joypad controls
		- red sun behaviour changes (blackhole)
		- player trail
		- increased deadband to 0.05

- Jan 16
		- deadzone (centering) for each axis
		- tweaks to grid
		
- Jan 14/15
		- generators flash when birthing
		- fixed up various generator images
		- fireworks to intro
		- sound volume
		- bonus keyed to what's needed
		- bonus destruct & mutate
		- speed fixes various enemies
		- colour changes
		
- Jan 13b
		- changes to particles
		- save/load sfx,music settings

- Jan 13
		- more fixes
		- score table, times
		- fancy title
		- powerup changes
		- button check fixes
		
- Jan 12
		- sfx for clone
		- added scaling to controllers
		- fixed buggy controller stuff
		- fixed sound crashes
		- title screen
		- hi score table
		- some error checking on the config file
		
- Jan 11
		- controller setttings 
		(based on code from archives at BlitzBasic.com by
		Troy Robinson  aka Pongo - stormwind@yahoo.com)

- Jan 10 
		- snake & clone fixes
		- save config
		- spawning changes
- Jan 9 
		- clone shield
- Jan 8 
		- evil clone
		- butterflies
- Jan 7 
		- snakes added
- Jan 4
		- powerups
- Jan 2
		- pink pinwheels

- Dec 30
		- generators

- Dec 28
		- blue circles
		- orange triangles

- Dec 23
		- Suns

- Dec 22
		- green squares
		- purple squares
		- blue diamonds

- Dec 21
		- started!
		- player
		- grid
		- particles
				
