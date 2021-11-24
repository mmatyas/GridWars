SuperStrict

Import PUB.FreeJoy
Import BRL.Volumes
Import BRL.FileSystem

Import "sound.bmx"
Import "gridparttrail.bmx"
Import "vectorfont.bmx"


Global g_style:Int = 0
Global info$ = " "
Global infotimer:Int
Global mx:Int,my:Int
Global ax:Int
Global assigning:Int = False
Global assigningoption:Int = False
Global assigningbomb:Int = False
Global bombtime:Int = 30
Global jdmx# = 0
Global jdmy# = 0
Global jdfx# = 0
Global jdfy# = 0
Global playgame:Int = False
Global startingdifficulty:Int = 1
Global laststartingdifficulty:Int = 1
Global numplayers:Int = 3
Global numbombs:Int = 3
Global EXTRALIFE:Int = 100000
Global POWERUP:Int = 2500
Global EXTRABOMB:Int = 150000
Global mbut$[] = ["None", "Left", "Right", "Middle"]
Global onoff$[] = ["Off","On"]
Global difficulty$[] = ["Easy","Medium","Hard"]
Global NUMGFXSETS:Int = 5-1
Global lowmedhigh$[] = ["Solid","Low","Med","High","User"]
Global soundsets$[] = ["Original", "User"]

Global exbomb:Int[] = [100000,150000,250000]
Global exlife:Int[] = [75000,100000,200000]


Type bbjoypad
	Field x1id:Int
	Field y1id:Int
	Field x2id:Int
	Field y2id:Int
	Field x1invert:Int
	Field y1invert:Int
	Field x2invert:Int
	Field y2invert:Int
	Field x1scale#
	Field y1scale#
	Field x2scale#
	Field y2scale#
	Field x1center#
	Field y1center#
	Field x2center#
	Field y2center#
	Field x1dz#
	Field y1dz#
	Field x2dz#
	Field y2dz#
	Field optionbutton%
	Field bombbutton%
End Type

Global j:bbjoypad[4]

For Local port:Int = 0 To 3
	j[port] = New bbjoypad
	j[port].x1id = 1
	j[port].y1id = 2
	j[port].x2id = 4
	j[port].y2id = 3
	j[port].x1invert = 1 'toggles between 1 And -1
	j[port].y1invert = 1
	j[port].x2invert = 1
	j[port].y2invert = 1
	j[port].x1scale# = 1
	j[port].y1scale# = 1
	j[port].x2scale# = 1
	j[port].y2scale# = 1
	j[port].x1center# = 0
	j[port].y1center# = 0
	j[port].x2center# = 0
	j[port].y2center# = 0
	j[port].x1dz# = 0
	j[port].y1dz# = 0
	j[port].x2dz# = 0
	j[port].y2dz# = 0
	j[port].optionbutton% = 1
	j[port].bombbutton% = 2
Next

Global joy_label$[16]
joy_label[0] = "null"
joy_label[1] = "JoyX()"
joy_label[2] = "JoyY()"
joy_label[3] = "JoyZ()"
joy_label[4] = "JoyR()"
joy_label[5] = "JoyU()"
joy_label[6] = "JoyV()"
joy_label[7] = "JoyYaw()"
joy_label[8] = "JoyPitch()"
joy_label[9] = "JoyRoll()"
joy_label[10] = "JoyHat()"
joy_label[11] = "JoyWheel()"
joy_label[12] = "JoyAxis12()"
joy_label[13] = "JoyAxis13()"
joy_label[14] = "JoyAxis14()"
joy_label[15] = "JoyAxisl5()"

Global control_method$[5]
control_method[0] = "Dual Analog"
control_method[1] = "Mouse"
control_method[2] = "Keyboard"
control_method[3] = "Joypad"
control_method[4] = "Hybrid"


'defaults
Global controltype:Int = 0
Global deadbandadjust:Int  = 0

Global joyport:Int = 0
Global autofire:Int = 0

Global axis_move_x:Int = 0
Global axis_move_y:Int = 1
Global axis_fire_x:Int = 3
Global axis_fire_y:Int = 2
Global axis_move_x_inv:Int = 1   '1 or -1
Global axis_move_y_inv:Int = 1
Global axis_fire_x_inv:Int = 1
Global axis_fire_y_inv:Int = 1
Global axis_move_x_sc# = 1   '1, 128, 255
Global axis_move_y_sc# = 1
Global axis_fire_x_sc# = 1
Global axis_fire_y_sc# = 1
Global axis_move_x_center# = 0   '-0.9 to .9
Global axis_move_y_center# = 0
Global axis_fire_x_center# = 0
Global axis_fire_y_center# = 0
Global axis_move_x_dz# = 0.05
Global axis_move_y_dz# = 0.05
Global axis_fire_x_dz# = 0.05
Global axis_fire_y_dz# = 0.05
Global j_d_bomb:Int = 5
Global j_d_option:Int = 4

Global h_config:Int = 0

Global j_config:Int = 0
Global j_pad_1:Int = 0
Global j_pad_2:Int = 1
Global j_pad_3:Int = 2
Global j_pad_4:Int = 3
Global j_pad_bomb:Int = 4
Global j_pad_option:Int = 0

Global k_bomb:Int = KEY_SPACE
Global k_move_left:Int = KEY_S
Global k_move_right:Int = KEY_D
Global k_move_up:Int = KEY_E
Global k_move_down:Int = KEY_X
Global k_fire_left:Int = KEY_LEFT
Global k_fire_right:Int = KEY_RIGHT
Global k_fire_up:Int = KEY_UP
Global k_fire_down:Int = KEY_DOWN

Global m_sensitivity# = .5
Global m_bomb:Int = 2
Global m_fire:Int = 1
Global inertia# = 0.0




Function DrawTarget(x%,y%,cnt%,sz%=7)

	If cnt Mod 30 > 14
		SetColor 255,255,32
	Else
		SetColor 255,32,32
	EndIf
'	DrawLine x-12,y,x+12,y
'	DrawLine x,y-12,x,y+12

	For Local a%=0 Until 359 Step 45
		SetRotation ((cnt*8) Mod 360)+a
		DrawLine x-sz,y-sz,x+sz,y+sz
	Next
	SetRotation 0

End Function


Function CheckConfDir:Int()
	Local ft:Int, confdir$

	confdir$=GetUserHomeDir()+"/.config/gridwars"
	ft = FileType(confdir)
	if ft = 2
		Return True
	Else
		Local success:Int = CreateDir(confdir, True)
		If Not success Then
			info$ = "Config directory creation failed."
			infotimer = 30*4
			Return False
		EndIf
	EndIf

End Function

Function LoadConfig:Int()

	Local fh:TStream, fn$, hdir$
	Local pv$, pm$

	hdir$=GetUserHomeDir()
	fn$ = hdir+"/.config/gridwars/Config.txt"
	fh = OpenFile(fn$)
	If fh <> Null
		While Not Eof(fh)
			' read each line
			pm$ = ReadLine(fh)
			pv$ = ReadLine(fh)
			Select pm$
				Case "[Windowed]"
					If Pv.toupper() = "TRUE"
						windowed = True
					Else
						windowed = False
					EndIf
				Case "[Control Type]"
					If Pv.toupper() = control_method[0].toupper()
						controltype = 0 'dual analog
					ElseIf Pv.toupper() = control_method[1].toupper()
						controltype = 1 'mouse
					ElseIf Pv.toupper() = control_method[2].toupper()
						controltype = 2 'keys
					ElseIf Pv.toupper() = control_method[3].toupper()
						controltype = 3	'joypad
					ElseIf Pv.toupper() = control_method[4].toupper()
						controltype = 4	'hybrid
					EndIf
				Case "[Autofire]"
					autofire = Int(pv$)

				Case "[Hybrid Config]"
					h_config = Int(pv$)

				Case "[Joypad Config]"
					j_config = Int(pv$)
				Case "[Joypad Left]"
					j_pad_1 = Int(pv$)
				Case "[Joypad Up]"
					j_pad_2 = Int(pv$)
				Case "[Joypad Right]"
					j_pad_3 = Int(pv$)
				Case "[Joypad Down]"
					j_pad_4 = Int(pv$)
				Case "[Joypad Option]"
					j_pad_option = Int(pv$)
				Case "[Joypad Bomb]"
					j_pad_bomb = Int(pv$)

				Case "[Key Bomb]"
					k_bomb = Int(pv$)
				Case "[Key Move Left]"
					k_move_left = Int(pv$)
				Case "[Key Move Right]"
					k_move_right = Int(pv$)
				Case "[Key Move Up]"
					k_move_up = Int(pv$)
				Case "[Key Move Down]"
					k_move_down = Int(pv$)
				Case "[Key Fire Left]"
					k_fire_left = Int(pv$)
				Case "[Key Fire Right]"
					k_fire_right = Int(pv$)
				Case "[Key Fire Up]"
					k_fire_up = Int(pv$)
				Case "[Key Fire Down]"
					k_fire_down = Int(pv$)

				Case "[SFX Volume]" '0-100
					sfxvol# = Float(pv$)/100.0
				Case "[Music Volume]" '0-100
					musicvol# = Float(pv$)/100.0
				Case "[Sound Set]"
					soundset = Int(pv$)
					If soundset < 0 Or soundset > 1 Then soundset = 0

				Case "[Grid Style]"
					g_style = Int(pv$)

				Case "[Grid Red]"
					g_red = Int(pv$)
				Case "[Grid Green]"
					g_green = Int(pv$)
				Case "[Grid Blue]"
					g_blue = Int(pv$)
				Case "[Grid Opacity]" '0-100
					g_opacity# = Float(pv$)/100.0
				Case "[Grid Spacing]"
					gridsize = Int(pv$)
				Case "[Full Grid]"
					fullgrid = Int(pv$)
					If fullgrid < 0 Or fullgrid > 1 Then fullgrid = 0
				Case "[Gfx Set]"
					gfxset = Int(pv$)
					If gfxset < 0 Or gfxset > NUMGFXSETS Then gfxset = 0

				Case "[Mouse Sensitivity]"
					m_sensitivity = Float(pv$)/100.0
				Case "[Mouse Fire]"
					m_fire = Int(pv$)
				Case "[Mouse Bomb]"
					m_bomb = Int(pv$)

				Case "[Show Stars]"
					showstars = Int(pv$)
				Case "[Scroll]"
					scroll = Int(pv$)
				Case "[Playfield Width]"
					playsizew = Int(pv$)
				Case "[Playfield Height]"
					playsizeh = Int(pv$)
				Case "[Screen Width]"
					screensizew = Int(pv$)
				Case "[Screen Height]"
					screensizeh = Int(pv$)

				Case "[Particle Count]"
					numparticles = Int(pv$)
					If numparticles > MAXPARTICLES Then numparticles = MAXPARTICLES
				Case "[Particle Life]"
					particlelife = Int(pv$)
					If particlelife > 500 Then particlelife = 500
				Case "[Particle Gravity]"
					gravityparticles = Int(pv$)
				Case "[Particle Decay]"
					particledecay# = Float(pv$)
					If particledecay < .01 Then particledecay = .01
					If particledecay > .9999 Then particledecay = .9999
				Case "[Particle Style]"
					particlestyle = Int(pv$)

				Case "[Difficulty]"
					startingdifficulty = Int(pv$)

				Case "[Inertia]"
					inertia# = Float(pv$)/100.0

				Case "[Used Port]"
					joyport = Int(pv$)
				Case "[Joy Port]"
					Local port:Int = Int(pv$)
					For Local t:Int = 0 To 21
						Local ax$ = ReadLine(fh)
						Local cn$ = ReadLine(fh)
						Select ax$
							Case "[Joy Move X]"
								j[port].x1id = Int(cn$)
							Case "[Joy Move Y]"
								j[port].y1id = Int(cn$)
							Case "[Joy Fire X]"
								j[port].x2id = Int(cn$)
							Case "[Joy Fire Y]"
								j[port].y2id = Int(cn$)

							Case "[Joy Move X Inverted]"
								j[port].x1invert = Int(cn$)
								If Abs(j[port].x1invert) <> 1 Then j[port].x1invert = 1
							Case "[Joy Move Y Inverted]"
								j[port].y1invert = Int(cn$)
								If Abs(j[port].y1invert) <> 1 Then j[port].y1invert = 1
							Case "[Joy Fire X Inverted]"
								j[port].x2invert = Int(cn$)
								If Abs(j[port].x2invert) <> 1 Then j[port].x2invert = 1
							Case "[Joy Fire Y Inverted]"
								j[port].y2invert = Int(cn$)
								If Abs(j[port].y2invert) <> 1 Then j[port].y2invert = 1

							Case "[Joy Move X Scale]"
								j[port].x1scale = Int(cn$)
								If j[port].x1scale = 0 Then j[port].x1scale = 1
							Case "[Joy Move Y Scale]"
								j[port].y1scale = Int(cn$)
								If j[port].y1scale = 0 Then j[port].y1scale = 1
							Case "[Joy Fire X Scale]"
								j[port].x2scale = Int(cn$)
								If j[port].x2scale = 0 Then j[port].x2scale = 1
							Case "[Joy Fire Y Scale]"
								j[port].y2scale = Int(cn$)
								If j[port].y2scale = 0 Then j[port].y2scale = 1

							Case "[Joy Move X Center]"
								j[port].x1center = Float(cn$)
								If Abs(j[port].x1center) > 1 Then j[port].x1center = 0
							Case "[Joy Move Y Center]"
								j[port].y1center = Float(cn$)
								If Abs(j[port].y1center) > 1 Then j[port].y1center = 0
							Case "[Joy Fire X Center]"
								j[port].x2center = Float(cn$)
								If Abs(j[port].x2center) > 1 Then j[port].x2center = 0
							Case "[Joy Fire Y Center]"
								j[port].y2center = Float(cn$)
								If Abs(j[port].y2center) > 1 Then j[port].y2center = 0

							Case "[Joy Move X Dead Zone]"
								j[port].x1dz = Float(cn$)
								If Abs(j[port].x1dz) > 1 Then j[port].x1dz = 0
							Case "[Joy Move Y Dead Zone]"
								j[port].y1dz = Float(cn$)
								If Abs(j[port].y1dz) > 1 Then j[port].y1dz = 0
							Case "[Joy Fire X Dead Zone]"
								j[port].x2dz = Float(cn$)
								If Abs(j[port].x2dz) > 1 Then j[port].x2dz = 0
							Case "[Joy Fire Y Dead Zone]"
								j[port].y2dz = Float(cn$)
								If Abs(j[port].y2dz) > 1 Then j[port].y2dz = 0
							Case "[Joy Option]"
								j[port].optionbutton = Int(cn$)
							Case "[Joy Bomb]"
								j[port].bombbutton = Int(cn$)

						End Select
					Next
			End Select
		Wend
		info$ = "Config file loaded."
		infotimer = 30*4
		CloseFile fh
		Return True
	Else
		info$ = "Config load failed."
		infotimer = 30*4
		Return False
	EndIf

End Function




Function SaveConfig:Int()

	Local fh:TStream, fn$, hdir$

	hdir$=GetUserHomeDir()
	fn$ = hdir+"/.config/gridwars/Config.txt"
	fh = WriteFile(fn$)
	If fh <> Null
		WriteLine (fh,"[Windowed]")
		If windowed
			WriteLine(fh,"True")
		Else
			WriteLine(fh,"False")
		EndIf
		WriteLine(fh,"[Control Type]")
		WriteLine(fh,control_method[controltype])

		WriteLine(fh,"[Hybrid Config]")
		WriteLine(fh,h_config)

		WriteLine(fh,"[Joypad Config]")
		WriteLine(fh,j_config)
		WriteLine(fh,"[Joypad Left]")
		WriteLine(fh,j_pad_1)
		WriteLine(fh,"[Joypad Up]")
		WriteLine(fh,j_pad_2)
		WriteLine(fh,"[Joypad Right]")
		WriteLine(fh,j_pad_3)
		WriteLine(fh,"[Joypad Down]")
		WriteLine(fh,j_pad_4)
		WriteLine(fh,"[Joypad Option]")
		WriteLine(fh,j_pad_option)
		WriteLine(fh,"[Joypad Bomb]")
		WriteLine(fh,j_pad_bomb)

		WriteLine(fh,"[Autofire]")
		WriteLine(fh,autofire)

		WriteLine(fh,"[Key Bomb]")
		WriteLine(fh,k_bomb)
		WriteLine(fh,"[Key Move Left]")
		WriteLine(fh,k_move_left)
		WriteLine(fh,"[Key Move Right]")
		WriteLine(fh,k_move_right)
		WriteLine(fh,"[Key Move Up]")
		WriteLine(fh,k_move_up)
		WriteLine(fh,"[Key Move Down]")
		WriteLine(fh,k_move_down)
		WriteLine(fh,"[Key Fire Left]")
		WriteLine(fh,k_fire_left)
		WriteLine(fh,"[Key Fire Right]")
		WriteLine(fh,k_fire_right)
		WriteLine(fh,"[Key Fire Up]")
		WriteLine(fh,k_fire_up)
		WriteLine(fh,"[Key Fire Down]")
		WriteLine(fh,k_fire_down)

		WriteLine(fh,"[SFX Volume]")
		WriteLine(fh,Int(sfxvol#*100))
		WriteLine(fh,"[Music Volume]")
		WriteLine(fh,Int(musicvol#*100))
		WriteLine(fh,"[Sound Set]")
		WriteLine(fh,soundset)

		WriteLine(fh,"[Grid Style]")
		WriteLine(fh,g_style)

		WriteLine(fh,"[Grid Red]")
		WriteLine(fh,g_red)
		WriteLine(fh,"[Grid Green]")
		WriteLine(fh,g_green)
		WriteLine(fh,"[Grid Blue]")
		WriteLine(fh,g_blue)
		WriteLine(fh,"[Grid Opacity]")
		WriteLine(fh,Int(g_opacity#*100))
		WriteLine(fh,"[Grid Spacing]")
		WriteLine(fh,gridsize)
		WriteLine(fh,"[Full Grid]")
		WriteLine(fh,fullgrid)
		WriteLine(fh,"[Gfx Set]")
		WriteLine(fh,gfxset)

		WriteLine(fh,"[Show Stars]")
		WriteLine(fh,showstars)
		WriteLine(fh,"[Scroll]")
		WriteLine(fh,scroll)

		WriteLine(fh,"[Playfield Width]")
		WriteLine(fh,playsizew)
		WriteLine(fh,"[Playfield Height]")
		WriteLine(fh,playsizeh)
		WriteLine(fh,"[Screen Width]")
		WriteLine(fh,screensizew)
		WriteLine(fh,"[Screen Height]")
		WriteLine(fh,screensizeh)

		WriteLine(fh,"[Particle Count]")
		WriteLine(fh,numparticles)
		WriteLine(fh,"[Particle Life]")
		WriteLine(fh,particlelife)
		WriteLine(fh,"[Particle Gravity]")
		WriteLine(fh,gravityparticles)
		WriteLine(fh,"[Particle Decay]")
		WriteLine(fh,particledecay)
		WriteLine(fh,"[Particle Style]")
		WriteLine(fh,particlestyle)

		WriteLine(fh,"[Mouse Sensitivity]")
		WriteLine(fh,Int(m_sensitivity#*100))
		WriteLine(fh,"[Mouse Fire]")
		WriteLine(fh,m_fire)
		WriteLine(fh,"[Mouse Bomb]")
		WriteLine(fh,m_bomb)

		WriteLine(fh,"[Difficulty]")
		WriteLine(fh,startingdifficulty)

		WriteLine(fh,"[Inertia]")
		WriteLine(fh,Int(inertia#*100))

		WriteLine(fh,"[Used Port]")
		WriteLine(fh, joyport)
		For Local port:Int = 0 To 3
			WriteLine(fh,"[Joy Port]")
			WriteLine(fh, port)
			WriteLine(fh,"[Joy Move X]")
			WriteLine(fh,j[port].x1id)
			WriteLine(fh,"[Joy Move Y]")
			WriteLine(fh,j[port].y1id)
			WriteLine(fh,"[Joy Fire X]")
			WriteLine(fh,j[port].x2id)
			WriteLine(fh,"[Joy Fire Y]")
			WriteLine(fh,j[port].y2id)

			WriteLine(fh,"[Joy Move X Inverted]")
			WriteLine(fh,j[port].x1invert)
			WriteLine(fh,"[Joy Move Y Inverted]")
			WriteLine(fh,j[port].y1invert)
			WriteLine(fh,"[Joy Fire X Inverted]")
			WriteLine(fh,j[port].x2invert)
			WriteLine(fh,"[Joy Fire Y Inverted]")
			WriteLine(fh,j[port].y2invert)

			WriteLine(fh,"[Joy Move X Scale]")
			WriteLine(fh,Int(j[port].x1scale))
			WriteLine(fh,"[Joy Move Y Scale]")
			WriteLine(fh,Int(j[port].y1scale))
			WriteLine(fh,"[Joy Fire X Scale]")
			WriteLine(fh,Int(j[port].x2scale))
			WriteLine(fh,"[Joy Fire Y Scale]")
			WriteLine(fh,Int(j[port].y2scale))

			WriteLine(fh,"[Joy Move X Center]")
			WriteLine(fh,(j[port].x1center))
			WriteLine(fh,"[Joy Move Y Center]")
			WriteLine(fh,(j[port].y1center))
			WriteLine(fh,"[Joy Fire X Center]")
			WriteLine(fh,(j[port].x2center))
			WriteLine(fh,"[Joy Fire Y Center]")
			WriteLine(fh,(j[port].y2center))

			WriteLine(fh,"[Joy Move X Dead Zone]")
			WriteLine(fh,j[port].x1dz)
			WriteLine(fh,"[Joy Move Y Dead Zone]")
			WriteLine(fh,j[port].y1dz)
			WriteLine(fh,"[Joy Fire X Dead Zone]")
			WriteLine(fh,j[port].x2dz)
			WriteLine(fh,"[Joy Fire Y Dead Zone]")
			WriteLine(fh,j[port].y2dz)

			WriteLine(fh,"[Joy Option]")
			WriteLine(fh,j[port].optionbutton)
			WriteLine(fh,"[Joy Bomb]")
			WriteLine(fh,j[port].bombbutton)

		Next
		info$ = "Config file saved."
		infotimer = 30*4
		CloseFile fh
		Return True
	Else
		Return False
	EndIf
End Function




Function SaveColours:Int()

	Local fh:TStream, fn$, hdir$

	hdir$=GetUserHomeDir()
	fn$ = hdir+"/.config/gridwars/Colours.txt"
	fh = WriteFile(fn$)
	If fh <> Null
		WriteLine(fh,"squares")
		WriteLine(fh,COL_SQUARE_R)
		WriteLine(fh,COL_SQUARE_G)
		WriteLine(fh,COL_SQUARE_B)
		WriteLine(fh,"pinwheels")
		WriteLine(fh,COL_PIN_R)
		WriteLine(fh,COL_PIN_G)
		WriteLine(fh,COL_PIN_B)
		WriteLine(fh,"diamonds")
		WriteLine(fh,COL_DIAMOND_R)
		WriteLine(fh,COL_DIAMOND_G)
		WriteLine(fh,COL_DIAMOND_B)
		WriteLine(fh,"cubes")
		WriteLine(fh,COL_CUBE_R)
		WriteLine(fh,COL_CUBE_G)
		WriteLine(fh,COL_CUBE_B)
		WriteLine(fh,"circles")
		WriteLine(fh,COL_SEEKER_R)
		WriteLine(fh,COL_SEEKER_G)
		WriteLine(fh,COL_SEEKER_B)
		WriteLine(fh,"butterflies")
		WriteLine(fh,COL_BUTTER_R)
		WriteLine(fh,COL_BUTTER_G)
		WriteLine(fh,COL_BUTTER_B)
		WriteLine(fh,"blackholes")
		WriteLine(fh,COL_SUN_R)
		WriteLine(fh,COL_SUN_G)
		WriteLine(fh,COL_SUN_B)
		WriteLine(fh,"clone")
		WriteLine(fh,COL_CLONE_R)
		WriteLine(fh,COL_CLONE_G)
		WriteLine(fh,COL_CLONE_B)
		WriteLine(fh,"snake head")
		WriteLine(fh,COL_SNAKE_R)
		WriteLine(fh,COL_SNAKE_G)
		WriteLine(fh,COL_SNAKE_B)
		WriteLine(fh,"snake tail")
		WriteLine(fh,COL_TAIL_R)
		WriteLine(fh,COL_TAIL_G)
		WriteLine(fh,COL_TAIL_B)
		WriteLine(fh,"triangles")
		WriteLine(fh,COL_TRIANGLE_R)
		WriteLine(fh,COL_TRIANGLE_G)
		WriteLine(fh,COL_TRIANGLE_B)
		WriteLine(fh,"player")
		WriteLine(fh,COL_PLAYER_R)
		WriteLine(fh,COL_PLAYER_G)
		WriteLine(fh,COL_PLAYER_B)
		WriteLine(fh,"shots")
		WriteLine(fh,COL_SHOT_R)
		WriteLine(fh,COL_SHOT_G)
		WriteLine(fh , COL_SHOT_B)
		WriteLine(fh,"super shots")
		WriteLine(fh,COL_SHOT1_R)
		WriteLine(fh,COL_SHOT1_G)
		WriteLine(fh,COL_SHOT1_B)
		WriteLine(fh,"bouncy shots")
		WriteLine(fh,COL_SHOT2_R)
		WriteLine(fh,COL_SHOT2_G)
		WriteLine(fh , COL_SHOT2_B)
		WriteLine(fh,"bomb")
		WriteLine(fh,COL_BOMB_R)
		WriteLine(fh,COL_BOMB_G)
		WriteLine(fh,COL_BOMB_B)
		WriteLine(fh,"scores")
		WriteLine(fh,COL_SCORE_R)
		WriteLine(fh,COL_SCORE_G)
		WriteLine(fh,COL_SCORE_B)
		WriteLine(fh,"powerups")
		WriteLine(fh,COL_POWERUP_R)
		WriteLine(fh,COL_POWERUP_G)
		WriteLine(fh,COL_POWERUP_B)
		WriteLine(fh,"trail")
		WriteLine(fh,COL_TRAIL_R)
		WriteLine(fh,COL_TRAIL_G)
		WriteLine(fh,COL_TRAIL_B)

		info$ = "Colour file saved."
		infotimer = 30*4
		CloseFile fh
		Return True
	Else
		Return False
	EndIf

End Function



Function LoadColours:Int()

	Local fh:TStream, fn$, hdir$
	Local com$

	hdir$=GetUserHomeDir()
	fn$ = hdir+"/.config/gridwars/Colours.txt"
	fh = OpenFile(fn$)
	If fh <> Null
		com$ = ReadLine(fh)
		COL_SQUARE_R = Int(ReadLine(fh))
		COL_SQUARE_G = Int(ReadLine(fh))
		COL_SQUARE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_PIN_R = Int(ReadLine(fh))
		COL_PIN_G = Int(ReadLine(fh))
		COL_PIN_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_DIAMOND_R = Int(ReadLine(fh))
		COL_DIAMOND_G = Int(ReadLine(fh))
		COL_DIAMOND_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_CUBE_R = Int(ReadLine(fh))
		COL_CUBE_G = Int(ReadLine(fh))
		COL_CUBE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SEEKER_R = Int(ReadLine(fh))
		COL_SEEKER_G = Int(ReadLine(fh))
		COL_SEEKER_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_BUTTER_R = Int(ReadLine(fh))
		COL_BUTTER_G = Int(ReadLine(fh))
		COL_BUTTER_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SUN_R = Int(ReadLine(fh))
		COL_SUN_G = Int(ReadLine(fh))
		COL_SUN_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_CLONE_R = Int(ReadLine(fh))
		COL_CLONE_G = Int(ReadLine(fh))
		COL_CLONE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SNAKE_R = Int(ReadLine(fh))
		COL_SNAKE_G = Int(ReadLine(fh))
		COL_SNAKE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_TAIL_R = Int(ReadLine(fh))
		COL_TAIL_G = Int(ReadLine(fh))
		COL_TAIL_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_TRIANGLE_R = Int(ReadLine(fh))
		COL_TRIANGLE_G = Int(ReadLine(fh))
		COL_TRIANGLE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_PLAYER_R = Int(ReadLine(fh))
		COL_PLAYER_G = Int(ReadLine(fh))
		COL_PLAYER_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SHOT_R = Int(ReadLine(fh))
		COL_SHOT_G = Int(ReadLine(fh))
		COL_SHOT_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SHOT1_R = Int(ReadLine(fh))
		COL_SHOT1_G = Int(ReadLine(fh))
		COL_SHOT1_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SHOT2_R = Int(ReadLine(fh))
		COL_SHOT2_G = Int(ReadLine(fh))
		COL_SHOT2_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_BOMB_R = Int(ReadLine(fh))
		COL_BOMB_G = Int(ReadLine(fh))
		COL_BOMB_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_SCORE_R = Int(ReadLine(fh))
		COL_SCORE_G = Int(ReadLine(fh))
		COL_SCORE_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_POWERUP_R = Int(ReadLine(fh))
		COL_POWERUP_G = Int(ReadLine(fh))
		COL_POWERUP_B = Int(ReadLine(fh) )

		com$ = ReadLine(fh)
		COL_TRAIL_R = Int(ReadLine(fh))
		COL_TRAIL_G = Int(ReadLine(fh))
		COL_TRAIL_B = Int(ReadLine(fh) )

		info$ = "Colour file loaded."
		infotimer = 30*4
		CloseFile fh
		Return True
	Else
		info$ = "Colour file load failed."
		infotimer = 30*4
		Return False
	EndIf

End Function







Function CaptureScreen()

	GrabImage(capturedimg,0,0)

End Function

Function DrawAllStatic(sz#=1)

	SetColor 64,64,128
	SetBlend SOLIDBLEND
	If capturedimg <> Null
		SetScale sz,sz
		DrawImage capturedimg,SCREENW/2,SCREENH/2
	EndIf
	SetScale 1,1
End Function



Function Options:Int(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local ret:Int = 0
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 2+showgame
	Local s#,x:Int
	Local ignorejoy:Int
	Local tim:Int
	Local lsp:Int = 40

	If showgame Then CaptureScreen()
	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(1+(showgame>0))+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()
		SetLineWidth 2
		tim = MilliSecs()
		If showgame Then DrawAllStatic(.9)
		SetColor 255,0,0
		DrawString("Options",SCREENW/2-280,SCREENH/2-lsp*3,6)

		If RectsOverlap(xx-8,yy-8,16,16,0, SCREENH/2-lsp,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Exit Program",SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Settings",SCREENW/2-280,SCREENH/2,4)
		If showgame
			If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 2
			If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
			DrawString("End Game",SCREENW/2-280,SCREENH/2+lsp,4)

			If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 3
			If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
			DrawString("Continue",SCREENW/2-280,SCREENH/2+lsp*2,4)
		Else
			If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 2
			If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
			DrawString("Continue",SCREENW/2-280,SCREENH/2+lsp,4)
		EndIf
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		Flip 1
		cnt:+1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 2+showgame
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 2+showgame Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If jdmy <> 0 Then ignorejoy = True
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Or MouseHit(1) Then done = True
		If KeyHit(KEY_ESCAPE) Or KeyHit(KEY_LEFT) Then sel = 2+showgame;done = True;bombtime = 20
		If KeyHit(KEY_RIGHT) Then done = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 10
		If sel = 1 And done = True
			ret = Settings(showgame)
			MoveMouse(SCREENW/2-280-20,SCREENH/2+20)
			done = False
			looper = 0
			bombtime = 20
			If ret = 2 And showgame
				FlushKeys()
				FlushMouse()
				Return 2
			EndIf
		EndIf
		If showgame
			If sel = 2 And done = True
				If conf(showgame,"End Game?")
					bombtime = 20
					FlushKeys()
					FlushMouse()
					Return 2
				Else
					done = False
					bombtime = 20
				EndIf
			EndIf
		EndIf
		If sel = 0 And done = True
			If conf(showgame,"Sure?")
				bombtime = 20
				FlushKeys()
				FlushMouse()
				Return 1
			Else
				done = False
				bombtime = 20
			EndIf
		EndIf
		looper :+8
	Wend
	FlushKeys()
	FlushMouse()
	Return False

End Function



Function conf:Int(showgame:Int, st$="")

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 1
	Local ignorejoy:Int
	Local tim:Int
	Local lsp:Int = 40

	If st$ = "" Then st$ = "Confirm"

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp+10)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.8)

		SetColor 255,0,0
		DrawString(st$,SCREENW/2-280,SCREENH/2-lsp*2,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Yes",SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("No",SCREENW/2-280,SCREENH/2+lsp,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		Flip 1
		cnt:+1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 1
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 1 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf

		If jdmy <> 0 Then ignorejoy = True
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Or KeyHit(KEY_ESCAPE) Or MouseHit(1) Then done = True
		If KeyHit(KEY_RIGHT) Then done = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		looper :+8
	Wend
	If sel = 0 Then Return True Else Return False

End Function



Function Settings:Int(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local ret:Int = 0
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 4
	Local s#,x:Int
	Local ignorejoy:Int
	Local tim:Int
	Local lsp:Int = 40

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*3+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.8)
		SetColor 255,0,0
		DrawString("Settings",SCREENW/2-280,SCREENH/2-lsp*3,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Audio",SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Video",SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Controls",SCREENW/2-280,SCREENH/2+lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Game",SCREENW/2-280,SCREENH/2+lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*3,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		Flip 1
		cnt:+1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 4
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 4 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf

		If jdmy <> 0 Then ignorejoy = True
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Or MouseHit(1) Then done = True
		If KeyHit(KEY_ESCAPE)  Or KeyHit(KEY_LEFT) Then done = True;sel = 4;bombtime = 20
		If KeyHit(KEY_RIGHT) Then done = True

		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True
		If done = True
			Select sel
				Case 0 'audio
					AudioSettings(showgame)
					MoveMouse(SCREENW/2-280-20,SCREENH/2-lsp+20)
					done = False
					looper = 0
					bombtime = 20
				Case 1 'video
					ret = VideoSettings(showgame)
					MoveMouse(SCREENW/2-280-20,SCREENH/2+20)
					done = False
					looper = 0
					bombtime = 20
				Case 2 'controller
					ret = ControllerSettings(showgame)
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp+20)
					SetController()
					done = False
					looper = 0
					bombtime = 20
				Case 3 'game settings
					ret = GameSettings(showgame)
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*2+20)
					done = False
					looper = 0
					bombtime = 20
				Case 4 ' done
					bombtime = 20
			End Select
			FlushKeys()
			FlushMouse()
		EndIf
		looper :+8
	Wend
	Return ret

End Function





Function VideoSettings:Int(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 10 ' done
	Local s#,x:Int
	Local ignorejoy:Int, ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40
	If SCREENH =< 480 Then lsp = 32

	Local old_scroll:Int = scroll
	Local old_screensize:Int = screensize
	Local old_playsize:Int = playsize
	Local old_gfxset:Int = gfxset
	Local old_windowed:Int = windowed
	Local bright# = g_opacity*120
	Local col_pick:Int = 0

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*6+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()
		SetLineWidth 2
		tim = MilliSecs()
		If showgame Then DrawAllStatic(.7)
		SetColor 255,0,0
		DrawString("Video Settings",SCREENW/2-280,SCREENH/2-lsp*6,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*4,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Scroll: "+onoff$[scroll],SCREENW/2-280,SCREENH/2-lsp*4,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*3,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Screen Size: "+(screensize+1)+"/"+numgfxmodes+" "+gfxmodearr[screensize].desc$+" ("+gfxmodearr[screensize].s$+")",SCREENW/2-280,SCREENH/2-lsp*3,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*2,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Playfield Size: "+(playsize+1)+"/"+numplayfieldsizes+" "+playfieldsizes[playsize*2]+"X"+playfieldsizes[playsize*2+1],SCREENW/2-280,SCREENH/2-lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Gfx Set: "+lowmedhigh$[gfxset],SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*0,SCREENW,5*4) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Windowed: "+onoff$[windowed],SCREENW/2-280,SCREENH/2+lsp*0,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*1,SCREENW,5*4) Then sel = 5
		If sel = 5 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Grid Style: "+g_style,SCREENW/2-280,SCREENH/2+lsp*1,4)
		If sel = 5 Or sel = 7 Or sel = 8 Or sel = 9
			If (cnt Mod 60 = 0) Then gridpoint.Pull(Rand(0,20)*GRIDWIDTH,Rand(0,20)*GRIDHEIGHT,8,24)
		EndIf
		CycleColours()
		gridpoint.UpdateGrid()
		gridpoint.DrawGrid(g_style, True)
		gxoff = 0
		gyoff = 0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 6
		If sel = 6 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Number of Stars: "+showstars,SCREENW/2-280,SCREENH/2+lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 7
		If sel = 7 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Particle Style: "+particlestyle,SCREENW/2-280,SCREENH/2+lsp*3,4)
		If sel = 7
			If Rand(0,100) > 94 Then part.CreateFireworks(2)
		EndIf
		part.UpdateParticles(1)
		part.DrawParticles()

		SetColor 255,255,255
		SetScale 2,2
		DrawImage colourpick,SCREENW/2+74,SCREENH/2+lsp*4+14,1
		DrawImage colourpick,SCREENW/2+74,SCREENH/2+lsp*5+14,0
		SetScale 1,1
		SetColor 100,255,100
		DrawRect SCREENW/2+74+2-122+col_pick*2,SCREENH/2+lsp*4+20,2,8
		DrawRect SCREENW/2+74+2-122+bright*2,SCREENH/2+lsp*5+20,2,8
		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*4,SCREENW,5*4) Then sel = 8
		If sel = 8 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Grid Colour:",SCREENW/2-280,SCREENH/2+lsp*4,4)
		If sel = 8
			SetScale 2,2
			DrawImage colourpick,SCREENW/2+74,SCREENH/2+lsp*4+14,2
			SetScale 1,1
		EndIf

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*5,SCREENW,5*4) Then sel = 9
		If sel = 9 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Grid Bright:",SCREENW/2-280,SCREENH/2+lsp*5,4)
		If sel = 9
			SetScale 2,2
			DrawImage colourpick,SCREENW/2+74,SCREENH/2+lsp*5+14,2
			SetScale 1,1
		EndIf

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*6,SCREENW,5*4) Then sel = 10
		If sel = 10 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*6,4)


		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 10
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-4)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 10 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-4)+20)
		EndIf

		If jdmy <> 0 Then ignorejoy = True
		If jdmx <> 0 Then ignorexjoy = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		If KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 10;bombtime = 20
		If (KeyDown(KEY_LEFT) Or MouseDown(1)) And bombtime = 0 Then jdmx = -1;bombtime = 20
		If (KeyDown(KEY_RIGHT) Or MouseDown(2)) And bombtime = 0 Then jdmx = 1;bombtime = 20
		Select sel
			Case 0
				If jdmx <> 0
					scroll = 1-scroll
				EndIf
				done = False
			Case 1
				If jdmx < 0
					screensize:-1
					If screensize < 0 Then screensize = numgfxmodes
					bombtime = 8
				EndIf
				If jdmx > 0
					screensize:+1
					If screensize > numgfxmodes Then screensize = 0
					bombtime = 8
				EndIf
				done = False
			Case 2
				If jdmx < 0
					playsize:-1
					If playsize < 0 Then playsize = numplayfieldsizes
					bombtime = 8
				EndIf
				If jdmx > 0
					playsize:+1
					If playsize > numplayfieldsizes Then playsize = 0
					bombtime = 8
				EndIf
				done = False
			Case 3
				If jdmx < 0
					gfxset:-1
					If gfxset < 0 Then gfxset = NUMGFXSETS
				EndIf
				If jdmx > 0
					gfxset:+1
					If gfxset > NUMGFXSETS Then gfxset = 0
				EndIf
				done = False
			Case 4
				If jdmx <> 0
					windowed = 1-windowed
				EndIf
				done = False
			Case 5
				If jdmx > 0
					g_style:+1
					If g_style > numgridstyles Then g_style = 0
				EndIf
				If jdmx < 0
					g_style:-1
					If g_style < 0 Then g_style = numgridstyles
				EndIf
			Case 6
				If jdmx > 0
					showstars:+100
					If showstars > MAXSTARS Then showstars = 0
					bombtime = 8
				EndIf
				If jdmx < 0
					showstars:-100
					If showstars < 0 Then showstars = MAXSTARS
					bombtime = 8
				EndIf
			Case 7
				If jdmx > 0
					particlestyle:+1
					If particlestyle > numparticlestyles Then particlestyle = 0
				EndIf
				If jdmx < 0
					particlestyle:-1
					If particlestyle < 0 Then particlestyle = numparticlestyles
				EndIf
			Case 8 ' colour
				If jdmx < 0
					col_pick:-1
					If col_pick < 0 Then col_pick = 0
					SetGridColours(col_pick)
					bombtime = 2
				EndIf
				If jdmx > 0
					col_pick:+1
					If col_pick > 119 Then col_pick = 119
					SetGridColours(col_pick)
					bombtime = 2
				EndIf
				done = False
			Case 9 ' brightness
				If jdmx < 0
					bright:-1
					If bright < 0 Then bright= 0
					g_opacity = bright/119
					bombtime = 2
				EndIf
				If jdmx > 0
					bright:+1
					If bright> 119 Then bright= 119
					g_opacity = bright/119
					bombtime = 2
				EndIf
				done = False
			Case 10
				If jdmx <> 0 Then done=True
				'exit this menu
		End Select
		looper :+8
	Wend
	If 	(old_scroll <> scroll Or ..
		old_screensize <> screensize Or ..
		old_playsize <> playsize or..
		old_gfxset <> gfxset or..
		old_windowed <> windowed)
		If conf(showgame,"Keep Changes?")
			' reload gfx, resize grid
			If setup()
				Return 2
			Else
				' can't set mode - reset to old
				scroll  = old_scroll
				screensize  = old_screensize
				playsize  = old_playsize
				gfxset = old_gfxset
				windowed = old_windowed
				SetDimensions()
				Cls
				SetColor 0,255,255
				DrawString("Unable to set Gfx Mode",20,64,3)
				DrawString("Reverting to old settings: "+gfxmodearr[screensize].s$,20,64+30,3)
				Flip 1
				Delay 2000
			EndIf
		Else
			scroll  = old_scroll
			screensize  = old_screensize
			playsize  = old_playsize
			gfxset = old_gfxset
			windowed = old_windowed
		EndIf
	EndIf
	Return False
End Function




Function SetGridColours(ind:Int)
	Local rgb:Int
	Local pm:TPixmap = LockImage:TPixmap(colourpick,1)
	rgb = ReadPixel(pm,1+ind,2)
	UnlockImage(colourpick,1)

	g_red = (rgb Shr 16) & $FF
	g_green = (rgb Shr 8) & $FF
	g_blue = rgb & $FF

End Function




Function GameSettings:Int(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 5 ' done
	Local s#,x:Int
	Local ignorejoy:Int, ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40

	Local old_startingdifficulty:Int = startingdifficulty
	Local old_exlife:Int = exlife[startingdifficulty]
	Local old_exbomb:Int = exbomb[startingdifficulty]
	Local old_autofire:Int = autofire
	Local old_inertia# = inertia
	Local old_scroll:Int = scroll

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*3+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.7)
		SetColor 255,0,0
		DrawString("Game Settings",SCREENW/2-280,SCREENH/2-lsp*4,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*2,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Starting Level: "+difficulty$[startingdifficulty],SCREENW/2-280,SCREENH/2-lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Free Player: "+exlife[startingdifficulty],SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Free Bomb: "+exbomb[startingdifficulty],SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("AutoFire: "+onoff$[autofire],SCREENW/2-280,SCREENH/2+lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Inertia:",SCREENW/2-280,SCREENH/2+lsp*2,4)
		rect SCREENW/2-360+240+1,SCREENH/2+lsp*2+1,inertia*300,24-2,1
		SetColor 255,255,0
		rect SCREENW/2-360+240,SCREENH/2+lsp*2,302,24,0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 5
		If sel = 5 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*3,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 5
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-2)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 5 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-2)+20)
		EndIf
		If jdmy <> 0 Then ignorejoy = True
		If jdmx <> 0 Then ignorexjoy = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		If KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 5;bombtime = 20
		If (KeyDown(KEY_LEFT) Or MouseDown(1)) And bombtime = 0 Then jdmx = -1;bombtime = 20
		If (KeyDown(KEY_RIGHT) Or MouseDown(2)) And bombtime = 0 Then jdmx = 1;bombtime = 20
		Select sel
			Case 0
				If jdmx < 0
					startingdifficulty:-1
					If startingdifficulty < 0 Then startingdifficulty = 0
				EndIf
				If jdmx > 0
					startingdifficulty:+1
					If startingdifficulty > 2 Then startingdifficulty = 2
				EndIf
				done = False
			Case 1
				If jdmx < 0
					exlife[startingdifficulty]:-25000
					If exlife[startingdifficulty]< 25000 Then exlife[startingdifficulty]= 25000
				EndIf
				If jdmx > 0
					exlife[startingdifficulty]:+25000
					If exlife[startingdifficulty]> 300000 Then exlife[startingdifficulty]= 300000
				EndIf
				done = False
			Case 2
				If jdmx < 0
					exbomb[startingdifficulty]:-25000
					If exbomb[startingdifficulty] < 25000 Then exbomb[startingdifficulty]= 25000
				EndIf
				If jdmx > 0
					exbomb[startingdifficulty]:+25000
					If exbomb[startingdifficulty]> 300000 Then exbomb[startingdifficulty]= 300000
				EndIf
				done = False
			Case 3
				If jdmx <> 0
					autofire = 1-autofire
				EndIf
				done = False
			Case 4
				'inertia
				If jdmx < 0
					inertia:- 0.05
					If inertia< 0 Then inertia = 0
				EndIf
				If jdmx > 0
					inertia:+ 0.05
					If inertia > 1 Then inertia = 1
				EndIf
				done = False
			Case 5
				If jdmx <> 0 Then done=True
				'exit this menu
		End Select
		looper :+8
	Wend
	If 	(old_startingdifficulty <> startingdifficulty Or ..
		old_exlife <> exlife[startingdifficulty] Or ..
		old_exbomb <> exbomb[startingdifficulty] Or ..
		old_autofire <> autofire Or ..
		old_inertia <> inertia)
		If conf(showgame,"Keep Changes?")
			Return 2
		Else
			startingdifficulty = old_startingdifficulty
			exlife[startingdifficulty] = old_exlife
			exbomb[startingdifficulty] = old_exbomb
			autofire  = old_autofire
			inertia  = old_inertia
		EndIf
	EndIf
	Return False
End Function





Function AudioSettings(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 3
	Local s#,x:Int
	Local ignoreyjoy:Int,ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40
	Local oldsoundset:Int = soundset

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*3+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.7)
		SetColor 255,0,0
		DrawString("Audio Settings",SCREENW/2-280,SCREENH/2-lsp*2,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 0
		If sel = 0
			SetColor 0,200,0
			rect SCREENW/2+2,SCREENH/2+2,sfxvol*200,24-2,1
			SetColor 255,255,(cnt*8) Mod 255
		Else
			SetColor 0,100,0
			rect SCREENW/2+1,SCREENH/2+1,sfxvol*200,24-2,1
			SetColor 0,200,0
		EndIf
		DrawString("SFX Volume:",SCREENW/2-280,SCREENH/2,4)
		rect SCREENW/2,SCREENH/2,202,24,0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 1
		If sel = 1
			SetColor 0,200,0
			rect SCREENW/2+1,SCREENH/2+lsp+1,musicvol*200,24-2,1
			SetColor 255,255,(cnt*8) Mod 255
		Else
			SetColor 0,100,0
			rect SCREENW/2+1,SCREENH/2+lsp+1,musicvol*200,24-2,1
			SetColor 0,200,0
		EndIf
		DrawString("Music Volume:",SCREENW/2-280,SCREENH/2+lsp,4)
		rect SCREENW/2,SCREENH/2+lsp,202,24,0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Sound Set: "+soundsets$[soundset],SCREENW/2-280,SCREENH/2+lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 3
		If sel = 3 Then SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*3,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf

		jdmy = GetJoyByAxis(joyport, axis_move_y,axis_move_y_inv,axis_move_y_sc,axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignoreyjoy = False
		If ignoreyjoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x,axis_move_x_inv,axis_move_x_sc,axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 3
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 3 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf
		If (KeyDown(KEY_LEFT) Or MouseDown(1)) And bombtime = 0 Then jdmx = -1;bombtime = 20
		If (KeyDown(KEY_RIGHT) Or MouseDown(2)) And bombtime = 0 Then jdmx = 1;bombtime = 20
		Select sel
			Case 0 ' sfxvol
				If jdmx < 0
					sfxvol:- 0.05
					If sfxvol < 0 Then sfxvol = 0
					AdjustVolume()
				EndIf
				If jdmx > 0
					sfxvol:+ 0.05
					If sfxvol > 1 Then sfxvol = 1
					AdjustVolume()
				EndIf
			Case 1 ' musicvol
				If jdmx < 0
					musicvol:- 0.05
					If musicvol < 0 Then musicvol = 0
					SetMusicVolume()
				EndIf
				If jdmx > 0
					musicvol:+ 0.05
					If musicvol > 1 Then musicvol = 1
					SetMusicVolume()
				EndIf
			Case 2
				If jdmx < 0
					soundset:-1
					If soundset < 0 Then soundset = 1
				EndIf
				If jdmx > 0
					soundset:+1
					If soundset > 1 Then soundset = 0
				EndIf
				done = False
			Case 3 ' done
				If jdmx <> 0 Then done=True

		End Select
		If jdmy <> 0 Then ignoreyjoy = True
		If jdmx <> 0 Then ignorexjoy = True
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 2;bombtime = 20
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True

		looper :+8
	Wend
	If soundset <> oldsoundset
		LoadSounds()
	EndIf

End Function





Function ControllerSettings:Int(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 2
	Local s#,x:Int
	Local ignoreyjoy:Int
	Local ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*2+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.7)
		SetColor 255,0,0
		DrawString("Controller Selection",SCREENW/2-280,SCREENH/2-lsp*2,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 0
		If sel = 0 Then SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Type: "+control_method[controltype],SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 1
		If sel = 1 Then SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Configure Controls",SCREENW/2-280,SCREENH/2+lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 2
		If sel = 2 Then SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*2,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignoreyjoy = False
		If ignoreyjoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x,axis_move_x_inv,axis_move_x_sc,axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 2
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 2 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
		EndIf

		If jdmy <> 0 Then ignoreyjoy = True
		If jdmx <> 0 Then ignorexjoy = True
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 2;bombtime = 20
		If KeyHit(KEY_LEFT) Or MouseHit(1) Then jdmx = -1
		If KeyHit(KEY_RIGHT) Or MouseHit(2) Then jdmx = 1
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20

		Select sel
			Case 0 ' control type
				If jdmx < 0 Or done = True
					controltype :- 1
					If controltype < 0 Then controltype = 4
					done = False
				EndIf
				If jdmx > 0
					controltype :+ 1
					If controltype > 4 Then controltype = 0
				EndIf
			Case 1 'controller config
				If done = True Or jdmx <> 0
					Select controltype
						Case 0 'dual analog
							DualAnalogControllerSettings()
						Case 1 'mouse
							MouseControllerSettings(showgame)
						Case 2 'key
							KeyboardControllerSettings(showgame)
						Case 3 'joypad
							JoypadControllerSettings(showgame)
						Case 4 'hybrid
							HybridControllerSettings(showgame)
					End Select
					SetController()
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel)+20)
					done = False
					looper = 0
					bombtime = 20
					FlushKeys()
					FlushMouse()
				EndIf
			Case 2 ' done
				If jdmx <> 0 Then done=True

		End Select
		looper :+8
	Wend

End Function


Function HybridControllerSettings(showgame:Int)

	Local xx:Int, yy:Int, cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 4
	Local s#,x:Int
	Local ignorejoy:Int,ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*3+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.6)
		SetColor 255,0,0
		DrawString("Hybrid Control",SCREENW/2-280,SCREENH/2-lsp*3,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		Select h_config
			Case 0
				DrawString("Move: Keys* - Aim: Mouse Relative",SCREENW/2-280,SCREENH/2-lsp,4)
			Case 1
				DrawString("Move: Mouse - Fire: Keys*",SCREENW/2-280,SCREENH/2-lsp,4)
			Case 2
				DrawString("Move: Keys* - Aim: Mouse Centered",SCREENW/2-280,SCREENH/2-lsp,4)
		End Select

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Fire: "+mbut$[m_fire]+" Mouse Button",SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Bomb: "+mbut$[m_bomb]+" Mouse Button",SCREENW/2-280,SCREENH/2+lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2+100+1,SCREENH/2+lsp*2+1,m_sensitivity*200,24-2,1
		DrawString("Mouse Sensitivity:",SCREENW/2-280,SCREENH/2+lsp*2,4)
		SetColor 255,255,0
		rect SCREENW/2+100,SCREENH/2+lsp*2,202,24,0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*3,4)

		SetColor 0,200,0
		DrawString("* configure in Keys Control",SCREENW/2-280,SCREENH/2+lsp*4,4)

		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 4
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 4 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If jdmy <> 0 Then ignorejoy = True
		If jdmx <> 0 Then ignorexjoy = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 7
			jb = jb + JoyDown(i,joyport)
		Next
		If (KeyDown(KEY_LEFT) Or MouseDown(1)) And bombtime = 0 Then jdmx = -1;bombtime = 20
		If (KeyDown(KEY_RIGHT) Or MouseDown(2)) And bombtime = 0 Then jdmx = 1;bombtime = 20
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 4;bombtime = 20
		Select sel
			Case 0
				If jdmx <> 0
					h_config:+1
					If h_config > 2 Then h_config = 0
				EndIf
				done = False
			Case 1
				If jdmx <> 0
					m_fire:+1
					If m_fire > 3 Then m_fire = 1
				EndIf
				done = False
			Case 2
				If jdmx <> 0
					m_bomb:+1
					If m_bomb > 3 Then m_bomb = 1
				EndIf
				done = False
			Case 3
				If jdmx < 0
					m_sensitivity:- 0.05
					If m_sensitivity< 0 Then m_sensitivity= 0
				EndIf
				If jdmx > 0
					m_sensitivity:+ 0.05
					If m_sensitivity> 1 Then m_sensitivity= 1
				EndIf
				done = False
			Case 4
				If jdmx <> 0 Then done = True
		End Select
		looper :+8
	Wend

End Function




Function MouseControllerSettings(showgame:Int)

	Local cnt:Int, xx:Int, yy:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 3
	Local s#,x:Int
	Local ignorejoy:Int,ignorexjoy:Int
	Local tim:Int
	Local lsp:Int = 40

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*2+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.6)
		SetColor 255,0,0
		DrawString("Mouse Control",SCREENW/2-280,SCREENH/2-lsp*3,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Fire: "+mbut$[m_fire]+" Mouse Button",SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Bomb: "+mbut$[m_bomb]+" Mouse Button",SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2+100+1,SCREENH/2+lsp+1,m_sensitivity*200,24-2,1
		DrawString("Mouse Sensitivity:",SCREENW/2-280,SCREENH/2+lsp,4)
		SetColor 255,255,0
		rect SCREENW/2+100,SCREENH/2+lsp,202,24,0

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*2,4)
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 3
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 3 Then sel = 0
			MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-1)+20)
		EndIf
		If jdmy <> 0 Then ignorejoy = True
		If jdmx <> 0 Then ignorexjoy = True
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 7
			jb = jb + JoyDown(i,joyport)
		Next
		If (KeyDown(KEY_LEFT) Or MouseDown(1)) And bombtime = 0 Then jdmx = -1;bombtime = 20
		If (KeyDown(KEY_RIGHT) Or MouseDown(2)) And bombtime = 0 Then jdmx = 1;bombtime = 20
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		If KeyHit(k_bomb) Or KeyHit(KEY_ENTER) Then done = True
		If KeyHit(KEY_ESCAPE) Then done = True;sel = 4;bombtime = 20
		Select sel
			Case 0
				If jdmx <> 0
					m_fire:+1
					If m_fire > 3 Then m_fire = 1
				EndIf
				done = False
			Case 1
				If jdmx <> 0
					m_bomb:+1
					If m_bomb > 3 Then m_bomb = 1
				EndIf
				done = False
			Case 2
				If jdmx < 0
					m_sensitivity:- 0.05
					If m_sensitivity< 0 Then m_sensitivity= 0
				EndIf
				If jdmx > 0
					m_sensitivity:+ 0.05
					If m_sensitivity> 1 Then m_sensitivity= 1
				EndIf
				done = False
			Case 3
				If jdmx <> 0 Then done=True
		End Select
		looper :+8
	Wend

End Function




Function KeyboardControllerSettings(showgame:Int)
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 9
	Local s#,x:Int
	Local ignorejoy:Int
	Local key:Int = -10
	Local flash$
	Local tim:Int
	Local cnt:Int
	Local lsp:Int = 40
	Local xx:Int
	Local yy:Int
	If (SCREENH<600) Then lsp = 32

	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*5+20)
	While Not done
		Cls
		xx = MouseX()
		yy = MouseY()
		tim = MilliSecs()
		If showgame Then DrawAllStatic(.6)
		SetColor 255,0,0
		DrawString("Keyboard Control",SCREENW/2-280,SCREENH/2-lsp*6,6)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*4,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_move_left];If key = -1 And sel = 0 And looper Mod 30 < 15 Then flash = ""
		DrawString("Move Left : "+flash$,SCREENW/2-280,SCREENH/2-lsp*4,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*3,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_move_right];If key = -1 And sel = 1 And looper Mod 30 < 15 Then flash = ""
		DrawString("Move Right: "+flash$,SCREENW/2-280,SCREENH/2-lsp*3,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*2,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_move_up];If key = -1 And sel = 2 And looper Mod 30 < 15 Then flash = ""
		DrawString("Move Up   : "+flash$,SCREENW/2-280,SCREENH/2-lsp*2,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*1,SCREENW,5*4) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_move_down];If key = -1 And sel = 3 And looper Mod 30 < 15 Then flash = ""
		DrawString("Move Down : "+flash$,SCREENW/2-280,SCREENH/2-lsp*1,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*0,SCREENW,5*4) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_fire_left];If key = -1 And sel = 4 And looper Mod 30 < 15 Then flash = ""
		DrawString("Fire Left : "+flash$,SCREENW/2-280,SCREENH/2-lsp*0,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*1,SCREENW,5*4) Then sel = 5
		If sel = 5 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_fire_right];If key = -1 And sel = 5 And looper Mod 30 < 15 Then flash = ""
		DrawString("Fire Right: "+flash$,SCREENW/2-280,SCREENH/2+lsp*1,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*2,SCREENW,5*4) Then sel = 6
		If sel = 6 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_fire_up];If key = -1 And sel = 6 And looper Mod 30 < 15 Then flash = ""
		DrawString("Fire Up   : "+flash$,SCREENW/2-280,SCREENH/2+lsp*2,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*3,SCREENW,5*4) Then sel = 7
		If sel = 7 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_fire_down];If key = -1 And sel = 7 And looper Mod 30 < 15 Then flash = ""
		DrawString("Fire Down : "+flash$,SCREENW/2-280,SCREENH/2+lsp*3,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*4,SCREENW,5*4) Then sel = 8
		If sel = 8 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		flash$ = keystring[k_bomb];If key = -1 And sel = 8 And looper Mod 30 < 15 Then flash = ""
		DrawString("Bomb : "+flash$,SCREENW/2-280,SCREENH/2+lsp*4,4)

		If key = -10 Then If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*5,SCREENW,5*4) Then sel = 9
		If sel = 9 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*5,4)

		cnt:+1
		DrawTarget(SCREENW/2-280-20,yy,cnt,4)
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		If key = -10
			jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
			If Abs(jdmy) < 0.6 Then jdmy = 0
			If jdmy = 0 Then ignorejoy = False
			If ignorejoy = True
				jdmy = 0
			EndIf
			If KeyHit(KEY_UP) Or jdmy < 0
				sel:-1
				If sel < 0 Then sel = 9
				MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-4)+20)
			EndIf
			If KeyHit(KEY_DOWN) Or jdmy > 0
				sel:+1
				If sel > 9 Then sel = 0
				MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-4)+20)
			EndIf

			If jdmy <> 0 Then ignorejoy = True
			If KeyHit(KEY_ENTER) Or KeyHit(KEY_RIGHT) Or KeyHit(KEY_LEFT) Or MouseHit(1)
				If sel < 9
					key = -1
					FlushKeys()
				Else
					done = True
				EndIf
			EndIf
		EndIf
		If key = -1 ' waiting for key press
			For Local kk:Int = 8 To 255
				If KeyDown(kk) Then FlushKeys();key=kk;Exit
			Next
		EndIf
		' key was entered
		If key > -1
			Select sel
				Case 0
					k_move_left = key
				Case 1
					k_move_right = key
				Case 2
					k_move_up = key
				Case 3
					k_move_down = key
				Case 4
					k_fire_left = key
				Case 5
					k_fire_right = key
				Case 6
					k_fire_up = key
				Case 7
					k_fire_down = key
				Case 8
					k_bomb = key
			End Select
			key = -10
		EndIf
		looper :+8
		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 7
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True
	Wend

End Function




Function JoypadControllerSettings(showgame:Int)
	Local xx:Int,yy:Int,cnt:Int
	Local done:Int = False
	Local jb:Int,i:Int
	Local looper:Int = 0
	Local sel:Int = 7
	Local s#,x:Int
	Local ignorejoy:Int, ignorexjoy:Int
	Local m$,f$
	Local tim:Int
	Local lsp:Int = 40

	If j_config = 0
		m$ = "D Pad"
		f$ = "4-Buttons"
	Else
		f$ = "D Pad"
		m$ = "4-Buttons"
	EndIf
	bombtime = 20
	FlushKeys()
	FlushMouse()
	MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*4+20)
	While Not done
		Cls
		xx= MouseX()
		yy = MouseY()

		tim = MilliSecs()
		If showgame Then DrawAllStatic(.6)
		SetColor 255,0,0
		DrawString("Joypad Control",SCREENW/2-280,SCREENH/2-lsp*4,6)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp*2,SCREENW,5*4) Then sel = 0
		If sel = 0 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Move: "+m$+"  Fire: "+f$,SCREENW/2-280,SCREENH/2-lsp*2,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2-lsp,SCREENW,5*4) Then sel = 1
		If sel = 1 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Bomb: Button  ["+(j_pad_bomb+1)+"]",SCREENW/2-280,SCREENH/2-lsp,4)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2,SCREENW,5*4) Then sel = 2
		If sel = 2 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Option: Button  ["+(j_pad_option+1)+"]",SCREENW/2-280,SCREENH/2,4)

		If RectsOverlap(xx-8,yy-8,16,16,SCREENW/2+64,SCREENH/2+lsp*1,40,30) Then sel = 3
		If sel = 3 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2+64,SCREENH/2+lsp*1,40,30,0
		DrawString((j_pad_4+1),SCREENW/2+64+8,SCREENH/2+lsp*1+8,3)

		If RectsOverlap(xx-8,yy-8,16,16,SCREENW/2,SCREENH/2+lsp*2,40,30) Then sel = 4
		If sel = 4 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2,SCREENH/2+lsp*2,40,30,0
		DrawString((j_pad_1+1),SCREENW/2+8,SCREENH/2+lsp*2+8,3)

		If RectsOverlap(xx-8,yy-8,16,16,SCREENW/2+128,SCREENH/2+lsp*2,40,30) Then sel = 5
		If sel = 5 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2+128,SCREENH/2+lsp*2,40,30,0
		DrawString((j_pad_3+1),SCREENW/2+128+8,SCREENH/2+lsp*2+8,3)

		If RectsOverlap(xx-8,yy-8,16,16,SCREENW/2+64,SCREENH/2+lsp*3,40,30) Then sel = 6
		If sel = 6 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		rect SCREENW/2+64,SCREENH/2+lsp*3,40,30,0
		DrawString((j_pad_2+1),SCREENW/2+64+8,SCREENH/2+lsp*3+8,3)

		If RectsOverlap(xx-8,yy-8,16,16,0,SCREENH/2+lsp*4,SCREENW,5*4) Then sel = 7
		If sel = 7 SetColor 255,255,(cnt*8) Mod 255 Else SetColor 0,200,0
		DrawString("Done",SCREENW/2-280,SCREENH/2+lsp*4,4)
		DrawTarget(xx,yy,cnt,4)
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
		If Abs(jdmy) < 0.6 Then jdmy = 0
		If jdmy = 0 Then ignorejoy = False
		If ignorejoy = True
			jdmy = 0
		EndIf
		jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
		If Abs(jdmx) < 0.6 Then jdmx = 0
		If jdmx = 0 Then ignorexjoy = False
		If ignorexjoy = True
			jdmx = 0
		EndIf
		If jdmy <> 0 Then ignorejoy = True
		If jdmx <> 0 Then ignorexjoy = True
		If KeyHit(KEY_UP) Or jdmy < 0
			sel:-1
			If sel < 0 Then sel = 7
			Select sel
				Case 3
					MoveMouse(SCREENW/2+64-20,SCREENH/2+lsp*1+20)
				Case 4
					MoveMouse(SCREENW/2-20,SCREENH/2+lsp*2+20)
				Case 5
					MoveMouse(SCREENW/2+128-20,SCREENH/2+lsp*2+20)
				Case 6
					MoveMouse(SCREENW/2+64-20,SCREENH/2+lsp*3+20)
				Case 7
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-3)+20)
				Default
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-2)+20)
			End Select
		EndIf
		If KeyHit(KEY_DOWN) Or jdmy > 0
			sel:+1
			If sel > 7 Then sel = 0
			Select sel
				Case 3
					MoveMouse(SCREENW/2+64-20,SCREENH/2+lsp*1+20)
				Case 4
					MoveMouse(SCREENW/2-20,SCREENH/2+lsp*2+20)
				Case 5
					MoveMouse(SCREENW/2+128-20,SCREENH/2+lsp*2+20)
				Case 6
					MoveMouse(SCREENW/2+64-20,SCREENH/2+lsp*3+20)
				Case 7
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-3)+20)
				Default
					MoveMouse(SCREENW/2-280-20,SCREENH/2+lsp*(sel-2)+20)
			End Select
		EndIf

		jb = 0
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		For i = 0 To 15
			jb = jb + JoyDown(i,joyport)
		Next
		If jb > 0 And bombtime = 0 And looper > 15*8 Then done = True;bombtime = 20
		If KeyHit(KEY_ESCAPE) Then done = True;sel=7;bombtime = 20
		If KeyHit(KEY_LEFT) Or MouseHit(1) Then jdmx = -1
		If KeyHit(KEY_RIGHT) Or MouseHit(2) Then jdmx = 1
		If KeyHit(KEY_ENTER) Then jdmx = 1
		Select sel
			Case 0
				If jdmx <> 0 j_config = 1-j_config
				done = False
				If j_config = 0
					m$ = "D Pad"
					f$ = "4-Buttons"
				Else
					f$ = "D Pad"
					m$ = "4-Buttons"
				EndIf
			Case 1
				If jdmx < 0
					j_pad_bomb:-1
					If j_pad_bomb < 0 Then j_pad_bomb = 0
				Else If jdmx > 0
					j_pad_bomb:+1
					If j_pad_bomb > 15 Then j_pad_bomb = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_bomb = i
				Next
				done = False
			Case 2
				If jdmx < 0
					j_pad_option:-1
					If j_pad_option < 0 Then j_pad_option = 0
				Else If jdmx > 0
					j_pad_option:+1
					If j_pad_option > 15 Then j_pad_option = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_option = i
				Next
				done = False
			Case 3
				If jdmx < 0
					j_pad_4:-1
					If j_pad_4 < 0 Then j_pad_4 = 0
				Else If jdmx > 0
					j_pad_4:+1
					If j_pad_4 > 15 Then j_pad_4 = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_4 = i
				Next
				done = False
			Case 4
				If jdmx < 0
					j_pad_1:-1
					If j_pad_1 < 0 Then j_pad_1 = 0
				Else If jdmx > 0
					j_pad_1:+1
					If j_pad_1 > 15 Then j_pad_1 = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_1 = i
				Next
				done = False
			Case 5
				If jdmx < 0
					j_pad_3:-1
					If j_pad_3 < 0 Then j_pad_3 = 0
				Else If jdmx > 0
					j_pad_3:+1
					If j_pad_3 > 15 Then j_pad_3 = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_3 = i
				Next
				done = False
			Case 6
				If jdmx < 0
					j_pad_2:-1
					If j_pad_2 < 0 Then j_pad_2 = 0
				Else If jdmx > 0
					j_pad_2:+1
					If j_pad_2 > 15 Then j_pad_2 = 15
				EndIf
				For i = 0 To 15
					If JoyDown(i,joyport) Then j_pad_2 = i
				Next
				done = False
			Case 7
				If jdmx <> 0 Then done = True
				'exit
		End Select
		looper :+8
	Wend

End Function



Function DualAnalogControllerSettings()

	Local done:Int = False
	Local tim:Int
	Local cnt:Int

	SetOrigin (SCREENW-640)/2,(SCREENH-480)/2

	While Not done
		Cls
		tim = MilliSecs()
		drawconfigstuff()

		mx = MouseX()
		my = MouseY()
		If mx>640 Then mx = 640
		If my>550 Then my = 550
		If assigning = False
			done = CheckInput(joyport)
		Else
			AssignAllJoyAxis(joyport)
			If ax Mod 1 = 1 Then If GetJoyAxis(joyport,1) = -1 Then ax = ax + 1
			If ax = 8 Then assigning = False
		EndIf

		' map the Input values so the red dots can be drawn in position
		Local x1j# = GetJoyByAxis(joyport,j[joyport].x1id-1,j[joyport].x1invert,j[joyport].x1scale,j[joyport].x1center)
		Local y1j# = GetJoyByAxis(joyport,j[joyport].y1id-1,j[joyport].y1invert,j[joyport].y1scale,j[joyport].y1center)
		Local x2j# = GetJoyByAxis(joyport,j[joyport].x2id-1,j[joyport].x2invert,j[joyport].x2scale,j[joyport].x2center)
		Local y2j# = GetJoyByAxis(joyport,j[joyport].y2id-1,j[joyport].y2invert,j[joyport].y2scale,j[joyport].y2center)

		' dead band
		If Abs(x1j) < j[joyport].x1dz Then x1j = 0
		If Abs(y1j) < j[joyport].y1dz Then y1j = 0
		If Abs(x2j) < j[joyport].x2dz Then x2j = 0
		If Abs(y2j) < j[joyport].y2dz Then y2j = 0

		'scale to box size
		Local x1:Int = FitValueToRange#( x1j, -1, 1,  10, 110 )
		Local y1:Int = FitValueToRange#( y1j, -1, 1, 275, 375 )
		Local x2:Int = FitValueToRange#( x2j, -1, 1, 250, 350 )
		Local y2:Int = FitValueToRange#( y2j, -1, 1, 275, 375 )

		'draw the control dots
		SetColor 185,0,0
		DrawOval x1-5-j[joyport].x1center*50,y1-5-j[joyport].y1center*50,10,10
		DrawOval x2-5-j[joyport].x2center*50,y2-5-j[joyport].y2center*50,10,10

		'draw cursor
		DrawTarget(mx,my,cnt,4)

		If infotimer > 0
			DrawText info$,320,180
			infotimer:-1
		EndIf
		cnt:+1
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
	Wend

	SetOrigin 0,0

End Function





Function DrawConfigStuff()

	SetBlend MASKBLEND
	SetAlpha 1

	SetColor 255,255,255
	DrawText "Dual Stick Configuration",170,10

	SetColor 128,128,128
	Rect 10,32,600,130,0 ' large text info box outline
	DrawText "Select controller port (0 for  single joypad)",15,35
	DrawText "others are only needed for multiple joypads.",15,35+1*12
	DrawText "Assign controls by clicking AXIS WIZARD or individually",15,35+2*12
	DrawText "cycle through available controls by left clicking on the axis box.",15,35+3*12
	DrawText "Right click on a box to toggle invert On or Off.",15,35+4*12
	DrawText "Blue box is normal, Orange box indicates an inverted axis.",15,35+5*12
	DrawText "Click on Stick 1/2 boxes and use cursor keys to adjust centering and",15,35+6*12
	DrawText "Dead Zone.  Make sure the red dot is in the green square when at rest.",15,35+7*12
	DrawText "If it drifts, press SHIFT+Cursor Keys to adjust Dead Zone.",15,35+8*12


	SetColor 35,65,115
	Select joyport ' draw current port selected
		Case 0
			Rect 100+10,130+45,45,25,1
		Case 1
			Rect 100+60,130+45,45,25,1
		Case 2
			Rect 100+110,130+45,45,25,1
		Case 3
			Rect 100+160,130+45,45,25,1
	End Select

	SetColor 0,0,100
	Rect 100+10,130+45,45,25,0 ' draw ports (outlines)
	Rect 100+60,130+45,45,25,0
	Rect 100+110,130+45,45,25,0
	Rect 100+160,130+45,45,25,0

	SetColor 255,255,255
	DrawText "Controller:",10,130+50
	DrawText "0",100+27,130+53
	DrawText "1",100+77,130+53
	DrawText "2",100+127,130+53
	DrawText "3",100+177,130+53

	If assigning = True
		SetColor 100,100,100
		Rect 10,225,135,25,1
	EndIf
	SetColor 255,255,255
	Rect 10,225,135,25,0
	DrawText "AXIS WIZARD",25,230

	If assigningoption = True
		SetColor 100,100,100
		Rect 180,225,100,25,1
	EndIf
	SetColor 255,255,255
	Rect 180,225,100,25,0
	DrawText "OPTION = "+(j[joyport].optionbutton+1),190,230

	If assigningbomb = True
		SetColor 100,100,100
		Rect 320,225,100,25,1
	EndIf
	SetColor 255,255,255
	Rect 320,225,100,25,0
	DrawText "BOMB = "+(j[joyport].bombbutton+1),330,230

	'draw boxes For axis controls
	SetColor 50,65,220
	If j[joyport].x1invert =-1 Then SetColor 255,128,0
	Rect 10,395,175,14,1

	SetColor 50,65,220
	If j[joyport].y1invert =-1 Then SetColor 255,128,0
	Rect 10,415,175,14,1

	SetColor 50,65,220
	If j[joyport].x2invert =-1 Then SetColor 255,128,0
	Rect 250,395,175,14,1

	SetColor 50,65,220
	If j[joyport].y2invert =-1 Then SetColor 255,128,0
	Rect 250,415,175,14,1

	SetColor 255,255,255
	DrawText "Stick 1",10,380
	DrawText "Stick 2",250,380
	DrawText "X axis: " + joy_label$[j[joyport].x1id],20,396
	DrawText "X axis: " + joy_label$[j[joyport].x2id],260,396
	DrawText "Y axis: " + joy_label$[j[joyport].y1id],20,416
	DrawText "Y axis: " + joy_label$[j[joyport].y2id],260,416

	If deadbandadjust = 1
		SetColor 100,100,100
		Rect 10+1,275+1, 100-2,100-2,1
	ElseIf deadbandadjust = 2
		SetColor 100,100,100
		Rect 250+1,275+1, 100-2,100-2,1
	EndIf

	SetColor 0,255,0
	rect 10+50-8,275+50-8,16,16
	rect 250+50-8,275+50-8,16,16

	SetColor 255,255,255
	Rect 10,275, 100,100,0 'draw outline boxes for controllers
	Rect 250,275, 100,100,0

	DrawText "X Scaling Factor",10,440
	DrawText "X Scaling Factor",250,440
	DrawText "Y Scaling Factor",10,480
	DrawText "Y Scaling Factor",250,480

	SetColor 35,65,115
	Select j[joyport].x1scale
		Case 1
			Rect 10,455,45,20,1
		Case 128
			Rect 60,455,45,20,1
		Case 255
			Rect 110,455,45,20,1
	End Select
	Select j[joyport].y1scale
		Case 1
			Rect 10,495,45,20,1
		Case 128
			Rect 60,495,45,20,1
		Case 255
			Rect 110,495,45,20,1
	End Select
	Select j[joyport].x2scale
		Case 1
			Rect 240+10,455,45,20,1
		Case 128
			Rect 240+60,455,45,20,1
		Case 255
			Rect 240+110,455,45,20,1
	End Select
	Select j[joyport].y2scale
		Case 1
			Rect 240+10,495,45,20,1
		Case 128
			Rect 240+60,495,45,20,1
		Case 255
			Rect 240+110,495,45,20,1
	End Select

	SetColor 255,255,255
	DrawText "1",27,460
	DrawText "180",70,460
	DrawText "255",120,460

	DrawText "1",240+27,460
	DrawText "180",240+70,460
	DrawText "255",240+120,460

	DrawText "1",27,500
	DrawText "180",70,500
	DrawText "255",120,500

	DrawText "1",240+27,500
	DrawText "180",240+70,500
	DrawText "255",240+120,500

	SetColor 0,0,100
	Rect 10,455,45,20,0
	Rect 60,455,45,20,0
	Rect 110,455,45,20,0

	Rect 240+10,455,45,20,0
	Rect 240+60,455,45,20,0
	Rect 240+110,455,45,20,0

	Rect 10,495,45,20,0
	Rect 60,495,45,20,0
	Rect 110,495,45,20,0

	Rect 240+10,495,45,20,0
	Rect 240+60,495,45,20,0
	Rect 240+110,495,45,20,0

	SetColor 255,32,32
	DrawText "DZ 1",120,270
	DrawText "DZ 2",360,270
	DrawText "C 1",120,330
	DrawText "C 2",360,330
	SetColor 32,32,240
	DrawText "X: "+j[joyport].x1dz,120,290
	DrawText "Y: "+j[joyport].y1dz,120,305
	DrawText "X: "+j[joyport].x2dz,360,290
	DrawText "Y: "+j[joyport].y2dz,360,305
	DrawText "X: "+j[joyport].x1center,120,350
	DrawText "Y: "+j[joyport].y1center,120,365
	DrawText "X: "+j[joyport].x2center,360,350
	DrawText "Y: "+j[joyport].y2center,360,365

	SetColor 64,64,64
	Rect 490,275+40,110,20
	Rect 490,300+40,110,20
	Rect 490,325+40,110,20
	Rect 490,350+40,110,20
	SetColor 255,255,255
	DrawText "(D)ebug",493,277+40
	DrawText "(S)ave Config",493,302+40
	DrawText "(L)oad Config",493,327+40
	DrawText "(E)xit",493,352+40

	If debug = 1
		SetColor 16,16,16
		Rect 0,25,640,217+80,1
		SetColor 48,48,48
		Rect 40,30,300,200+80,1
		SetColor 64,64,64 ' draw grey boxes
		For Local loop:Int = 50 To 190+80 Step 20
			Rect 180,loop,150,15
		Next
		Rect 40,30,300,200+60,0
		Rect 39,29,302,202+60,0

		SetColor 128,128,128 ' draw boxes showing movement of axis
		Rect 180,50,FitValueToRange#( JoyX(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,70,FitValueToRange#( JoyY(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,90,FitValueToRange#( JoyZ(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,110,FitValueToRange#( JoyR(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,130,FitValueToRange#( JoyU(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,150,FitValueToRange#( JoyV(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,170,FitValueToRange#( JoyPitch(joyport), -180, 180, 0, 150 ),15,1
		Rect 180,190,FitValueToRange#( JoyRoll(joyport), -180, 180, 0, 150 ),15,1
		Rect 180,210,FitValueToRange#( JoyYaw(joyport), -180, 180, 0, 150 ),15,1
		Rect 180,230,FitValueToRange#( JoyHat(joyport), -1, 1, 0, 150 ),15,1
		Rect 180,250,FitValueToRange#( JoyWheel(joyport), -1, 1, 0, 150 ),15,1
'		Rect 180,270,FitValueToRange#( JoyWhat(joyport,12), -1, 1, 0, 150 ),15,1
'		Rect 180,290,FitValueToRange#( JoyWhat(joyport,13), -1, 1, 0, 150 ),15,1

		SetColor 160,160,160 ' show values of axis
		DrawText "1.  JoyX()      : " + JoyX(joyport) ,50,50
		DrawText "2.  JoyY()      : " + JoyY(joyport),50,70
		DrawText "3.  JoyZ()      : " + JoyZ(joyport),50,90
		DrawText "4.  JoyR()      : " + JoyR(joyport),50,110
		DrawText "5.  JoyU()      : " + JoyU(joyport),50,130
		DrawText "6.  JoyV()      : " + JoyV(joyport),50,150
		DrawText "7.  JoyPitch()  : " + JoyPitch(joyport),50,170
		DrawText "8.  JoyRoll()   : " + JoyRoll(joyport),50,190
		DrawText "9.  JoyYaw()    : " + JoyYaw(joyport),50,210
		DrawText "10. JoyHat()    : " + JoyHat(joyport),50,230
		DrawText "11. JoyWheel()  : " + JoyWheel(joyport),50,250
'		DrawText "12. JoyAxis12()  : " + JoyWhat(joyport,12),50,270
'		DrawText "13. JoyAxis13()  : " + JoyWhat(joyport,13),50,290
	EndIf
End Function



Function CheckInput:Int(port:Int)
	SetColor 255,0,0
	If RectsOverlap  (mx-2,my-2,4,4,10,395,175,14) ' joy x 1
		Rect 9,394,177,16,0 ' draw a highlight rectangle
		If MouseHit(1) Then j[port].x1id:+1
		If MouseHit(2) Then j[port].x1invert = - j[port].x1invert
		If j[port].x1id > 15 Then j[port].x1id = 0
		If j[port].x1id < 0 Then j[port].x1id = 15
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,10,415,175,14) ' joy y 1
		Rect 9,414,177,16,0	' draw a highlight rectangle
		If MouseHit(1) Then j[port].y1id:+1
		If MouseHit(2) Then j[port].y1invert = - j[port].y1invert
		If j[port].y1id > 15 Then j[port].y1id = 0
		If j[port].y1id < 0 Then j[port].y1id = 15
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,250,395,175,14) ' joy x 2
		Rect 249,394,177,16,0	' draw a highlight rectangle
		If MouseHit(1) Then j[port].x2id:+1
		If MouseHit(2) Then j[port].x2invert = - j[port].x2invert
		If j[port].x2id > 15 Then j[port].x2id = 0
		If j[port].x2id < 0 Then j[port].x2id = 15
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,250,415,175,14) ' joy y 2
		Rect 249,414,177,16,0	' draw a highlight rectangle
		If MouseHit(1) Then j[port].y2id:+1
		If MouseHit(2) Then j[port].y2invert = - j[port].y2invert
		If j[port].y2id > 15 Then j[port].y2id = 0
		If j[port].y2id < 0 Then j[port].y2id = 15
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,10,275,100,100)
		Rect 10,275,100,100,0
		If MouseHit(1)
			If deadbandadjust = 1
				deadbandadjust = 0
			Else
				deadbandadjust = 1
			EndIf
		EndIf
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,250,275,100,100)
		Rect 250,275,100,100,0
		If MouseHit(1)
			If deadbandadjust = 2
				deadbandadjust = 0
			Else
				deadbandadjust = 2
			EndIf
		EndIf
	EndIf

	'joy port selection
	If RectsOverlap  (mx-2,my-2,4,4,100+10,130+45,45,25)
		Rect 100+10,130+45,45,25,0
		If MouseHit(1) Then joyport = 0
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,100+60,130+45,45,25)
		Rect 100+60,130+45,45,25,0
		If MouseHit(1) Then joyport = 1
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,100+110,130+45,45,25)
		Rect 100+110,130+45,45,25,0
		If MouseHit(1) Then joyport = 2
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,100+160,130+45,45,25)
		Rect 100+160,130+45,45,25,0
		If MouseHit(1) Then joyport = 3
	EndIf

	'scaling
	If RectsOverlap  (mx-2,my-2,4,4,10,455,45,20)
		Rect 10,455,45,20,0
		If MouseHit(1) Then j[joyport].x1scale = 1
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,60,455,45,20)
		Rect 60,455,45,20,0
		If MouseHit(1) Then j[joyport].x1scale = 180
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,110,455,45,20)
		Rect 110,455,45,20,0
		If MouseHit(1) Then j[joyport].x1scale = 255
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,10,495,45,20)
		Rect 10,495,45,20,0
		If MouseHit(1) Then j[joyport].y1scale = 1
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,60,495,45,20)
		Rect 60,495,45,20,0
		If MouseHit(1) Then j[joyport].y1scale = 180
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,110,495,45,20)
		Rect 110,495,45,20,0
		If MouseHit(1) Then j[joyport].y1scale = 255
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,240+10,455,45,20)
		Rect 240+10,455,45,20,0
		If MouseHit(1) Then j[joyport].x2scale = 1
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,240+60,455,45,20)
		Rect 240+60,455,45,20,0
		If MouseHit(1) Then j[joyport].x2scale = 180
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,240+110,455,45,20)
		Rect 240+110,455,45,20,0
		If MouseHit(1) Then j[joyport].x2scale = 255
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,240+10,495,45,20)
		Rect 240+10,495,45,20,0
		If MouseHit(1) Then j[joyport].y2scale = 1
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,240+60,495,45,20)
		Rect 240+60,495,45,20,0
		If MouseHit(1) Then j[joyport].y2scale = 180
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,240+110,495,45,20)
		Rect 240+110,495,45,20,0
		If MouseHit(1) Then j[joyport].y2scale = 255
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,10,225,135,25) ' assign all axis button
		Rect 10,225,135,25,0
		If MouseHit(1) Then assigning = True;ax = 0;assigningoption = False;assigningbomb = False
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,180,225,100,25) ' option button
		Rect 180,225,100,25,0
		If MouseHit(1) Then assigningoption = True;assigningbomb = False
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,320,225,100,25) ' bomb button
		Rect 320,225,100,25,0
		If MouseHit(1) Then assigningbomb = True;assigningoption = False
	EndIf

	If assigningoption
		For Local i:Int = 0 To 15
			If JoyDown(i,joyport) Then j[joyport].optionbutton = i
		Next
		If KeyHit(KEY_ENTER)
			j[joyport].optionbutton:+ 1
			If j[joyport].optionbutton > 15 Then j[joyport].optionbutton = 0
		EndIf
	EndIf

	If assigningbomb
		For Local i:Int = 0 To 15
			If JoyDown(i,joyport) Then j[joyport].bombbutton = i
		Next
		If KeyHit(KEY_ENTER)
			j[joyport].bombbutton:+ 1
			If j[joyport].bombbutton> 15 Then j[joyport].bombbutton = 0
		EndIf
	EndIf

	If KeyHit(KEY_1) Then joyport = 0 '1 key
	If KeyHit(KEY_2) Then joyport = 1 '2 key
	If KeyHit(KEY_3) Then joyport = 2 '3 key
	If KeyHit(KEY_4) Then joyport = 3 '4 key

	If RectsOverlap  (mx-2,my-2,4,4,490,275+40,110,20) ' debug toggle
		Rect 490,275+40,110,20,0
		If MouseHit (1) Then debug = 1 - Debug
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,490,300+40,110,20) ' save button
		Rect 490,300+40,110,20,0
		If MouseHit (1) Then SaveConfig()
	EndIf

	If RectsOverlap  (mx-2,my-2,4,4,490,325+40,110,20) 'load button
		Rect 490,325+40,110,20,0
		If MouseHit (1) Then LoadConfig()
	EndIf

	If KeyHit(KEY_D) Then debug = 1 - Debug ' tab key,... turns on debug

	If KeyHit(KEY_S) ' S key
		SaveConfig()
	EndIf

	If KeyHit(KEY_L) ' L key
		LoadConfig()
	EndIf

	If KeyHit(KEY_E) ' E For Exit
		Return True
	EndIf

	If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
		If deadbandadjust > 0
			If deadbandadjust = 1
				If KeyDown(KEY_UP)
					j[joyport].y1dz:-.01
					If j[joyport].y1dz < 0 Then j[joyport].y1dz = 0
				EndIf
				If KeyDown(KEY_DOWN)
					j[joyport].y1dz:+.01
					If j[joyport].y1dz > .5 Then j[joyport].y1dz = .5
				EndIf
				If KeyDown(KEY_LEFT)
					j[joyport].x1dz:-.01
					If j[joyport].x1dz < 0 Then j[joyport].x1dz = 0
				EndIf
				If KeyDown(KEY_RIGHT)
					j[joyport].x1dz:+.01
					If j[joyport].x1dz > .5 Then j[joyport].x1dz = .5
				EndIf
			Else
				If KeyDown(KEY_UP)
					j[joyport].y2dz:-.01
					If j[joyport].y2dz < -.9 Then j[joyport].y2dz= -.9
				EndIf
				If KeyDown(KEY_DOWN)
					j[joyport].y2dz:+.01
					If j[joyport].y2dz > .9 Then j[joyport].y2dz= .9
				EndIf
				If KeyDown(KEY_LEFT)
					j[joyport].x2dz:-.01
					If j[joyport].x2dz < -.9 Then j[joyport].x2dz= -.9
				EndIf
				If KeyDown(KEY_RIGHT)
					j[joyport].x2dz:+.01
					If j[joyport].x2dz > .9 Then j[joyport].x2dz= .9
				EndIf
			EndIf
		EndIf
	Else
		If deadbandadjust > 0
			If deadbandadjust = 1
				If KeyDown(KEY_UP)
					j[joyport].y1center:-.01
					If j[joyport].y1center < -.9 Then j[joyport].y1center = -.9
				EndIf
				If KeyDown(KEY_DOWN)
					j[joyport].y1center:+.01
					If j[joyport].y1center > .9 Then j[joyport].y1center = .9
				EndIf
				If KeyDown(KEY_LEFT)
					j[joyport].x1center:-.01
					If j[joyport].x1center < -.9 Then j[joyport].x1center = -.9
				EndIf
				If KeyDown(KEY_RIGHT)
					j[joyport].x1center:+.01
					If j[joyport].x1center > .9 Then j[joyport].x1center = .9
				EndIf
			Else
				If KeyDown(KEY_UP)
					j[joyport].y2center:-.01
					If j[joyport].y2center < -.9 Then j[joyport].y2center= -.9
				EndIf
				If KeyDown(KEY_DOWN)
					j[joyport].y2center:+.01
					If j[joyport].y2center > .9 Then j[joyport].y2center= .9
				EndIf
				If KeyDown(KEY_LEFT)
					j[joyport].x2center:-.01
					If j[joyport].x2center < -.9 Then j[joyport].x2center= -.9
				EndIf
				If KeyDown(KEY_RIGHT)
					j[joyport].x2center:+.01
					If j[joyport].x2center > .9 Then j[joyport].x2center= .9
				EndIf
			EndIf
		EndIf
	EndIf
	If RectsOverlap  (mx-2,my-2,4,4,490,350+40,110,20) ' quit button
		Rect 490,350+40,110,20,0
		If MouseHit (1) Then Return True
	EndIf

	Return False

End Function




Function GetJoyAxis:Int(port:Int,sc#)
	' on some joysticks, when an axis is not present the value is the Max
	' so we needed to get around that with the double check
	Local count:Int = 0
	While count < 30
		If Abs(JoyX(port)) > .5*sc And Abs(JoyX(port)) < .9*sc Return 1
		If Abs(JoyY(port)) > .5*sc And Abs(JoyY(port)) < .9*sc Return 2
		If Abs(JoyZ(port)) > .5*sc And Abs(JoyZ(port)) < .9*sc Return 3
		If Abs(JoyR(port)) > .5*sc And Abs(JoyR(port)) < .9*sc Return 4
		If Abs(JoyU(port)) > .5*sc And Abs(JoyU(port)) < .9*sc Return 5
		If Abs(JoyV(port)) > .5*sc And Abs(JoyV(port)) < .9*sc Return 6
		If Abs(JoyYaw(port)) > .5*sc And Abs(JoyYaw(port)) < .9*sc Return 7
		If Abs(JoyPitch(port)) > .5*sc And Abs(JoyPitch(port)) < .9*sc Return 8
		If Abs(JoyRoll(port)) > .5*sc And Abs(JoyRoll(port)) < .9*sc Return 9
		If Abs(JoyHat(port)) > .5*sc And Abs(JoyHat(port)) < .9*sc Return 10
		If Abs(JoyWheel(port)) > .5*sc And Abs(JoyWheel(port)) < .9*sc Return 11
'		If Abs(JoyWhat(port,12)) > .5*sc And Abs(JoyWhat(port,12)) < .9*sc Return 12
'		If Abs(JoyWhat(port,13)) > .5*sc And Abs(JoyWhat(port,13)) < .9*sc Return 13
'		If Abs(JoyWhat(port,14)) > .5*sc And Abs(JoyWhat(port,14)) < .9*sc Return 14
'		If Abs(JoyWhat(port,15)) > .5*sc And Abs(JoyWhat(port,15)) < .9*sc Return 15

		If KeyHit(KEY_ESCAPE) Then Return 0
		count:+1
		Delay 2
	Wend
	Return -1

End Function




Function AssignAllJoyAxis(port:Int)

	Local jax:Int

	SetColor 0,255,0
	Select ax/2
		Case 0
			DrawText "move stick 1 left or right (Escape to Cancel)",180,210
			jax = getjoyaxis(port,j[port].x1scale)
			If jax >= 0
			 	If jax > 0 Then j[port].x1id = jax
				ax:+1
				infotimer = 30*4
				info$ = "Stick 1 X axis assigned to " + joy_label[j[port].x1id]
			EndIf
		Case 1
			DrawText "move stick 1 up or down (Escape to Cancel)",180,210
			jax = getjoyaxis(port,j[port].y1scale)
			If jax >= 0
			 	If jax > 0 Then j[port].y1id = jax
				ax:+1
				infotimer = 30*4
				info$ = "Stick 1 Y axis assigned to " + joy_label[j[port].y1id]
			EndIf
		Case 2
			DrawText "move stick 2 left or right (Escape to Cancel)",180,210
			jax = getjoyaxis(port,j[port].x2scale)
			If jax >= 0
			 	If jax > 0 Then j[port].x2id = jax
				ax:+1
				infotimer = 30*4
				info$ = "Stick 2 X axis assigned to " + joy_label[j[port].x2id]
			EndIf
		Case 3
			DrawText "move stick 2 up or down (Escape to Cancel)",180,210
			jax = getjoyaxis(port,j[port].y2scale)
			If jax >= 0
			 	If jax > 0 Then j[port].y2id = jax
				ax:+1
				infotimer = 60*4
				info$ = "Stick 2 Y axis assigned to " + joy_label[j[port].y2id]
			EndIf
	End Select

End Function



' Function JoyWhat#( port:Int=0, axis:Int )
' 	SampleJoy port
' 	Return joy_axis[port*16+axis]
' End Function


Function GetJoyByAxis#( port:Int, axis:Int, invert:Int=1, sc#, db# )
	Local joy#

	Select axis
		Case 0
			joy=JoyX(port)/sc*invert - db
		Case 1
			joy=JoyY(port)/sc*invert - db
		Case 2
			joy=JoyZ(port)/sc*invert - db
		Case 3
			joy=JoyR(port)/sc*invert - db
		Case 4
			joy=JoyU(port)/sc*invert - db
		Case 5
			joy=JoyV(port)/sc*invert - db
		Case 6
			joy=JoyYaw(port)/sc*invert - db
		Case 7
			joy=JoyPitch(port)/sc*invert - db
		Case 8
			joy=JoyRoll(port)/sc*invert - db
		Case 9
			joy=JoyHat(port)/sc*invert - db
		Case 10
			joy=JoyWheel(port)/sc*invert - db
'		Case 11
'			joy=JoyWhat(port,12)/sc*invert - db
'		Case 12
'			joy=JoyWhat(port,13)/sc*invert - db
'		Case 13
'			joy=JoyWhat(port,14)/sc*invert - db
'		Case 14
'			joy=JoyWhat(port,15)/sc*invert - db
	End Select
	Return joy  '/sc * invert)
End Function



Function SetController()

	axis_move_x = j[joyport].x1id-1
	axis_move_y = j[joyport].y1id-1
	axis_fire_x = j[joyport].x2id-1
	axis_fire_y = j[joyport].y2id-1
	axis_move_x_inv = j[joyport].x1invert
	axis_move_y_inv = j[joyport].y1invert
	axis_fire_x_inv = j[joyport].x2invert
	axis_fire_y_inv = j[joyport].y2invert
	axis_move_x_sc = j[joyport].x1scale
	axis_move_y_sc = j[joyport].y1scale
	axis_fire_x_sc = j[joyport].x2scale
	axis_fire_y_sc = j[joyport].y2scale
	axis_move_x_center = j[joyport].x1center
	axis_move_y_center = j[joyport].y1center
	axis_fire_x_center = j[joyport].x2center
	axis_fire_y_center = j[joyport].y2center
	axis_move_x_dz = j[joyport].x1dz
	axis_move_y_dz = j[joyport].y1dz
	axis_fire_x_dz = j[joyport].x2dz
	axis_fire_y_dz = j[joyport].y2dz
	j_d_bomb = j[joyport].bombbutton
	j_d_option = j[joyport].optionbutton

End Function





