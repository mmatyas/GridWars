' GridWars
' (Mark1nc) - www.incitti.com
' markinc @ gmail.com
SuperStrict

?MacOS
Framework BRL.GLMax2D
?Win32
'Framework BRL.D3D7Max2D
Framework BRL.GLMax2D
?Linux
?OpenGLES
Framework SDL.GL2SDLMax2D
?not OpenGLES
Framework BRL.GLMax2D
?

Import BRL.RandomDefault

Import "vectorfont.bmx"
Import "colordefs.bmx"
Import "gridparttrail.bmx"
Import "sound.bmx"
Import "images.bmx"
Import "control.bmx"

?Win32
Import "-luser32"
Extern "win32"
	Function SystemParametersInfoW(stuff1:Int,Stuff2:Int,Stuff3:Int,Stuff4:Int) = "SystemParametersInfoW@16"
EndExtern
Const SPI_SETSCREENSAVEACTIVE:Int = 17
Const SPIF_SENDWININICHANGE:Int = 2
SystemParametersInfoW(SPI_SETSCREENSAVEACTIVE, 0, Null, SPIF_SENDWININICHANGE)
?

?Win32
'SetGraphicsDriver D3D7Max2DDriver()
SetGraphicsDriver GLMax2DDriver()
?
Global g_v_num$ = "5.4"
Global version$ = "Version "+g_v_num+" - Apr 19, 2006"
Global advert$ =  "Visit www.incitti.com for more games."

JoyCount() ' needed to init the joystick stuff

Global cheat:Int = False
Global nokillme:Int = False
Global valid:Int = True
Global mxaim# = 0
Global myaim# = 0

CheckConfDir()
LoadConfig() ' see control.bmx for more global settings
LoadColours()
GetGfxModes()
FindSetting()
SetController()
SetupKeyTable()
SetUp()
LoadSounds()


SeedRnd(MilliSecs())

Global px# = 512
Global py# = 384
Global pr:Int = 0
Global player_shield:Int = 0
Global pscore:Int = 0
Global upgradetime:Int = 20

Global oldmx# = 0
Global oldmy# = 0

Global gameover:Int = False
Global dying:Int = False

Global powerupscore:Int = 1
Global extralifecount:Int = 1
Global extrabombcount:Int = 1

Global lowesthiscore:Int = 0
Global hiscore:Int = 0

Global gcount:Int = 0

Global numshots:Int = 1
Global shottimer:Int = 0
Global shot_back:Int = 0
Global shot_side:Int = 0
Global supershots:Int = 0
Global bouncyshots:Int = 0

Global shotspeed# = 3
Global MAXPLAYERSPEED:Int = 6.5

Global killcount:Int = 0
Global multiplier:Int = 1
'Global multiplieramount:Int[] = [25,50,100,200,400,800,1600,3200,6400,12800]
Global multiplieramount:Int[] =  [25,100,200,400,800,1600,2500,3500,5000,5500]

Global speed_nme# = 1
Global speed_nme1# = 1
Global speed_nme2# = 1
Global speed_nme3# = 1
Global speed_nme4# = 1
Global speed_nme5# = 1
Global speed_nme6# = 1
Global speed_nme7# = 1
Global speed_nme8# = 1
Global speed_le# = 1
Global sp_x:Int = 0
Global sp_t:Int = 0
Global sp_c:Int = 0
Global sp_x2:Int = 0
Global sp_t2:Int = 0
Global sp_c2:Int = 0
Global sp_x3:Int = 0
Global sp_t3:Int = 0
Global sp_c3:Int = 0
Global sp_x4:Int = 0
Global sp_t4:Int = 0
Global sp_c4:Int = 0

Global letter:Int[8]
letter[0] = 32
letter[1] = 32
letter[2] = 32
letter[3] = 32
letter[4] = 32
letter[5] = 32
letter[6] = 32
letter[7] = 32

' top 10 scores, time reached and player names
Global scores:Int[10+1,3]
Global playtimes$[10+1,3]
Global names$[10+1,3]
Global scoresetting$[10+1,3]
Global checksum:Int[10+1,3]

Global tcounter:Int = 0

Global mess$
Global messtime:Int = 0
Global mlen:Int

Local t:Int

Global circ#[36]
For t = 0 To 17
	circ[t*2] = Cos(t*20)*8
	circ[t*2+1] = Sin(t*20)*8
Next

Global SHOT_LIST:TList = New TList
Global nme_LIST:TList = New TList
Global nme1_LIST:TList = New TList
Global nme2_LIST:TList = New TList
Global nme3_LIST:TList = New TList
Global nme4_LIST:TList = New TList
Global nme5_LIST:TList = New TList
Global nme6_LIST:TList = New TList
Global nme7_LIST:TList = New TList
Global nme8_LIST:TList = New TList
Global ge_LIST:TList = New TList
Global le_LIST:TList = New TList
Global pu_LIST:TList = New TList
Global score_list:Tlist = New Tlist


score.LoadScores()
HideMouse()
Main()
ShowMouse()
SaveConfig()
SaveColours() 'only needed once
score.SaveScores()

End







'green square
Type nme
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int

	Function Create:nme( x#, y# ,freeze:Int, close:Int = 0)
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme_born_snd,1, pan, vol)
		Local dir:Int, mag#
		Local n:nme = New nme
		n.x = x
		n.y = y
		n.r =  90'Rand(0,359)
		dir = Rand(0,359)
		mag# = Rnd(2,4)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		Local distx#
		Local disty#
		Local dist#
		Local othern:nme
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 12
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-12
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 12
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-12
			dy = -Abs(dy)
			y = y + dy
		EndIf
		Toward(px,py,PLAYFIELDW)
		BlackHole()
		For othern:nme = EachIn nme_list
			If othern <> Self
				distx# = othern.x-x
				disty# = othern.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 30*30 + 24*24
					dx = dx - Sgn(distx)'/4
					dy = dy - Sgn(disty)'/4
				EndIf
			EndIf
		Next
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_nme
			dx = dx/speed*speed_nme
			dy = dy/speed*speed_nme
		EndIf
		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			If KillPlayer() Then nme_LIST.Remove(Self)
		EndIf

	End Method

	Method blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*8
					dx = dx + ddx/dist/512*(1200-dist)
					dy = dy + ddy/dist/512*(1200-dist)
					If dist < 12+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range:Int)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range
			dx = dx + ddx/dist
			dy = dy + ddy/dist
		EndIf
	End Method

	Method RunAway(x1#,y1#,x2#,y2#)
		Local ddx# = x1-x-(x1-x2)*4
		Local ddy# = y1-y-(y1-y2)*4
		Local bdx# = x1-x2
		Local bdy# = y1-y2
		Local distd# = Sqr(ddx*ddx + ddy*ddy)+0.001
		Local distb# = Sqr(bdx*bdx + bdy*bdy)+0.001
		If distd < 100
			ddx# = -ddx/distd*30
			ddy# = -ddy/distd*30
			ddx#:+ bdx/distb*30
			ddy#:+ bdy/distb*30
			dx = dx + ddx
			dy = dy + ddy
			Local speed# = Sqr(dx*dx+dy*dy)
			If speed > speed_nme*1.1
				dx = dx/speed*speed_nme*1.1
				dy = dy/speed*speed_nme*1.1
			EndIf
		EndIf
	End Method

	Method Kill(points:Int=True)
		If points
			score.IncScore(x,y,100)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound,1.1, pan, vol)
		EndIf
		For Local t:Int = 0 To 15
			part.Create(x,y,6 ,COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B)
		Next
		gridpoint.Shockwave(x,y)
		nme_LIST.Remove(Self)
	End Method

	Method Draw()
		Local sc#
		Local sqa#[]=[0.0,12.0, 12.0,0.0, 0.0,-12.0, -12.0,0.0]
		SetColor COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B
		SetBlend ALPHABLEND
		SetOrigin x-gxoff,y-gyoff
		SetRotation(r+45)
		sc = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		DrawPoly sqa

		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(r)
		DrawImage greensquare,x-gxoff,y-gyoff
		SetRotation 0
		Return
	End Method

End Type




'pink pinwheel
Type nme1
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int

	Function Create:nme1( x#, y# ,freeze:Int, close:Int = 0)
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme1_born_snd,1, pan, vol)
		Local dir:Int,mag#
		Local n:nme1 = New nme1
		n.x = x
		n.y = y
		n.r = 90 'Rand(0,359)
		dir = Rand(0,359)
		mag# = Rnd(.5,2.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme1_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		Local othern:nme1
		Local dist#,distx#,disty#

		If move > 0
			move:-1
			Return
		EndIf
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		'Toward(px,py,400)
		BlackHole()
		For othern:nme1 = EachIn nme1_list
			If othern <> Self
				distx# = othern.x-x
				disty# = othern.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 20*20  + 20*20
					dx = dx - Sgn(distx)
					dy = dy - Sgn(disty)
				EndIf
			EndIf
		Next
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_nme1
			dx = dx/speed*speed_nme1
			dy = dy/speed*speed_nme1
		EndIf

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			If KillPlayer() Then nme1_LIST.Remove(Self)
		EndIf
	End Method

	Method blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*8
					dx = dx + ddx/dist/512*(1200-dist)
					dy = dy + ddy/dist/512*(1200-dist)
					If dist < 12+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

'	Method Toward(xx#,yy#,range:Int)
'		Local ddx# = xx-x
'		Local ddy# = yy-y
'		Local dist# = Sqr(ddx*ddx + ddy*ddy)
'		If dist < range And dist > 16
'			dx = dx + ddx/dist*32
'			dy = dy + ddy/dist*32
'		EndIf
'	End Method

	Method Kill(points:Int=True)
		If points
			score.IncScore(x,y,25)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound,1, pan, vol)
		EndIf
		For Local t:Int = 0 To 15
			part.Create(x,y,6 ,COL_PIN_R,COL_PIN_G,COL_PIN_B,r)
		Next
		gridpoint.Shockwave(x,y)
		nme1_LIST.Remove(Self)
	End Method

	Method Draw()
		Local sc#
		Local sqa#[]=[0.0,12.0, 12.0,0.0, 0.0,-12.0, -12.0,0.0]
		SetColor COL_PIN_R,COL_PIN_G,COL_PIN_B
		SetBlend ALPHABLEND
		SetOrigin x-gxoff,y-gyoff
		SetRotation(r*4+45)
		sc = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		DrawPoly sqa

		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(r*4)
		DrawImage pinkpinwheel,x-gxoff,y-gyoff
		SetRotation 0
		Return

	End Method

End Type



' blue diamonds
Type nme2
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int

	Function Create:nme2( x#, y#,freeze:Int, close:Int = 0 )
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme2_born_snd,1, pan, vol)
		Local dir:Int, mag#
		Local n:nme2 = New nme2
		n.x = x
		n.y = y
		n.r = Rand(0,359)
		dir = Rand(0,359)
		mag# = Rnd(.25,1.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme2_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		Local othern:nme2,distx#,disty#,dist#
		If move > 0
			move:-1
			Return
		EndIf
		r = r + 1
		x = x + dx
		y = y + dy
		If Rand(0,1) Then dx = dx + Rand(-0.2,0.2);dy = dy + Rand(-0.2,0.2)
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		blackhole()
		Toward(px,py,PLAYFIELDW)
		For othern:nme2 = EachIn nme2_list
			If othern <> Self
				distx# = othern.x-x
				disty# = othern.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 30*30 + 20*20
					dx = dx - Sgn(distx)
					dy = dy - Sgn(disty)
				EndIf
			EndIf
		Next
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_nme2
			dx = dx/speed*speed_nme2
			dy = dy/speed*speed_nme2
		EndIf

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			If KillPlayer() Then nme2_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*8
					dx = dx + ddx/dist/512*(1200-dist)
					dy = dy + ddy/dist/512*(1200-dist)
					If dist < 12+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range:Int)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range
			dx = dx + ddx/dist/2
			dy = dy + ddy/dist/2
		EndIf
	End Method

	Method Kill(points:Int=True)
		If points
			score.IncScore(x,y,50)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound,.98, pan, vol)
		EndIf
		For Local t:Int = 0 To 15
			part.Create(x+Rand(-8,8),y+Rand(-8,8),3 ,COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B)
		Next
		gridpoint.Shockwave(x,y)
		nme2_LIST.Remove(Self)
	End Method

	Method Draw()

		Local sc%,scy#,scx#
		sc = r Mod (256)
		If sc > 127
			scy = sc-127
			If sc > 127+63 Then scy = 255-sc
			scx = 0
		Else
			scx = sc
			If sc > 63 Then scx = 127-sc
			scy = 0
		EndIf
		SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
		SetOrigin x-gxoff,y-gyoff
		SetBlend ALPHABLEND
		Local scc# = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale 1+Float(move)/5.0,1+Float(move)/5.0
		Else
			SetAlpha 0.5-scc/8
			SetScale 1.5+scx/16.0,1.5+scy/16.0 'scc,scc
		EndIf
		Local diam#[]=[0.0,12.0+scy/32, 12.0+scx/32,0.0, 0.0,-12.0-scy/32, -12.0-scx/32,0.0]
		DrawPoly diam

		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetBlend lightblend
		SetScale 1+scx/80.0,1+scy/80.0
		DrawImage bluediamond,x-gxoff,y-gyoff
		SetScale 1,1
		Return

	End Method

End Type



' purple squares
Type nme3
	Field x#,y#,dx#,dy#,r#,sz:Int, killer:Int=False
	Field move:Int

	Function Create:nme3( x#, y#, size:Int, freeze:Int, close:Int=0 )
		If CountList(nme3_list) > 100 Then Return Null
		If size <> 0 Or close <> 0
			SafeXY(x,y,px,py,40,1)
		Else
			SafeXY(x , y , px , py , 160)
		EndIf
		If size = 0
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme3_born_snd,1, pan, vol)
		EndIf
		Local dir:Int, mag#
		Local n:nme3 = New nme3
		n.x = x
		n.y = y
		n.sz = size
		n.r = Rand(0,359)
		dir = Rand(0,359)
		mag# = Rnd(.25,2.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme3_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		Local distx#
		Local disty#
		Local dist#
		Local othern3:nme3
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		Toward(px,py,PLAYFIELDW)
		blackhole()
		For othern3:nme3 = EachIn nme3_list
			If othern3 <> Self
				distx# = othern3.x-x
				disty# = othern3.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 30*30 + 20*20 - sz*20
					dx = dx - Sgn(distx)
					dy = dy - Sgn(disty)
				EndIf
			EndIf
		Next
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > (speed_nme3 - sz/4)
			dx = dx/speed*(speed_nme3 - sz/4)
			dy = dy/speed*(speed_nme3 - sz/4)
		EndIf
		x = x + Sin(r*(6+sz))*(sz)
		y = y + Cos(r*(6+sz))*(sz)
		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < (12-sz)*(12-sz) + 12*12
			killer = True
			If KillPlayer() Then nme3_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*8
					dx = dx + ddx/dist/512*(1200-dist)
					dy = dy + ddy/dist/512*(1200-dist)
					If dist < 12+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range1#)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range1
			dx = dx + ddx/dist*2.5
			dy = dy + ddy/dist*2.5
		EndIf
	End Method

	Method Kill(points:Int=True)
		Local t:Int, freq# = 1
		If points
			If sz = 0
				score.IncScore(x,y,100)
				freq = 1
			Else
				score.IncScore(x,y,50)
				freq = 1.25
			EndIf
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound,freq, pan, vol)
			If sz = 0
				For t = 0 To 2
					nme3.Create(x+Rand(-30,-30),y+Rand(-30,30),4,2,1)
				Next
			EndIf
		EndIf
		For t = 0 To 15
			part.Create(x,y,3 ,COL_CUBE_R,COL_CUBE_G,COL_CUBE_B,r)
		Next
		gridpoint.Shockwave(x,y)
		nme3_LIST.Remove(Self)
	End Method

	Method Draw()
		SetColor COL_CUBE_R,COL_CUBE_G,COL_CUBE_B
		SetRotation(r+45)
		SetOrigin x-gxoff,y-gyoff
		SetBlend ALPHABLEND
		Local sc# = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		Local sqa#[]=[0.0,12.0-sz, 12.0-sz,0.0, 0.0,-12.0+sz, -12.0+sz,0.0]
		DrawPoly sqa

		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(r)
		If sz = 0
			DrawImage purplesquare1,x-gxoff,y-gyoff
		Else
			DrawImage purplesquare2,x-gxoff,y-gyoff
		EndIf
		SetRotation 0
		Return
	End Method

End Type



'blue circles
Type nme4
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int
	Field mean:Int

	Function Create:nme4( x# , y# , freeze:Int , m:Int = 0, close:Int = 0)
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme4_born_snd,1, pan, vol)
		Local n:nme4 = New nme4
		n.x = x
		n.y = y
		n.mean = m
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(3.0,6.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme4_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		Local distx#
		Local disty#
		Local dist#
		Local othern4:nme4
		Local speed#
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		Toward(px,py,PLAYFIELDW)
		blackhole()
		For othern4:nme4 = EachIn nme4_list
			If othern4 <> Self
				distx# = othern4.x-x
				disty# = othern4.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 24*24 + 20*20
					dx = dx - Sgn(distx)
					dy = dy - Sgn(disty)
				EndIf
			EndIf
		Next
		speed# = Sqr(dx*dx+dy*dy)
		If speed > (speed_nme4+mean)
			dx = dx/speed*(speed_nme4+mean)
			dy = dy/speed*(speed_nme4+mean)
		EndIf

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 12*12 + 12*12
			killer = True
			If KillPlayer() Then nme4_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*6
					dx = dx + ddx/dist/1024*(700-dist)
					dy = dy + ddy/dist/1024*(700-dist)
					If dist < n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range1:Int)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range1
			dx = dx + ddx/dist*4
			dy = dy + ddy/dist*4
		EndIf
	End Method

	Method Kill(points:Int=True)
		If points
			score.IncScore(x,y,10)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound,1, pan, vol)
		EndIf
		For Local t:Int = 0 To 15
			part.Create(x,y, 2 ,COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B,t*24+r)
		Next
		gridpoint.Shockwave(x,y)
		nme4_LIST.Remove(Self)
	End Method

	Method Draw()
		SetColor COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B
		SetOrigin x-gxoff,y-gyoff
		SetBlend ALPHABLEND
		Local sc# = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		DrawPoly circ

		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		DrawImage bluecircle,x-gxoff,y-gyoff
		Return
	End Method

End Type





' red circles
Type nme5
	Field x#,y#,dx#,dy#,r#,sz#, active:Int
	Field absorbcount:Int,killer:Int=False
	Field sndchindex:Int
	Field move:Int
	Field gcenterx#
	Field gcentery#
	Field ex:Int = False
	Field pulse#

	Global sndindex:Int = 0

	Function CreateDisplayEffect(x#, y#, size#)
		Local cnt:Int = CountList(nme5_list)
		If cnt > 15 Then Return
		Local n:nme5 = New nme5
		n.x = x
		n.y = y
		n.sz = size
		n.gcenterx# = x
		n.gcentery# = y
		n.active = 1
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(1,4)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		nme5_list.AddLast( n )
	EndFunction

	Method UpdateDisplayEffect()
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 32
			dx = Abs(dx)
			x = x + dx
		ElseIf x > SCREENW-32
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 32
			dy = Abs(dy)
			y = y + dy
		ElseIf y > SCREENH-32
			dy = -Abs(dy)
			y = y + dy
		EndIf
		gcenterx# = x+Sin(r*2)*sz/2.5
		gcentery# = y+Cos(r*2)*sz/2.5
		If active
'			If r Mod 6 = 0
'				For Local pp:Int = 0 To 7
'					part.Create(x+Sin(pp*45)*sz*3,y+Cos(pp*45)*sz*3, 7,rcol,gcol,bcol, r+pp*45,0)
'				Next
'			EndIf
			If r Mod 25 = 0
'				For Local pp:Int = 0 To 7
'					part.Create(x+Sin(r)*sz*2+Sin(pp*45)*8,y+Cos(r)*sz*2+Cos(pp*45)*8, 7,rcol,gcol,bcol, 0,0)
'				Next
				For Local pp:Int = 0 To 7
					part.Create(x+Sin(r)*sz*1.25+Sin(pp*45)*8,y+Cos(r)*sz*1.25+Cos(pp*45)*8, 7,rcol,gcol,bcol,0,0)
				Next
			EndIf
		EndIf
	End Method


	Function Create( x#, y#, size# ,freeze:Int, close:Int = 0 )
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local cnt:Int = CountList(nme5_list)
		If cnt > 3 Then Return
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme5_born_snd,1, pan, vol)
		Local n:nme5 = New nme5
		n.sndchindex = sndindex
		sndindex:+1;If sndindex > 7 Then sndindex = 0
		n.x = x
		n.y = y
		n.gcenterx# = x
		n.gcentery# = y
		n.sz = size
		n.absorbcount = 0
		n.active = 0
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(.05,.5)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme5_list.AddLast( n )
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 16
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-16
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 16
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-16
			dy = -Abs(dy)
			y = y + dy
		EndIf
		gcenterx# = x+Sin(r*3)*sz/2.5
		gcentery# = y+Cos(r*3)*sz/2.5
		If active Then gridpoint.Pull(x,y,5+sz/2) '/3
 		DoubleSun()
		Local distx# = x-px
		Local disty# = y-py
		Local dist# = (distx * distx + disty * disty)
		If dist < (12+sz/2)*(12+sz/2)+12*12
			killer = True
			If KillPlayer() Then nme5_LIST.Remove(Self)
		EndIf

		If active
			If r Mod 60 = 0
'				For Local pp:Int = 0 To 7
'					part.Create(x+Sin(pp*45)*sz*3,y+Cos(pp*45)*sz*3, 7,rcol,gcol,bcol, r+pp*45,0)
'				Next
				For Local pp:Int = 0 To 7
					part.Create(x+Sin(r)*sz*1.15+Sin(r+pp*45)*3,y+Cos(r)*sz*1.15+Cos(r+pp*45)*3, 7,rcol,gcol,bcol,r+pp*45)
				Next
			EndIf
			If r Mod 25 = 0 ' 2 times per second
				If sunloopchan[sndchindex] <> Null
					Local pan# = (x-px)/PLAYFIELDW
					Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
					SetPanAndVolume(sunloopchan[sndchindex], pan, vol)
				EndIf
			EndIf
		EndIf
	End Method

	Method DoubleSun()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5 <> Self
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local mag# = (n5.sz-sz)/8
				If mag < 1 Then mag = 1
				If mag > 8 Then mag = 8
				Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
				If dist < (n5.sz*2+sz*2) + 64
					ddx# = ddx/dist*mag
					ddy# = ddy/dist*mag
					If dist < n5.sz+sz
						ddx# = -ddx# - ddy#*.25
						ddy# = -ddy# - ddx#*.25
					EndIf
					dx = dx + ddx
					dy = dy + ddy
					Local speed# = Sqr(dx*dx+dy*dy)
					If speed > speed_nme5
						dx = dx/speed*speed_nme5
						dy = dy/speed*speed_nme5
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Kill(points:Int=True)
		Local t:Int, rate#
		If active = False
			active = True
			If sunloopchan[sndchindex] <> Null
				StopChannel(sunloopchan[sndchindex])
			EndIf
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			sunloopchan[sndchindex] = PlaySound2(nme5_loop_snd,1, pan, vol)
			gridpoint.Push(x,y,6,1)
		EndIf
		sz = sz - 0.75 ' sz goes from 4 to 64
		rate = sz/16
		If sunloopchan[sndchindex] <> Null Then SetChannelRate( sunloopchan[sndchindex], rate# )
		If points = False Then sz = 0
		For t = 0 To 3
			part.Create(x,y, 0 ,COL_SUN_R,COL_SUN_G,COL_SUN_B)
		Next
		If sz < 4
			'gridpoint.pull(x,y,16,10)
			gridpoint.Push(x,y,8,2)
			If sunloopchan[sndchindex] <> Null Then StopChannel(sunloopchan[sndchindex])
			nme5_LIST.Remove(Self)
			For t = 0 To 31
				part.Create(x,y, 0 ,COL_SUN_R,COL_SUN_G,COL_SUN_B)
			Next
			If points
				Local sc:Int = 150
				sc:+ absorbcount*(absorbcount+1)/3*5
				score.IncScore(x,y,sc)
			EndIf
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme5_killed_snd,1, pan, vol)
		Else
			Local freq# = 1.1+(64-sz)/64
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme5_shrink_snd, freq, pan, vol)
		EndIf
	End Method

	Method Grow(amnt#=1)
		Local t:Int,rate#
		Local speedup#,xx:Int,yy:Int

		absorbcount:+1
		speedup = 1+Float(gcount/(50*60*6)) 'increase by 1 every 6 minutes
		If speedup > 5 Then speedup = 5
		sz = sz + amnt*speedup

		rate = sz/16
		If active = False
			active = True
			If sunloopchan[sndchindex] <> Null
				StopChannel(sunloopchan[sndchindex])
			EndIf
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			sunloopchan[sndchindex] = PlaySound2(nme5_loop_snd, 1, pan, vol)
			gridpoint.Push(x,y,6,1)
		EndIf
		If sunloopchan[sndchindex] <> Null Then SetChannelRate( sunloopchan[sndchindex] , rate# )
		If sz > 64
			If sunloopchan[sndchindex] <> Null Then StopChannel(sunloopchan[sndchindex] )
			For t = 0 To 15
				xx= x+Cos(t*22.5)*20
				yy= y+Sin(t*22.5)*20
				nme4.Create(xx,yy,4,1,1)	' 1=mean - move faster
			Next
			For t = 0 To 17
				xx= x+Cos(t*20)*30
				yy= y+Sin(t*20)*30
				nme8.Create(xx,yy,4,1)
			Next
			nme5_LIST.Remove(Self)
			For t = 0 To 35
				part.Create(x+Sin(t*10)*20,y+Cos(t*10)*20, 0 ,COL_SUN_R,COL_SUN_G,COL_SUN_B)
			Next
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme5_explode_snd, 1, pan, vol)
		Else
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme5_grow_snd, 1, pan, vol)
		EndIf
	End Method


	Method Draw()

		Local szz# = .25+sz/64
		SetColor COL_SUN_R,COL_SUN_G,COL_SUN_B
		SetOrigin x-gxoff,y-gyoff
		SetBlend ALPHABLEND
		Local sc# = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc+sz/16,sc+sz/16
		EndIf
		DrawPoly circ
		If active = True
			pulse = pulse + sz/2
			szz = szz + Cos(pulse)/6
		EndIf
		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale szz,szz
		SetBlend lightblend
		DrawImage redcircle,x-gxoff,y-gyoff
		SetScale 1,1
		Return

	End Method

End Type





'snake
Type nme6
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field ishead:Int, die:Int
	Field tail:nme6, sz:Int
	Field head:nme6
	Field move:Int
	Field rot:Int,rotdir:Int
	Global segdir:Int = 20

	Function Create:nme6( x#, y#, length:Int, freeze:Int, rr:Int=0, hdx#=0,hdy#=0, close:Int = 0 )
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		If CountList(nme6_list) > 16 * 24 Then Return Null
		Local dir:Int,mag#
		Local n:nme6 = New nme6
		n.x = x
		n.y = y
		n.r = Rand(0,359)
		n.move = freeze
		n.sz = length
		n.die = False
		If length = 24
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme6_born_snd, 1, pan, vol)
			n.ishead = True
			n.head = Null
			n.rot = n.r
			n.rotdir = Rand(0,1)
			mag# = Rnd(0.5,2)
			n.dx = Cos(n.rot)*mag
			n.dy = Sin(n.rot)*mag
			rr = n.rot+180
		Else
			n.ishead = False
			n.dx = hdx
			n.dy = hdy
		EndIf
		If length > 0
			If length Mod 3 = 0 Then If Rand(0,1) = 1 Then segdir = -segdir
			Local ndx:Int = 0'Cos(rr)*15
			Local ndy:Int = 0'Sin(rr)*15
			n.tail = nme6.Create(x+ndx,y+ndy,length-1,freeze, rr+segdir, -ndx , -ndy, 0 )
			n.tail.head = n
		Else
			n.tail = Null
		EndIf
		nme6_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		Local speed#, distx#,disty#,dist#
		If move > 0
			move:-1
			If die
				If tail <> Null
					tail.die = True
					tail.move = move
				EndIf
				Explode()
			EndIf
			Return
		EndIf
		r = r + 1
		If head <> Null
			distx# = head.x-x
			disty# = head.y-y
			dist# = Sqr(distx * distx + disty * disty)
			If dist > 15
				dx = distx/dist*speed_nme6
				dy = disty/dist*speed_nme6
			Else
				If dist = 0 Then dist = 0.001
				dx = distx/dist/32
				dy = disty/dist/32
			EndIf
		EndIf
		If ishead
			dx = dx + Cos(rot)*speed_nme6
			dy = dy + Sin(rot)*speed_nme6
			If rotdir = 0
				rot:+ 4
			Else
				rot:- 4
			EndIf
			If Rand(1,100) > 90 Then rotdir = 1 - rotdir
		EndIf
		'Toward(px,py,400)
		If ishead Then BlackHole()
		speed# = Sqr(dx*dx+dy*dy)
		If speed >  speed_nme6
			dx = dx/speed*speed_nme6
			dy = dy/speed*speed_nme6
		EndIf
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
			rot = rot + 90
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
			rot = rot + 90
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
			rot = rot + 90
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
			rot = rot + 90
		EndIf
		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			MarkKiller()
			If KillPlayer() Then nme6_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*5
					dx = dx + ddx/dist/1024*(1200-dist)
					dy = dy + ddy/dist/1024*(1200-dist)
					If dist < 12+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Kill(points:Int=True)
		Local t:Int
		If ishead
			If points
				score.IncScore(x,y,100)
				Local pan# = (x-px)/PLAYFIELDW
				Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
				PlaySound2(quarkhitsound, 1, pan, vol)
			EndIf
			For t = 0 To 31
				part.Create(x,y,0 ,COL_SNAKE_R,COL_SNAKE_G,COL_SNAKE_B)
			Next
			gridpoint.Shockwave(x,y)
			If tail <> Null
				tail.die = True
				If points
					tail.move = 30
				Else
					tail.move = 300
				EndIf
			EndIf
			nme6_LIST.Remove(Self)
		Else
			If points
				Local pan# = (x-px)/PLAYFIELDW
				Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
				PlaySound2(nme6_tailhit_snd, 1, pan, vol)
			EndIf
			For t = 0 To 7
				part.Create(x,y,0 ,COL_TAIL_R,COL_TAIL_G,COL_TAIL_B)
			Next
		EndIf
	End Method

	Method MarkKiller()
		Local hd:nme6,tl:nme6
		' go up head and down tail marking killer
		hd = head
		While hd <> Null
			hd.killer = True
			hd = hd.head
		Wend
		tl = tail
		While tl <> Null
			tl.killer = True
			tl = tl.tail
		Wend
	End Method


	Method Explode()
		nme6_LIST.Remove(Self)
		If move < 50
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme6_tailexplode_snd, 1, pan, vol)
		EndIf
		For Local t:Int = 0 To 7
			part.Create(x,y,0 ,COL_TAIL_R,COL_TAIL_G,COL_TAIL_B)
		Next
	End Method

	Method Draw()
		Local roti:Int
		roti = ATan2(dy,dx)+90
		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(roti)
		If sz = 24
			DrawImage snakehead,x-gxoff,y-gyoff
		Else
			DrawImage snaketail,x-gxoff,y-gyoff,sz
		EndIf
		SetRotation 0
		Return
	End Method

End Type




'red clone
Type nme7
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int
	Field rot:Int,rotdir:Int,lastplayed:Int
	Field xrgt#,yrgt#,xlft#,ylft#

	Function Create( x#, y#, freeze:Int, close:Int = 0 )
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		If CountList(nme7_list) > 3 And Rand(0,100) > 50 Then Return
		If CountList(nme7_list) > 7 Then Return
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme7_born_snd, 1, pan, vol)
		Local dir:Int,mag#
		Local n:nme7 = New nme7
		n.move = freeze
		n.x = x
		n.y = y
		dir = Rand(0,359)
		mag# = Rnd(0.5,2)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.r = Rand(0,359)

		n.rot = n.r
		n.rotdir = TurnToFace(n.x,n.y,n.dx,n.dy,PLAYFIELDW/2,PLAYFIELDH/2) ' turn towards center
		If Abs(n.rotdir) < 16
			n.rotdir = 16
		EndIf
		nme7_list.AddLast( n )
		Return
	EndFunction

	Method Update()
		Local speed#, distx#,disty#,dist#,dx2#,dy2#
		If move > 0
			move:-1
			Return
		EndIf
		r = (r + 16) Mod 360
		If Rand(1,100) > 95-speed_nme7*8
			rotdir = TurnToFace(x,y,dx,dy,px,py)
		EndIf
		If rotdir <> 0
			rot:+ 4*Sgn(rotdir)
			rotdir = rotdir - Sgn(rotdir)
		EndIf
		If rotdir = 0 And lastplayed = 0
			lastplayed = 60
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(nme7_shield_snd, 1, pan, vol)
		EndIf
		If lastplayed > 0 Then lastplayed:-1
		If Abs(rotdir) < 20
			dx = dx + Cos(rot)*2
			dy = dy + Sin(rot)*2
			gridpoint.Push(x+dx*8,y+dy*8,4,.1)
		Else
			dx = (dx + Cos(rot))*(0.265+speed_nme7/20)
			dy = (dy + Sin(rot))*(0.265+speed_nme7/20)
		EndIf
		x = x + dx
		y = y + dy
		If x < 16
			x = x - dx
			y = y - dy
			'rotdir = rotdir + 180
		ElseIf x > PLAYFIELDW-16
			x = x - dx
			y = y - dy
			'rotdir = rotdir + 180
		EndIf
		If y < 16
			x = x - dx
			y = y - dy
			'rotdir = rotdir + 180
		ElseIf y > PLAYFIELDH-16
			x = x - dx
			y = y - dy
			'rotdir = rotdir + 180
		EndIf
		'Toward(px,py,400)
		BlackHole()
		For Local othern7:nme7 = EachIn nme7_list
			If othern7 <> Self
				distx# = othern7.x-x
				disty# = othern7.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 20*20 + 20*20
					dx = dx - Sgn(distx)
					dy = dy - Sgn(disty)
				EndIf
			EndIf
		Next
		speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_nme7
			dx = dx/speed*speed_nme7
			dy = dy/speed*speed_nme7
		EndIf
		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			If KillPlayer() Then nme7_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*8
					dx = dx + ddx/dist/512*(1200-dist)
					dy = dy + ddy/dist/512*(1200-dist)
					If dist < 16+n5.sz/2
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

'	Method Toward(xx#,yy#,range:Int)
'		Local ddx# = xx-x
'		Local ddy# = yy-y
'		Local dist# = Sqr(ddx*ddx + ddy*ddy)
'		If dist < range And dist > 2
'			dx = dx + ddx/dist*32
'			dy = dy + ddy/dist*32
'		EndIf
'	End Method

	Method Kill(points:Int=True)
		Local t:Int
		If points
			score.IncScore(x,y,100)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhit2sound, 1, pan, vol)
		EndIf
		For t = 0 To 15
			part.Create(x,y,6 ,COL_CLONE_R,COL_CLONE_G,COL_CLONE_B)
		Next
		gridpoint.Shockwave(x,y)
		nme7_LIST.Remove(Self)
	End Method

	Method Draw()
		SetColor 255,255,255
		SetBlend lightblend
		SetRotation(rot+90)
		DrawImage redclone,x-gxoff,y-gyoff
		SetColor COL_CLONE_R,COL_CLONE_G,COL_CLONE_B
		SetRotation 0
		Local xr#[8],yr#[8]
		xr[0] = x-6
		yr[0] = y
		xr[1] = x+6
		yr[1] = y
		xr[2] = x+6
		yr[2] = y+12
		xr[3] = x+12
		yr[3] = y+12
		xr[6] = x-12
		yr[6] = y+12
		TFormR(x,y, rot+270, xr[0] ,yr[0] )
		TFormR(x,y, rot+270, xr[1] ,yr[1] )
		TFormR(x,y, rot+270, xr[2] ,yr[2] )
		TFormR(x,y, rot+270, xr[3] ,yr[3] )
		TFormR(x,y, rot+270, xr[6] ,yr[6] )
		Local pry# = yr[2]-yr[1]
		Local prx# = xr[2]-xr[1]
		If Abs(rotdir) <= 4
			For Local t# = 1.5+r/360 To 3.5+r/360
				DrawLine xr[3]+prx*t+(xr[0]-x)*t*1.5-gxoff,..
				yr[3]+pry*t+(yr[0]-y)*t*1.5-gyoff,..
				xr[6]+prx*t+(xr[1]-x)*t*1.5-gxoff,..
				yr[6]+pry*t+(yr[1]-y)*t*1.5-gyoff,0
			Next
		EndIf
		Local xn#,yn#
		Local sz# = Sqr(dx*dx + dy*dy)
		If sz = 0
			xn# = 1
			yn# = 1
		Else
			xn# = -dy/sz
			yn# = dx/sz
		EndIf
		xrgt# = x+yn*64+xn*36
		yrgt# = y-xn*64+yn*36
		xlft# = x+yn*64-xn*36
		ylft# = y-xn*64-yn*36
		Return
	End Method

End Type


'blue butterflies
Type nme8
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field move:Int

	Function Create:nme8( x# , y# , freeze:Int , close:Int = 0)
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(nme8_born_snd, 1, pan, vol)
		Local n:nme8 = New nme8
		n.x = x
		n.y = y
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(3.0,6.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		nme8_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		Local distx#
		Local disty#
		Local dist#
		Local othern8:nme8
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		Toward(px,py,PLAYFIELDW)
		blackhole()
		For othern8:nme8 = EachIn nme8_list
			If othern8 <> Self
				distx# = othern8.x-x
				disty# = othern8.y-y
				dist# = (distx * distx + disty * disty)
				If dist < 16*16 + 16*16
					dx = dx - Sgn(distx)/8
					dy = dy - Sgn(disty)/8
				EndIf
			EndIf
		Next
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_nme8
			dx = dx/speed*speed_nme8
			dy = dy/speed*speed_nme8
		EndIf

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 12*12 + 12*12
			killer = True
			If KillPlayer() Then nme8_LIST.Remove(Self)
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*5
					dx = dx + ddx/dist/2048*(500-dist)
					dy = dy + ddy/dist/2048*(500-dist)
					If dist < 12+n5.sz
						Kill(False)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range1#)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range1
			dx = dx + ddx/dist*2
			dy = dy + ddy/dist*2
		EndIf
	End Method

	Method Kill(points:Int=True)
		If points
			score.IncScore(x,y,10)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(quarkhitsound, 1, pan, vol)
		EndIf
		For Local t:Int = 0 To 8
			part.Create(x,y, 8 ,COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B,t*120+r)
		Next
		gridpoint.Shockwave(x,y)
		nme8_LIST.Remove(Self)
	End Method

	Method Draw()
		Local sc#
		Local tri#[]=[0.0,-10.0, 8.0,6.0, -8.0,6.0]
		SetColor COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B
		SetBlend alphablend
		SetOrigin x-gxoff,y-gyoff
		SetRotation(r*8)
		sc = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		DrawPoly tri
		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(r*8)
		DrawImage indigotriangle,x-gxoff,y-gyoff
		SetRotation 0
		Return
	End Method

End Type








' generators
Type ge
	Field x#,y#,r#,kind:Int,rate:Int,sz#,killer:Int=False
	Field move:Int

	Function Create:ge( x#, y#, kind:Int, rate:Int, size:Int ,freeze:Int)
		SafeXY(x,y,px,py,160)
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(ge_born_snd, 1, pan, vol)
		Local g:ge = New ge
		g.x = x
		g.y = y
		g.sz = size
		g.r = Rand(0,359)
		g.rate = rate
		g.kind = kind
		g.move = freeze
		ge_list.AddLast( g )
		Return g
	EndFunction

	Method Update()
		If move > 0
			move:-1
			Return
		EndIf
		r = r + 1
		Local distx# = x-px
		Local disty# = y-py
		Local dist# = (distx * distx + disty * disty)
		If dist < (12+sz/2)*(12+sz/2)+12*12
			killer = True
			KillPlayer()
		EndIf

		If r Mod (rate+42-sz) = 0 Then birth()

	End Method

	Method Birth()
		gridpoint.Push(x , y , 6 , .9)
		Select kind
			Case 1 ' pink spinners
				nme1.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
			Case 2 ' blue diamonds
				nme2.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
			Case 3 ' green squares
				nme.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
			Case 4 ' purple cubes
				nme3.create(x+Rand(-10,10),y+Rand(-10,10),0,5,1)
			Case 5 ' blue circles
				nme4.create(x+Rand(-10,10),y+Rand(-10,10),5,0,1)
			Case 6 ' red circles
				nme5.create(x+Rand(-10,10),y+Rand(-10,10),10,5,1)
			Case 7 ' orange triangles
				le.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
			Case 8 ' snakes
				nme6.create(x+Rand(-10,10),y+Rand(-10,10),24,5,1)
			Case 9 ' red clone
				nme7.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
			Case 10 ' butterflies
				nme8.create(x+Rand(-10,10),y+Rand(-10,10),5,1)
		End Select
	End Method

	Method Kill(points:Int=True)
		sz = sz - 1
		If points = False Then sz = 0
		For Local t:Int = 0 To 3 + (sz<1)*8 ' 1 or 8
			Select kind
				Case 1 ' pink spinners
					part.Create(x,y, 0 ,COL_PIN_R,COL_PIN_G,COL_PIN_B)
				Case 2 ' blue diamonds
					part.Create(x,y, 0 ,COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B)
				Case 3 ' green squares
					part.Create(x,y, 0 ,COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B)
				Case 4 ' purple cubes
					part.Create(x,y, 0 ,COL_CUBE_R,COL_CUBE_G,COL_CUBE_B)
				Case 5 ' blue circles
					part.Create(x,y, 0 ,COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B)
				Case 6 ' red circles
					part.Create(x,y, 0 ,COL_SUN_R,COL_SUN_G,COL_SUN_B)
				Case 7 ' orange triangles
					part.Create(x,y, 0 ,COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B)
				Case 8 ' snake
					part.Create(x,y, 0 ,COL_SNAKE_R,COL_SNAKE_G,COL_SNAKE_B)
				Case 9 ' clone
					part.Create(x,y, 0 ,COL_CLONE_R,COL_CLONE_G,COL_CLONE_B)
				Case 10 ' butterfly
					part.Create(x,y, 0 ,COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B)
			End Select
		Next

		If sz < 1
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(ge_killed_snd, 1, pan, vol)
			If points Then score.IncScore(x,y,200)
			ge_LIST.Remove(Self)
		Else
			Local freq# = 1+(sz)/64
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(ge_hit_snd, freq, pan, vol)
			If points Then score.IncScore(x,y,1,False)
		EndIf
	End Method

	Method Draw()
		Local sc#,scy#,scx#,zz#,zs#,t:Int
		Local x1#,x2#,x3#,x4#,y1#,y2#,y3#,y4#
		Local sqa#[]=[12.0,12.0, 12.0,-12.0, -12.0,-12.0, -12.0,12.0]
		Local diam#[]=[0.0,12.0, 12.0,0.0, 0.0,-12.0, -12.0,0.0]
		Local tri#[]=[0.0,8.0, 6.0,-4.0, -6.0,-4.0]
		Local staywhite:Int = False

		SetColor 255,255,255
		If (r+8) Mod (rate+42-sz) < 8 Then staywhite = True

		Select kind
			Case 2 ' blue diamonds
				If Not staywhite SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
				SetScale sz/14,sz/14
				SetAlpha 0.1+sz/256
				SetOrigin x-gxoff,y-gyoff
				DrawPoly diam
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				DrawLine x-gxoff,y-gyoff-12-sz/4,x-gxoff+12+sz/4,y-gyoff,0
				DrawLine x-gxoff+12+sz/4,y-gyoff,x-gxoff,y-gyoff+12+sz/4,0
				DrawLine x-gxoff,y-gyoff+12+sz/4,x-gxoff-12-sz/4,y-gyoff,0
				DrawLine x-gxoff-12-sz/4,y-gyoff,x-gxoff,y-gyoff-12-sz/4,0
				DrawLine x-gxoff,y-gyoff-8,x-gxoff+8,y-gyoff,0
				DrawLine x-gxoff+8,y-gyoff,x-gxoff,y-gyoff+8,0
				DrawLine x-gxoff,y-gyoff+8,x-gxoff-8,y-gyoff,0
				DrawLine x-gxoff-8,y-gyoff,x-gxoff,y-gyoff-8,0

			Case 3 ' green squares
				If Not staywhite SetColor COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/16,sz/16
				SetAlpha 0.1+sz/256
				DrawPoly sqa
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zz = 8+sz/4
				x1 = x-zz-gxoff
				y1 = y-zz-gyoff
				x2 = x+zz-gxoff
				y2 = y-zz-gyoff
				x3 = x+zz-gxoff
				y3 = y+zz-gyoff
				x4 = x-zz-gxoff
				y4 = y+zz-gyoff
				DrawLine x1,y1,x2,y2,0
				DrawLine x2,y2,x3,y3,0
				DrawLine x3,y3,x4,y4,0
				DrawLine x4,y4,x1,y1,0
				DrawLine x-gxoff-8,y-gyoff-8,x-gxoff+8,y-gyoff-8,0
				DrawLine x-gxoff+8,y-gyoff-8,x-gxoff+8,y-gyoff+8,0
				DrawLine x-gxoff+8,y-gyoff+8,x-gxoff-8,y-gyoff+8,0
				DrawLine x-gxoff-8,y-gyoff+8,x-gxoff-8,y-gyoff-8,0

			Case 4 ' purple cubes
				If Not staywhite SetColor COL_CUBE_R,COL_CUBE_G,COL_CUBE_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/16,sz/16
				SetAlpha 0.1+sz/256
				DrawPoly sqa
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zz = 8+sz/4
				x1 = x-zz-gxoff
				y1 = y-zz-gyoff
				x2 = x+zz-gxoff
				y2 = y-zz-gyoff
				x3 = x+zz-gxoff
				y3 = y+zz-gyoff
				x4 = x-zz-gxoff
				y4 = y+zz-gyoff
				DrawLine x1,y1,x2,y2,0
				DrawLine x2,y2,x3,y3,0
				DrawLine x3,y3,x4,y4,0
				DrawLine x4,y4,x1,y1,0
				DrawLine x-gxoff-8,y-gyoff-8,x-gxoff+8,y-gyoff-8,0
				DrawLine x-gxoff+8,y-gyoff-8,x-gxoff+8,y-gyoff+8,0
				DrawLine x-gxoff+8,y-gyoff+8,x-gxoff-8,y-gyoff+8,0
				DrawLine x-gxoff-8,y-gyoff+8,x-gxoff-8,y-gyoff-8,0

			Case 5 ' blue circles
				If Not staywhite SetColor COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/8,sz/8
				SetAlpha 0.1+sz/256
				DrawPoly circ
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zs# = (1+sz/16)/1.1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0
				zs# = 1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0

			Case 6 ' red circles
				If Not staywhite SetColor COL_SUN_R,COL_SUN_G,COL_SUN_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/8,sz/8
				SetAlpha 0.1+sz/256
				DrawPoly circ
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zs# = (1+sz/16)/1.1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0
				zs# = 1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0

			Case 7 ' orange triangles
				If Not staywhite SetColor COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/8,sz/8
				SetAlpha 0.1-sc/256
				DrawPoly tri
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				DrawLine x-gxoff,y-gyoff+12+sz/4,x-gxoff+9+sz/4,y-gyoff-4-sz/4,0
				DrawLine x-gxoff+9+sz/4,y-gyoff-4-sz/4,x-gxoff-9-sz/4,y-gyoff-4-sz/4,0
				DrawLine x-gxoff-9-sz/4,y-gyoff-4-sz/4,x-gxoff,y-gyoff+12+sz/4,0
				DrawLine x-gxoff,y-gyoff+12,x-gxoff+9,y-gyoff-4,0
				DrawLine x-gxoff+9,y-gyoff-4,x-gxoff-9,y-gyoff-4,0
				DrawLine x-gxoff-9,y-gyoff-4,x-gxoff,y-gyoff+12,0

			Case 1 ' pink spinners
				If Not staywhite SetColor COL_PIN_R,COL_PIN_G,COL_PIN_B
				SetScale sz/14,sz/14
				SetAlpha 0.1+sz/256
				SetOrigin x-gxoff,y-gyoff
				DrawPoly diam
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				DrawLine x-gxoff,y-gyoff-12-sz/4,x-gxoff+12+sz/4,y-gyoff,0
				DrawLine x-gxoff+12+sz/4,y-gyoff,x-gxoff,y-gyoff+12+sz/4,0
				DrawLine x-gxoff,y-gyoff+12+sz/4,x-gxoff-12-sz/4,y-gyoff,0
				DrawLine x-gxoff-12-sz/4,y-gyoff,x-gxoff,y-gyoff-12-sz/4,0
				DrawLine x-gxoff,y-gyoff-8,x-gxoff+8,y-gyoff,0
				DrawLine x-gxoff+8,y-gyoff,x-gxoff,y-gyoff+8,0
				DrawLine x-gxoff,y-gyoff+8,x-gxoff-8,y-gyoff,0
				DrawLine x-gxoff-8,y-gyoff,x-gxoff,y-gyoff-8,0

			Case 8 ' purple snake
				If Not staywhite SetColor COL_SNAKE_R,COL_SNAKE_G,COL_SNAKE_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/8,sz/8
				SetAlpha 0.1+sz/256
				DrawPoly circ
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zs# = (1+sz/16)/1.1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0
				zs# = 1
				For t = 0 To 16
					DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
						x-gxoff+circ[t*2+2]*zs,y-gyoff+circ[t*2+1+2]*zs,0
				Next
				DrawLine x-gxoff+circ[t*2]*zs,y-gyoff+circ[t*2+1]*zs,..
					x-gxoff+circ[0]*zs,y-gyoff+circ[1]*zs,0

			Case 9 ' red clone
				If Not staywhite SetColor COL_CLONE_R,COL_CLONE_G,COL_CLONE_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/16,sz/16
				SetAlpha 0.1+sz/256
				DrawPoly sqa
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				zz = 8+sz/4
				x1 = x-zz-gxoff
				y1 = y-zz-gyoff
				x2 = x+zz-gxoff
				y2 = y-zz-gyoff
				x3 = x+zz-gxoff
				y3 = y+zz-gyoff
				x4 = x-zz-gxoff
				y4 = y+zz-gyoff
				DrawLine x1,y1,x2,y2,0
				DrawLine x2,y2,x3,y3,0
				DrawLine x3,y3,x4,y4,0
				DrawLine x4,y4,x1,y1,0
				DrawLine x-gxoff-8,y-gyoff-8,x-gxoff+8,y-gyoff-8,0
				DrawLine x-gxoff+8,y-gyoff-8,x-gxoff+8,y-gyoff+8,0
				DrawLine x-gxoff+8,y-gyoff+8,x-gxoff-8,y-gyoff+8,0
				DrawLine x-gxoff-8,y-gyoff+8,x-gxoff-8,y-gyoff-8,0

			Case 10 ' blue butterflies
				If Not staywhite SetColor COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B
				SetOrigin x-gxoff,y-gyoff
				SetScale sz/8,sz/8
				SetAlpha 0.1-sc/256
				DrawPoly tri
				SetAlpha 1
				SetScale 1,1
				SetOrigin 0,0
				DrawLine x-gxoff,y-gyoff+12+sz/4,x-gxoff+9+sz/4,y-gyoff-4-sz/4,0
				DrawLine x-gxoff+9+sz/4,y-gyoff-4-sz/4,x-gxoff-9-sz/4,y-gyoff-4-sz/4,0
				DrawLine x-gxoff-9-sz/4,y-gyoff-4-sz/4,x-gxoff,y-gyoff+12+sz/4,0
				DrawLine x-gxoff,y-gyoff+12,x-gxoff+9,y-gyoff-4,0
				DrawLine x-gxoff+9,y-gyoff-4,x-gxoff-9,y-gyoff-4,0
				DrawLine x-gxoff-9,y-gyoff-4,x-gxoff,y-gyoff+12,0

		End Select
	End Method

End Type



'line end
Type le
	Field x#,y#,dx#,dy#,r#,killer:Int=False
	Field attached:Int, le2:le, strength#
	Field checked:Int
	Field move:Int, resist:Int = False

	Function Create:le( x#, y#,freeze:Int, close:Int = 0 )
		If close = 0
			SafeXY(x,y,px,py,160)
		Else
			SafeXY(x,y,px,py,40,1)
		EndIf
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(le_born_snd, 1, pan, vol)
		Local n:le = New le
		n.x = x
		n.y = y
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(.25,1.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.attached = False
		n.le2 = Null
		n.move = freeze
		le_list.AddLast( n )
		Return n
	EndFunction

	Method Update()
		Local distx#
		Local disty#
		Local dist#
		If move > 0
			move:-1
			Return
		EndIf
		checked = False
		r = r + 2
		Local ll:le
		For ll:le = EachIn le_list
			If ll <> Self
				If attached = False
					distx# = x-ll.x
					disty# = y-ll.y
					dist# = (distx * distx + disty * disty)
					If dist < 32*32
						If ll.attached = False
							attached = True
							strength = 25
							le2 = ll
							ll.attached = True
							ll.le2 = Self
							ll.strength = 25
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		If attached = True
			TowardPartner(le2.x,le2.y)
			If resist = False Then BlackHole2()
		Else
			toward(px,py,300)
			BlackHole()
		EndIf

		Local speed# = Sqr(dx*dx+dy*dy)
		If speed > speed_le
			dx = dx/speed*speed_le
			dy = dy/speed*speed_le
		EndIf
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 24*24
			killer = True
			If KillPlayer()
				If le2 <> Null
					le2.attached = False
					le2.resist = False
					le2.le2 = Null
				EndIf
				le2 = Null
				attached = False
				resist = False
				le_LIST.Remove(Self)
			Else
				killer = False
			EndIf
		EndIf
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 25+n5.sz*5
					dx = dx + ddx/dist/1024*(500-dist)
					dy = dy + ddy/dist/1024*(500-dist)
					If dist < n5.sz/2
						Kill(False,0,0)
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Blackhole2()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			' it gets pulled in, partner spins around
			If le2 <> Null Then le2.resist = True Else Exit
			Toward(n5.x,n5.y,100+n5.sz*10)
			Local distx# = x-n5.x
			Local disty# = y-n5.y
			Local dist# = (distx * distx + disty * disty)
			If dist < (12)*(12) + n5.sz*n5.sz*4
				If le2.Spin(Cos(n5.r*2)*16,Sin(n5.r*2)*16)
					' free it
					le2.attached = False
					le2.resist = False
					le2.le2 = Null
					le2.strength = 0
					le2 = Null
					attached = False
					resist = False
					strength = 0
					le_LIST.Remove(Self)
					n5.Grow(1)
					Exit
				'Else
				'	strength = le2.strength
				EndIf
			EndIf
		Next
	End Method

	Method TowardPartner(xx#,yy#)
		Local speed#
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist > 150
			dx = dx + ddx/dist*32
			dy = dy + ddy/dist*32
		ElseIf dist < 64
			dx = dx -ddx/dist*32
			dy = dy -ddy/dist*32
		EndIf
	End Method

	Method Toward(xx#,yy#,range:Int)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range
			dx = dx + ddx/dist
			dy = dy + ddy/dist
		EndIf
	End Method

	Method Spin:Int(vx#,vy#)
		Local t:Int
		dx = dx - vx/2
		dy = dy - vy/2
		strength:-0.25
		If strength <= 0
			Return True
		Else
			Return False
		EndIf
	End Method

	Method Kill(points:Int=True,vx#,vy#)
		Local t:Int
		For t = 0 To 3
			part.Create(x,y, 8 ,20+strength*4,220-strength*4,0,r)
		Next
		If points = False Then attached = False
		If attached
			dx = dx - vx/16
			dy = dy - vy/16
			strength:-2.5
			If strength <= 0
				strength = 0
				If le2 <> Null
					le2.attached = False
					le2.le2 = Null
					le2.strength = 0
				EndIf
				le2 = Null
				attached = False
			EndIf
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(le_hit_snd, 1, pan, vol)
		Else
			If points = True score.IncScore(x,y,150)
			gridpoint.ShockWave(x,y)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(le_killed_snd, 1, pan, vol)
			For t = 0 To 31
				part.Create(x,y, 8 ,COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B)
			Next
			le_LIST.Remove(Self)
		EndIf
	End Method

	Method Draw()
		Local sc#
		Local tri#[]=[0.0,-10.0, 8.0,6.0, -8.0,6.0]
		SetColor COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B
		SetBlend alphablend
		SetOrigin x-gxoff,y-gyoff
		SetRotation(r*2)
		sc = (r/16) Mod 8  + 0.5
		If move > 0
			SetAlpha Float(move)/40.0
			SetScale Float(move)/5.0,Float(move)/5.0
		Else
			SetAlpha 0.5-sc/8
			SetScale sc,sc
		EndIf
		DrawPoly tri
		SetColor 255,255,255
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		SetRotation(r*2)
		DrawImage orangetriangle,x-gxoff,y-gyoff
		If attached
			SetRotation(r*4+180)
			DrawImage orangetriangle,x-gxoff,y-gyoff
		EndIf
		SetRotation 0
		Return
	End Method

	Method DrawBond()
		If attached And Not killer
			SetColor 20+strength*8,220-strength*8,0
			DrawLine (x-gxoff,y-gyoff,le2.x-gxoff,le2.y-gyoff,0)
		EndIf
	End Method

End Type





'powerups
Type pu
	Field x#,y#,dx#,dy#,r#,kind:Int
	Field move:Int, life:Int, die:Int

	Function Create( x#, y#, kind:Int, freeze:Int )
		Local n:pu = New pu
		n.x = x
		n.y = y
		n.kind = kind
		n.life = 0
		n.r = Rand(0,359)
		Local dir:Int = Rand(0,359)
		Local mag# = Rnd(.5,2.0)
		n.dx = Cos(dir)*mag
		n.dy = Sin(dir)*mag
		n.move = freeze
		pu_list.AddLast( n )
	EndFunction

	Method Update()
		Local otherpu:pu
		Local distx#
		Local disty#
		Local dist#
		Local t:Int

		distx# = x-px
		disty# = y-py
		dist# = (distx * distx + disty * disty)
		If dist < 20*20 + 16*16
			UpPower()
			die = True
		EndIf

		If move > 0
			move:-1
			Return
		EndIf
		life:+1
		r = r + 1
		x = x + dx
		y = y + dy
		If x < 8
			dx = Abs(dx)
			x = x + dx
		ElseIf x > PLAYFIELDW-8
			dx = -Abs(dx)
			x = x + dx
		EndIf
		If y < 8
			dy = Abs(dy)
			y = y + dy
		ElseIf y > PLAYFIELDH-8
			dy = -Abs(dy)
			y = y + dy
		EndIf
		If Not die Then blackhole()
		If Rand(0,100) > 96 Then Toward(px,py,PLAYFIELDW)
		If life > 10*20
			If kind > 1
				For otherpu:pu  = EachIn pu_list
					If otherpu<> Self And otherpu.kind > 1
						distx# = otherpu.x-x
						disty# = otherpu.y-y
						dist# = (distx * distx + disty * disty)
						If life > 15*20
							'towards
							dx = dx + Sgn(distx)/64
							dy = dy + Sgn(disty)/64
							otherpu.dx:- Sgn(distx)/64
							otherpu.dy:- Sgn(disty)/64
						EndIf
						If dist < 16*16 + 16*16
							'merge
							'otherpu.move = 200
							pu_list.Remove(otherpu)
							die = True
							ge.Create( x, y, 10, 20, 20, 20)
							For t = 0 To 7
								part.Create(x,y, 0 ,COL_POWERUP_R,COL_POWERUP_G,COL_POWERUP_B)
							Next
						EndIf
					EndIf
				Next
			Else
				' back and side shooters disappear
				If life > 20*20
					die = True
					nme8.Create( x, y, 30)
					For t = 0 To 7
						part.Create(x,y, 0 ,COL_POWERUP_R,COL_POWERUP_G,COL_POWERUP_B)
					Next
				EndIf
			EndIf
		EndIf
		Local speed# = Sqr(dx*dx+dy*dy)+0.001
		If speed > 4
			dx = dx/speed*4
			dy = dy/speed*4
		EndIf

		If die Then pu_LIST.Remove(Self)
	End Method

	Method Blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Local ddx# = n5.x-x
				Local ddy# = n5.y-y
				Local dist# = Sqr(ddx*ddx + ddy*ddy) + 0.001
				If dist < 75+n5.sz*5
					dx = dx + ddx/dist/4096*(400-dist)
					dy = dy + ddy/dist/4096*(400-dist)
					If dist < 12+n5.sz
						Kill()
						n5.Grow(1)
						Exit
					EndIf
				EndIf
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range#)
		Local ddx# = xx-x
		Local ddy# = yy-y
		Local dist# = Sqr(ddx*ddx + ddy*ddy)+0.001
		If dist < range
			dx = dx + ddx/dist
			dy = dy + ddy/dist
		EndIf
	End Method
'
	Method Kill()
		For Local t:Int = 0 To 14
			part.Create(x,y, 2 ,COL_POWERUP_R,COL_POWERUP_G,COL_POWERUP_B,t*24+r)
		Next
		pu_LIST.Remove(Self)
	End Method

	Method Draw()
		SetAlpha 1
		SetScale 1,1
		SetRotation 0
		SetBlend LIGHTBLEND
		SetColor 255,255,255
		If life > 18*20
			SetColor 180,80,200
		EndIf
		Select kind
			Case 0 'back shooter
				DrawImage powerimage,x-gxoff,y-gyoff,2
			Case 1 'side shooters
				DrawImage powerimage,x-gxoff,y-gyoff,3
			Case 2 'Xtra Bullet B
				DrawImage powerimage,x-gxoff,y-gyoff,0
			Case 3 'shot speed  ->
				DrawImage powerimage,x-gxoff,y-gyoff,5
			Case 4 'Free ship    X
				DrawImage powerimage,x-gxoff,y-gyoff,6
			Case 5 'Free bomb
				DrawImage powerimage,x-gxoff,y-gyoff,8
			Case 6 'shield
				DrawImage powerimage,x-gxoff,y-gyoff,9
			Case 7 'supershots
				DrawImage powerimage,x-gxoff,y-gyoff,7
			Case 8 'bouncyshots
				DrawImage powerimage,x-gxoff,y-gyoff,10
		End Select
		SetBlend LIGHTBLEND
		SetColor rcol,gcol,bcol
		If life > 15*20
			SetColor 180,80,200
		EndIf
		SetOrigin 0,0
		SetRotation(life*6)
		DrawImage whitestar,x-gxoff,y-gyoff
		SetRotation 0
		SetScale 1,1
		SetOrigin 0,0

	End Method

	Method UpPower()
		Select kind
			Case 0 'back shooter
				shot_back:+ 20*upgradetime
				mess$ = "Reverse Shooter"
				mlen = 15
			Case 1 'side shooters
				shot_side:+ 20*upgradetime
				mess$ = "Side Shooters"
				mlen = 13
			Case 2 'Bullet B
				numshots:+1
				If numshots > 4
					numshots = 4
					mess$ = "2000 Points!"
					mlen = 12
					score.IncScore(x,y,2000,0)
				Else
					mess$ = "Extra Cannon"
					mlen = 12
				EndIf
			Case 3 'Shot Speed   S
				shotspeed:+1
				If shotspeed > 5
					shotspeed = 5
					mess$ = "2000 Points!"
					score.IncScore(x,y,2000,0)
					mlen = 12
				Else
					mess$ = "Faster Shots"
					mlen = 12
				EndIf
			Case 4 'Free ship    X
				If numplayers > 9
					mess$ = "2000 Points!"
					score.IncScore(x,y,2000,0)
					mlen = 12
				Else
					numplayers:+1
					mess$ = "Extra Player"
					mlen = 12
				EndIf
			Case 5 'bomb
				If numbombs > 8
					mess$ = "2000 Points!"
					score.IncScore(x,y,2000,0)
					mlen = 12
				Else
					numbombs:+1
					mess$ = "Extra Bomb"
					mlen = 10
				EndIf
			Case 6 'shield
				player_shield:+ 20*upgradetime
				If player_shield > 20*upgradetime*2 Then player_shield = 20*upgradetime*2
				mess$ = "Shield"
				mlen = 6
			Case 7 'super shots
				supershots:+ 20*upgradetime
				mess$ = "Super Shots"
				mlen = 15
			Case 8 'Bouncy shots
				bouncyshots:+ 20*upgradetime
				mess$ = "Bouncy Shots"
				mlen = 15
		End Select
		score.create(mess$,x-mlen*6,y-8,True)
'		messtime = 180
		Local pan# = (x-px)/PLAYFIELDW
		Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
		PlaySound2(pu_collect_snd, 1, pan, vol)
	End Method

	Function MakePowerUp(tp:Int=-1)
		Local x:Int,y:Int,k:Int

		x = Rand(250,PLAYFIELDW-250)
		y = Rand(150,PLAYFIELDH-150)

		' figure out what's needed based on
		' numplayers, numbombs
		' numshots   (1-4)
		' shotspeed  (3-5)

		' can always be 0,1
		' if bullets needed then 2
		' if speed needed then 3
		' if low on men then 4
		' if low on bombs then 5
		k = Rand(0,1)
		If Rand(0,100) > 80
			k = 6'shield
			If Rand(0,100) > 45 Then k = 7 + Rand(0,1) 'supershots or bouncy shots
		EndIf
		If shotspeed < 5
			' need more shot speed!
			If Rand(1,shotspeed) < 2  '2/3 to 2/5
				k = 3
			EndIf
		EndIf
		If numshots < 4
			' need more bullets!
			If Rand(1,numshots) = 1 '1-1 to 1-6
				k = 2
			EndIf
		EndIf
		If k < 2 And Rand(0,100) > 40 ' ie not bullet or speed
			If numplayers < 2
				k = 4
			ElseIf numbombs < 2
				k = 5
			EndIf
		EndIf
		If tp <> -1 Then k = tp
		pu.Create(x,y,k,2)
		gridpoint.Push(x,y,6,1)

	End Function

End Type






' player bullets
Type shot

	Field x#,y#,dx#,dy#,sp#

	Function Create( x#, y# ,xd#, yd#, sp#)
		If CountList(SHOT_list) < 500
			Local s:SHOT= New SHOT
			s.x = x
			s.y = y
			s.sp = sp
			s.dx = xd
			s.dy = yd
			's.x1 = s.x2 + s.dx
			's.y1 = s.y2 + s.dy
			SHOT_list.AddLast( s )
		EndIf
	EndFunction

	Method Update()
		Local kill:Int = False
		Local pass:Int

		For pass = 0 To 1
		x = x + dx/2
		y = y + dy/2
		If x < 0 Or x > PLAYFIELDW-1
			x = x - dx*2/2
			If bouncyshots = 0
				kill = True
			Else
				dx = -dx
			EndIf
		EndIf
		If y < 0 Or y > PLAYFIELDH-1
			y = y - dy*2/2
			If bouncyshots = 0
				kill = True
			Else
				dy = -dy
			EndIf
		EndIf
		If Not kill
			If supershots > 0
				CheckCollisions()
			Else
				kill = CheckCollisions()
			EndIf
		EndIf
		If Not kill Then blackhole()
		Local speed# = Sqr(dx*dx+dy*dy)
		If speed < sp/2 And speed > 0
			dx = dx/speed*sp/2
			dx = dx/speed*sp/2
		EndIf
		If kill
			If supershots > 0
				For Local t:Int = 0 To 3
					part.Create(x,y,0 ,COL_SHOT1_R,COL_SHOT1_G,COL_SHOT1_B)
				Next
			Else
				If bouncyshots
					For Local t:Int = 0 To 3
						part.Create(x,y,0 ,COL_SHOT2_R,COL_SHOT2_G,COL_SHOT2_B)
					Next
				Else
					For Local t:Int = 0 To 3
						part.Create(x,y,0 ,COL_SHOT_R,COL_SHOT_G,COL_SHOT_B)
					Next
				EndIf
			EndIf
			SHOT_LIST.Remove(Self)
			Local pan# = (x-px)/PLAYFIELDW
			Local vol# = (1 - Abs(pan)/10) * (1 - (Abs(y-py)/PLAYFIELDH)/10)
			PlaySound2(shot_hit_wall_snd, 1, pan, vol)
			Exit ' no need for 2nd pass
		Else
			gridpoint.Push(x+dx*2,y+dy*2,3,.025)
		EndIf
		Next
	End Method

	Method blackhole()
		Local n5:nme5
		For n5:nme5 = EachIn nme5_list
			If n5.active
				Toward(n5.x,n5.y,75+n5.sz*5,n5.sz/4)
			EndIf
		Next
	End Method

	Method Toward(xx#,yy#,range:Int,di:Int)
		'diam = 1 to 16
		Local ddx# = xx-x
		Local ddy# = yy-y
		If ddx*ddx + ddy*ddy < range * range And ddx*ddx + ddy*ddy > 32*32
			ddx# = -Sgn(ddx)/(26-di)
			ddy# = -Sgn(ddy)/(26-di)
			dx = dx + ddx
			dy = dy + ddy
		EndIf
	End Method


	Method Checkcollisions:Int()
		Local n:nme
		Local n1:nme1
		Local n2:nme2
		Local n3:nme3
		Local n4:nme4
		Local n5:nme5
		Local n6:nme6
		Local n7:nme7
		Local n8:nme8
		Local g:ge
		Local ll:le
		Local distx#
		Local disty#
		Local dist#
		For n5:nme5 = EachIn nme5_list
			distx# = x-n5.x
			disty# = y-n5.y
			dist# = (distx * distx + disty * disty)
			If dist < (12+n5.sz/2)*(12+n5.sz/2)
				n5.Kill()
				Return True
			EndIf
		Next
		For n:nme = EachIn nme_list
			distx# = x-n.x
			disty# = y-n.y
			dist# = (distx * distx + disty * disty)
			If dist < 16*16+2*2
				n.Kill()
				Return True
			Else
				n.RunAway(x,y,x+dx,y+dy)
			EndIf
		Next
		For n1:nme1 = EachIn nme1_list
			distx# = x-n1.x
			disty# = y-n1.y
			dist# = (distx * distx + disty * disty)
			If dist < 16*16+2*2
				n1.Kill()
				Return True
			EndIf
		Next
		For n2:nme2 = EachIn nme2_list
			distx# = x-n2.x
			disty# = y-n2.y
			dist# = (distx * distx + disty * disty)
			If dist < 18*18+3*3
				n2.Kill()
				Return True
			EndIf
		Next
		For n3:nme3 = EachIn nme3_list
			distx# = x-n3.x
			disty# = y-n3.y
			dist# = (distx * distx + disty * disty)
			If dist < 16*16+3*3 - n3.sz*3
				n3.Kill()
				Return True
			EndIf
		Next
		For n4:nme4 = EachIn nme4_list
			distx# = x-n4.x
			disty# = y-n4.y
			dist# = (distx * distx + disty * disty)
			If dist < 12*12+2*2
				n4.Kill()
				Return True
			EndIf
		Next
		For ll:le = EachIn le_list
			distx# = x-ll.x
			disty# = y-ll.y
			dist# = (distx * distx + disty * disty)
			If dist < 12*12+2*2
				ll.Kill(True,-dx*5,-dy*5) 'x1-x2,y1-y2)
				Return True
			EndIf
		Next
		For g:ge = EachIn ge_list
			distx# = x-g.x
			disty# = y-g.y
			dist# = (distx * distx + disty * disty)
			If dist < 12*12 + g.sz
				g.Kill()
				Return True
			EndIf
		Next
		For n6:nme6 = EachIn nme6_list
			distx# = x-n6.x
			disty# = y-n6.y
			dist# = (distx * distx + disty * disty)
			If dist < 9*9 + n6.sz
				n6.Kill()
				Return True
			EndIf
		Next
		For n7:nme7 = EachIn nme7_list
			distx# = x-n7.x
			disty# = y-n7.y
			dist# = (distx * distx + disty * disty)
			If dist < 64*64
				If Abs(n7.rotdir) > 4
					'no shield up
					If dist < 12*12
						n7.Kill()
						Return True
					EndIf
				Else
					' is it in the shield ?
					If PointInTri(x,y, n7.x-dx, n7.y-dy, n7.xrgt,n7.yrgt,n7.xlft,n7.ylft)
						' just kill bullet
						Return True
					Else
						' not in the shield - must be sides or back
						If dist < 12*12
							n7.Kill()
							Return True
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		For n8:nme8 = EachIn nme8_list
			distx# = x-n8.x
			disty# = y-n8.y
			dist# = (distx * distx + disty * disty)
			If dist < 10*10+2*2
				n8.Kill()
				Return True
			EndIf
		Next

		Return False

	End Method

	Function DrawAllShots()
		Local s:shot
		If supershots
			SetColor COL_SHOT1_R,COL_SHOT1_G,COL_SHOT1_B
		Else
			If bouncyshots
				SetColor COL_SHOT2_R,COL_SHOT2_G,COL_SHOT2_B
			Else
				SetColor COL_SHOT_R,COL_SHOT_G,COL_SHOT_B
			EndIf
		EndIf
		SetOrigin 0,0
		SetAlpha 1
		SetScale 1,1
		SetBlend lightblend
		For s:shot = EachIn SHOT_list
			Local roti:Int = ATan2( s.dy,s.dx)+90
			SetRotation(roti)
			DrawImage yellowshot,s.x-gxoff,s.y-gyoff
		Next
		SetRotation 0
	End Function

	Function Superbomb()
		Local t:Float
		Local z:Int = 1
		If numbombs > 0
			PlaySound2(super_bomb_snd)
			bombtime = 60
			numbombs:-1
			For t = 0 To (z*360)-1
				part.Create(px,py,1,COL_BOMB_R,COL_BOMB_G,COL_BOMB_B, t/z)
				part.Create(px,py,9,COL_BOMB_R,COL_BOMB_G,COL_BOMB_B)
			Next
			DestroyAll()
			score.ResetMultiplier()
			gridpoint.Pull(px,py,60,60)
			player_shield = 65
		EndIf
	End Function


End Type


Type score
	Field x:Int,y:Int,s$,life:Int

	Function Create(s$,x:Int,y:Int, l:Int=0)
		Local sc:score = New score
		sc.x = x
		sc.y = y
		sc.s$ = s$
		sc.life = 30+l*20
		score_list.AddLast( sc )
	End Function

	Function UpdatePoints()
		Local sc:score
		For sc:score = EachIn score_list
			sc.life:-1
			If sc.life <= 0 Then score_LIST.Remove(sc)
		Next
	End Function

	Function DrawPoints()
		Local sc:score

		SetBlend lightblend
		SetScale 1,1
		SetAlpha 1
		SetLineWidth 2.0
		For sc:score = EachIn score_list
			Local cc%
			cc = 75 + sc.life * 10
			If cc > 255 Then cc = 255
			SetColor cc,cc,32
			Drawstring (sc.s$,sc.x-gxoff-sc.life,sc.y-gyoff-16,1+Float(sc.life)/12.0)
		Next
		SetAlpha 1
	End Function

	Function ResetMultiplier()
		multiplier = 1
		killcount = 0
		' set back powerupscore to just above current
		powerupscore = pscore + POWERUP*2
		powerupscore = Int(powerupscore/POWERUP/2)*POWERUP*2
		messtime = 180
		mess$ = "Power Up at "+ powerupscore
		mlen = Len(mess$)
	End Function

	Function ResetScore()
		lowesthiscore = scores[9,startingdifficulty]
		hiscore = scores[0,startingdifficulty]
		pscore = 0
	End Function

	Function IncScore(x:Int,y:Int,amt:Int,m:Int=True)

		Local s$
		pscore = pscore + amt*multiplier
		s$ = amt*multiplier
		If m Then score.create(s$,x,y)

		If m Then killcount:+1
		If multiplier < 10
			If killcount >= multiplieramount[multiplier-1] '0-9
				multiplier:+1
				PlaySound2(multiplier_increase_snd)
				s$ = multiplier+"X Multiplier"
				score.create(s$,px-13*6,py-32,True)
			EndIf
		EndIf
		If pscore >= extralifecount*EXTRALIFE
'			numplayers:+1
			extralifecount:+1
			PlaySound2(extra_life_snd)
'			s$ = "Extra Life"
'			score.create(s$,px-10*6,py-32,True)
			If numplayers < 10 Then pu.MakePowerup(4)
		EndIf
		If pscore >= extrabombcount*EXTRABOMB
'			numbombs:+1
			extrabombcount :+1
			PlaySound2(extra_bomb_snd)
'			s$ = "Extra Bomb"
'			score.create(s$,px-10*6,py-32,True)
			If numbombs < 9 Then pu.MakePowerup(5)
		EndIf
		If pscore >= powerupscore
			pu.MakePowerUp()
			powerupscore:+POWERUP*multiplier*multiplier
			PlaySound2(bonus_born_snd)
		EndIf
		If pscore > hiscore
			hiscore = pscore
		EndIf

	End Function

	Function DrawScore()
		' draw scores
		SetColor COL_SCORE_R,COL_SCORE_G,COL_SCORE_B
		DrawString("SCORE: "+pscore, 10,10,3)
		DrawString("HISCORE: " + hiscore, SCREENW-260,10,3)
		DrawString(multiplier+"X", 240,10,2.5)
		If debug Then DrawString(gcount, 300,10,3)
	End Function


	Function GetHighScore:Int()
	If Not valid Then Return -20

		Local slot:Int = 0, t:Int
		Local name$
		Local done:Int = False
		Local ignoreyjoy:Int
		Local ignorefyjoy:Int
		Local ignorexjoy:Int
		Local tim:Int

		gxoff = 0
		gyoff = 0

		bombtime = 20
		PlaySound2(high_score_snd)
		Local playtime$ = GetPlayTime(gcount)
		FlushKeys()
		FlushMouse()
		While done = False
			Cls
			tim = MilliSecs()

			jdfy = GetJoyByAxis(joyport, axis_fire_y, axis_fire_y_inv, axis_fire_y_sc, axis_fire_y_center )
			jdmy = GetJoyByAxis(joyport, axis_move_y, axis_move_y_inv, axis_move_y_sc, axis_move_y_center )
			jdmx = GetJoyByAxis(joyport, axis_move_x, axis_move_x_inv, axis_move_x_sc, axis_move_x_center )
			If Abs(jdfy) < 0.3 Then jdfy = 0
			If Abs(jdmy) < 0.3 Then jdmy = 0
			If Abs(jdmx) < 0.3 Then jdmx = 0
			If jdfy = 0 Then ignorefyjoy = False
			If jdmy = 0 Then ignoreyjoy = False
			If jdmx = 0 Then ignorexjoy = False
			If ignoreyjoy = True And bombtime > 0 Then jdmy = 0
			If ignorefyjoy = True And bombtime > 0 Then jdfy = 0
			If ignorexjoy = True And bombtime > 0 Then jdmx = 0
			If KeyDown(KEY_UP) And bombtime = 0 Then jdmy =-1
			If KeyDown(KEY_DOWN) And bombtime = 0 Then jdmy = 1
			If KeyHit(KEY_LEFT) Then jdmx =-1
			If KeyHit(KEY_RIGHT) Then jdmx = 1
			If jdmy <> 0 Then ignoreyjoy = True
			If jdfy <> 0 Then ignorefyjoy = True
			If jdmx <> 0 Then ignorexjoy = True

			If KeyDown(KEY_RSHIFT) Or KeyDown(KEY_LSHIFT)
				For Local kk:Int = 48 To 90
					If KeyHit(kk)
						'FlushKeys()
						letter[slot]=kk
						jdmx = 1
						Exit
					EndIf
				Next
			Else
				For Local kk:Int = 48 To 90
					If KeyHit(kk)
						'FlushKeys()
						If kk >= 65 And kk <= 65+26
							letter[slot]=kk+32
							jdmx = 1
						Else
							letter[slot]=kk
							jdmx = 1
						EndIf
						Exit
					EndIf
				Next
			EndIf
			If KeyHit(KEY_SPACE)
				letter[slot] = 32
				jdmx = 1
			EndIf

			If jdfy <> 0
			   PlaySound2(quarkhitsound)
			   If letter[slot] > 64 And letter[slot] < 91 Then
			         letter[slot] = letter[slot] + 32
			   Else If letter[slot] > 96 And letter[slot] < 123 Then
			         letter[slot] = letter[slot] - 32
			   End If
			   bombtime = 15
			EndIf

			If jdmy < 0
			   letter[slot] = letter[slot] - 1
			   PlaySound2(quarkhitsound)
			   If letter[slot] = 32 Then
			         letter[slot] = 126
			   Else If letter[slot] = 64 Then
			         letter[slot] = 32
			   Else If letter[slot] < 32 Then
			         letter[slot] = 64

			   Else If letter[slot] = 96 Then
			         letter[slot] = 32
			   Else If letter[slot] = 122 Then
			         letter[slot] = 96
			   End If
			   bombtime = 8
			EndIf
			If jdmy > 0
			   letter[slot] = letter[slot] + 1
			   PlaySound2(quarkhitsound)
			   If letter[slot] > 126 Then
			         letter[slot] = 33
			   Else If letter[slot] = 65 Then
			         letter[slot] = 32
			   Else If letter[slot] = 33 Then
			         letter[slot] = 65

			   Else If letter[slot] = 123 Then
			         letter[slot] = 91
			   Else If letter[slot] = 97 Then
			         letter[slot] = 123
			   End If

			   bombtime = 8
			EndIf
			If jdmx < 0
				slot = slot - 1
				PlaySound2(quarkhitsound)
				If slot < 0 Then slot = 7
				bombtime = 15
			EndIf
			If jdmx > 0
				slot = slot + 1
				PlaySound2(quarkhitsound)
				If slot > 7 Then slot = 0
				bombtime = 15
			EndIf

			SetColor 255,255,255
			DrawString("Congratulations!", SCREENW/2-250,SCREENH/2-240,3)
			DrawString("You are in the top 10.",SCREENW/2-250,SCREENH/2-200,3)
			DrawString("Difficulty Level: "+difficulty$[laststartingdifficulty],SCREENW/2-250,SCREENH/2-160,3)
			SetColor 0,255,0
			DrawString("Score: " + pscore, SCREENW/2-200,SCREENH/2-80,3)
			DrawString("Time:  " + playtime$, SCREENW/2-200,SCREENH/2-40,3)
			DrawString("Name:  " + name$, SCREENW/2-200,SCREENH/2,3)
			For t = 0 To 7
				If slot = t
					SetColor 255,255,0
				Else
					SetColor 0,255,0
				EndIf
				DrawLine SCREENW/2-200+7*15+t*15,SCREENH/2+22,SCREENW/2-200+7*15+t*15+12,SCREENH/2+22
			Next
			SetColor 255,255,255
			DrawString("Up and Down to select letter,",SCREENW/2-250,SCREENH/2+80,3)
			DrawString("Left and Right to select position.",SCREENW/2-250,SCREENH/2+120,3)
			DrawString("Press Enter when done.",SCREENW/2-250,SCREENH/2+160,3)
			name$ = ""
			For t = 0 To 7
				name$:+ Chr$(letter[t])
			Next
			If Rand(0,100) > 90 Then part.CreateFireworks(2)
			part.UpdateParticles()
			part.DrawParticles()
			Flip 1
			tim = MilliSecs() - tim
			If tim < 20 And tim > 0
				Delay 20-tim
			EndIf

			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0

			If KeyHit(KEY_ENTER) Or MouseHit(m_bomb) Or ..
				(JoyDown(j_pad_bomb,joyport) And controltype = 3 And bombtime = 0) Or ..
				(JoyDown(j_d_bomb,joyport) And controltype = 0 And bombtime = 0)
				bombtime = 20
				done = True
			EndIf

		Wend
		Return insertscore(pscore, name$, playtime$,score.GetSettings(), laststartingdifficulty)
	End Function

	Function GetSettings$()
		Local ret$ = ""
		'game version
		ret$:+ g_v_num$ +","
		'screen size
		ret$:+ gfxmodearr[screensize].s$+","
		'play size
		ret$:+ playfieldsizes[playsize*2]+"X"+playfieldsizes[playsize*2+1]+","
		'control type
		If controltype > 2
			ret$:+ control_method[controltype]
			If controltype = 3
				ret$:+ "-"+j_config+","
			EndIf
			If controltype = 4
				ret$:+ "-"+h_config+","
			EndIf
		Else
			ret$:+ control_method[controltype]+","
		EndIf
		'scroll
		ret$:+ scroll +","
		'gfx set
		ret$:+ gfxset +","
		'grid style
		ret$:+ g_style +","
		'autofire
		ret$:+ autofire +","
		'inertia
		ret$:+ Int(inertia*100)

		Return ret$
	End Function

	Function CalcChecksum:Int(sc:Int, tm$, n$, set$)
		Local pad:Int = 0
		Local st$ = sc+n$+tm$+set$

		For Local tt:Int = 0 To Len(st$)-1
			pad = pad + st$[tt]
		Next

		Return pad
	End Function

	Function InsertScore:Int(sc:Int,name$,tm$, set$, tb:Int)
		' find position
		' shift others down
		' and insert new score
		Local minpos:Int=10
		Local t:Int
		For t = 9 To 0 Step -1
			If sc > scores[t,tb] Then minpos=t
		Next
		For t = 9 To (minpos+1) Step -1
			scores[t,tb]=scores[t-1,tb]
			names[t,tb]=names[t-1,tb]
			playtimes[t,tb]=playtimes[t-1,tb]
			scoresetting$[t,tb] = scoresetting$[t-1,tb]
			checksum[t,tb] = checksum[t-1,tb]
		Next
		scores[minpos,tb]= sc
		playtimes$[minpos,tb]= tm$
		names$[minpos,tb]= name$
		scoresetting$[minpos,tb] = set$
		checksum[minpos,tb] = score.CalcChecksum(sc, tm$, name$, set$)
		lowesthiscore = scores[9,tb]
		Return minpos

	End Function



	Function LoadScores()
		Local tb:Int
		Local t:Int
		Local hdir$, fn$

		hdir$=GetUserHomeDir()
		fn$ = hdir+"/.config/gridwars/hiscores.dat"

		Local fh:TStream = OpenFile(fn)
		If fh = Null
			' if score file not found use the default
			score.SetDefault()
		Else
			For tb = 0 To 2
				For t = 0 To 9
					scores[t,tb] = Int(ReadLine(fh))
					playtimes[t,tb] = ReadLine(fh)
					names$[t,tb] = ReadLine(fh)
					scoresetting$[t,tb] = ReadLine(fh)
					checksum[t,tb] = Int(ReadLine(fh))
				Next
			Next
			CloseFile fh
		EndIf
		score.ValidateScores()
	End Function

	Function ValidateScores()
		Local tb:Int
		Local t:Int
		Local pad:Int
		Local dirtyscores:Int = False

		For tb = 0 To 2
			For t = 0 To 9
				pad = score.CalcChecksum(scores[t,tb],playtimes[t,tb],names$[t,tb],scoresetting$[t,tb])
				If pad <> checksum[t,tb]
					dirtyscores = True
				EndIf
			Next
		Next
		If dirtyscores Then score.SetDefault()

	End Function

	Function SetDefault()

		Local tb:Int
		Local t:Int
		For tb = 0 To 2
			For t = 0 To 9
				If tb = 0 Then scores[t,tb]= (200000-t*19000)
				If tb = 1 Then scores[t,tb]= (100000-t*9000)
				If tb = 2 Then scores[t,tb]= (50000-t*4900)
				playtimes[t,tb] = GetPlayTime(50*60*11-t*50*40-tb*50*60*2)
				names$[t,tb]= "Mark Inc"
				scoresetting$[t,tb] = "0,0,0,0,0,0,0,0,0,0"
				checksum[t,tb] = score.CalcChecksum(scores[t,tb],playtimes[t,tb],names$[t,tb],scoresetting$[t,tb])
			Next
		Next
	End Function

	Function SaveScores()
		' write the scores out to file
		Local tb:Int
		Local t:Int
		Local hdir$, fn$

		hdir$=GetUserHomeDir()
		fn$ = hdir+"/.config/gridwars/hiscores.dat"

		Local fh:TStream = WriteFile(fn)
		If fh <> Null
			For tb = 0 To 2
				For t = 0 To 9
					WriteLine(fh,scores[t,tb])
					WriteLine(fh,playtimes[t,tb])
					WriteLine(fh,names$[t,tb])
					WriteLine(fh,scoresetting$[t,tb])
					WriteLine(fh,checksum[t,tb])
				Next
			Next
			CloseFile fh
		EndIf
	End Function

End Type










Function Main()

	Local tim:Int
	Local tim2:Int
	Local tim3:Int
	Local tim4:Int

	Local looper:Int
	Local done:Int,f:Int

	part.CreateAll()

	FlushKeys()
	done = False
	Repeat
		While playgame = False And done = False
			StartMusic(0)
			If playgame = False And done = False Then done = ShowTitle()
			If playgame = False And done = False Then done = ShowScores()
			If playgame = False And done = False Then done = ShowFriends()
			If playgame = False And done = False Then done = ShowEnemies()
		Wend

		If playgame And done = False
			If Not cheat Then valid = True;nokillme = False
			StopMusic()
			RemoveAll(True)
			ResetGame()
			dying = True
			done = GetReady()
			dying = False
			Cls
			Repeat
				tim = MilliSecs()
				Spawn(gcount)
				UpdatePlayer()
				UpdateAll()
				tim2:Int = MilliSecs()-tim
				DrawAll()
				tim3:Int = MilliSecs()-tim
				If gameover
					StopMusic()
					done = DoGameOver()
					playgame = False
				EndIf

				If cheat
					DrawString("Update ms: "+tim2, 10,30,3)
					DrawString("Draw ms: " + (tim3 - tim2) , 10 , 50 , 3)
					DrawString("Last Frame ms: " + (tim4) , 10 , 70 , 3)
					Flip 1
					If KeyDown(KEY_P)
						Local pause:Int = True
						While pause
							Delay 100
							If KeyHit(KEY_O) Then pause = False
						Wend
					EndIf
				Else
					Flip 1
				EndIf
				gcount:+1
				If KeyHit(KEY_ESCAPE) Or ..
					(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
					(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)
					Local ret:Int = Options(True)
					If ret > 0
						done = True
						gameover = True
						If ret = 2
							StopMusic()
							playgame = False
							done = False
						EndIf
					EndIf
					bombtime = 20
				EndIf
				tim4:Int = MilliSecs() - tim
				If tim4 < 20 And tim4 > 0
					Delay 20-tim4
				EndIf
				Cls
			Until gameover = True Or playgame = False
			RemoveAll(True)'in case some sounds still playing and we quit
			If done = False
				gxoff = 0
				gyoff = 0
				If pscore > lowesthiscore
					StartMusic(2)
					f = score.GetHighScore()
					done = ShowScores(f)
					pscore = 0
					StopMusic()
				Else
					If pscore > 0 Then StartMusic(0);done = ShowScores(-20)
				EndIf
			EndIf
		EndIf

	Until done

End Function



Function DoGameOver:Int()

	Local looper:Int = 2
	Local tim:Int

	FlushKeys()
	While looper < 360
		dying = True
		UpdateAll()
		Cls
		tim = MilliSecs()
		drawall()
'		If KeyDown(KEY_TAB) Then End
'		If Not KeyDown(KEY_F8)
			SetColor 0,55+Abs(Sin(looper/2))*200,0
			DrawString("GAME OVER",..
			  SCREENW/2-Abs(Sin(looper/2))*19*5*9*.5,..
			  SCREENH/2-Abs(Sin(looper/2))*100,..
			  Abs(Sin(looper/2))*20)
'		EndIf
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		If KeyHit(KEY_ESCAPE) Or ..
			(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)
			If Options(True) Then Return True
		EndIf
		If KeyHit(k_bomb) Or MouseHit(m_bomb)
			looper = 360
		EndIf
		looper :+2
	Wend
	Return False

End Function




Function ShowFriends:Int(f:Int=-1)
	Local counter:Int = 0, i:Int
	Local tim:Int

	FlushKeys()
	bombtime = 20
	Local colr:Int[8]
	Local colg:Int[8]
	Local colb:Int[8]
	Local lsp:Int = 50
	Local lwsp:Int = 0

	While (counter < 900)
		Cls
		gcount:+1
		tim = MilliSecs()
		If Rand(0,100) > 94 And counter < 850 Then part.CreateFireworks(1)
		part.UpdateParticles(1)
		part.DrawParticles()
		BlackholeParticles()
		'red circles
		For Local n5:nme5 = EachIn nme5_list
			n5.UpdateDisplayEffect()
		Next

		SetColor 255,255,0
		If (SCREENH<600) Then lsp = 32;lwsp = 32 Else lsp = 50;lwsp = 0
		DrawString("Know Your Friends",SCREENW/2-4.5*5*18/2-32,10,4.5)

		CycleColours()
		CycleColours()
		colr[7] = rcol
		colg[7] = gcol
		colb[7] = bcol
		If counter Mod 4 = 0
			For i= 1 To 7
				colr[i-1] = colr[i]
				colg[i-1] = colg[i]
				colb[i-1] = colb[i]
			Next
		EndIf

		If counter > 50
			SetColor 255,255,255
			SetRotation(counter)
		 	DrawImage whiteplayer,SCREENW/2-200+lwsp,SCREENH/2-lsp*4
			SetRotation(0)
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			DrawString("Your Ship",SCREENW/2-100,SCREENH/2-lsp*4-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 100
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200-lwsp,SCREENH/2-lsp*3,2
			SetBlend LIGHTBLEND
			SetColor colr[0],colg[0],colb[0]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200-lwsp,SCREENH/2-lsp*3
			SetRotation 0
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Temporary Back Shooter",SCREENW/2-100,SCREENH/2-lsp*3-10,3)
		EndIf
		If counter > 150
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200+lwsp,SCREENH/2-lsp*2,3
			SetBlend LIGHTBLEND
			SetColor colr[1],colg[1],colb[1]
			SetRotation(counter*6+45)
			DrawImage whitestar,SCREENW/2-200+lwsp,SCREENH/2-lsp*2
			SetRotation 0
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			DrawString("Temporary Side Shooters",SCREENW/2-100,SCREENH/2-lsp*2-10,3)
		EndIf
		If counter > 200
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200-lwsp,SCREENH/2-lsp,0
			SetBlend LIGHTBLEND
			SetColor colr[2],colg[2],colb[2]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200-lwsp,SCREENH/2-lsp
			SetRotation 0
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Extra Front Shooter",SCREENW/2-100,SCREENH/2-lsp-10,3)
		EndIf
		If counter > 250
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200+lwsp,SCREENH/2,5
			SetBlend LIGHTBLEND
			SetColor colr[3],colg[3],colb[3]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200+lwsp,SCREENH/2
			SetRotation 0
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			DrawString("Extra Shot Speed",SCREENW/2-100,SCREENH/2-10,3)
		EndIf
		If counter > 300
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200-lwsp,SCREENH/2+lsp,6
			SetBlend LIGHTBLEND
			SetColor colr[4],colg[4],colb[4]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200-lwsp,SCREENH/2+lsp
			SetRotation 0
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Extra Player",SCREENW/2-100,SCREENH/2+lsp-10,3)
		EndIf
		If counter > 350
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200+lwsp,SCREENH/2+lsp*2,8
			SetBlend LIGHTBLEND
			SetColor colr[5],colg[5],colb[5]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200+lwsp,SCREENH/2+lsp*2
			SetRotation 0
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			DrawString("Extra Bomb",SCREENW/2-100,SCREENH/2+lsp*2-10,3)
		EndIf
		If counter > 400
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200-lwsp,SCREENH/2+lsp*3,9
			SetBlend LIGHTBLEND
			SetColor colr[6],colg[6],colb[6]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200-lwsp,SCREENH/2+lsp*3
			SetRotation 0
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Temporary Shield",SCREENW/2-100,SCREENH/2+lsp*3-10,3)
		EndIf
		If counter > 450
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200+lwsp,SCREENH/2+lsp*4,7
			SetBlend LIGHTBLEND
			SetColor colr[6],colg[6],colb[6]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200+lwsp,SCREENH/2+lsp*4
			SetRotation 0
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			DrawString("Super Shots",SCREENW/2-100,SCREENH/2+lsp*4-10,3)
		EndIf
		If counter > 500
			SetAlpha 1
			SetRotation 0
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage powerimage,SCREENW/2-200-lwsp,SCREENH/2+lsp*5,10
			SetBlend LIGHTBLEND
			SetColor colr[7],colg[7],colb[7]
			SetRotation(counter*6)
			DrawImage whitestar,SCREENW/2-200-lwsp,SCREENH/2+lsp*5
			SetRotation 0
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Bouncy Shots",SCREENW/2-100,SCREENH/2+lsp*5-10,3)
		EndIf

		SetColor 255,255,0
		If counter Mod 50 > 25
			DrawString("Press BOMB Button to Start",SCREENW/2-250,SCREENH-32,4)
		EndIf

'		DrawLine 0,0,SCREENW,0
'		DrawLine 0,0,0,SCREENH
'		DrawLine SCREENW-1,0,SCREENW-1,SCREENH-1
'		DrawLine 0,SCREENH-1,SCREENW-1,SCREENH-1

		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		counter = counter+1
		bombtime = bombtime - 1
		If bombtime < 0 Then bombtime = 0
		If KeyHit(KEY_ESCAPE) Or ..
			(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)

			If Options(False) Then Return True
		EndIf
		If KeyHit(k_bomb) Or MouseHit(m_bomb) Or ..
			(JoyDown(j_pad_bomb,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_bomb,joyport) And controltype = 0 And bombtime = 0)
			counter = 1000
			playgame = True
		EndIf
	Wend
	Return False
End Function





Function ShowEnemies:Int(f:Int=-1)
	Local counter:Int = 0, i:Int
	Local tim:Int
	Local lsp:Int = 50
	Local lwsp:Int = 0

	FlushKeys()
	bombtime = 20

	While (counter < 900)
		Cls
		tim = MilliSecs()
		If (SCREENH<600) Then lsp = 32;lwsp = 32 Else lsp = 50;lwsp = 0

		SetColor 255,0,0
		DrawString("Know Your Enemies",SCREENW/2-4.5*5*18/2-32,10,4.5)

		If counter > 50
			SetColor 255,255,255
			SetRotation(counter*4)
			DrawImage pinkpinwheel,SCREENW/2-200-lwsp,SCREENH/2-lsp*4
			SetRotation(0)
			SetColor COL_PIN_R,COL_PIN_G,COL_PIN_B
			DrawString("Paul the Pinwheel (25 pts)",SCREENW/2-120,SCREENH/2-lsp*4-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 100
			Local sc%,scy#,scx#
			sc = counter Mod (256)
			If sc > 127
				scy = sc-127
				If sc > 127+63 Then scy = 255-sc
				scx = 0
			Else
				scx = sc
				If sc > 63 Then scx = 127-sc
				scy = 0
			EndIf
			SetScale 1+scx/80.0,1+scy/80.0
			DrawImage bluediamond,SCREENW/2-200+lwsp,SCREENH/2-lsp*3
			SetScale 1,1
			SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
			DrawString("Dimmy the Diamond (50 pts)",SCREENW/2-120,SCREENH/2-lsp*3-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 150
			SetRotation(counter*2)
			DrawImage greensquare,SCREENW/2-200-lwsp,SCREENH/2-lsp*2
			SetRotation(0)
			SetColor COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B
			DrawString("Shy the Square (100 pts)",SCREENW/2-120,SCREENH/2-lsp*2-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 200
			SetRotation(-counter*2.5+90)
			DrawImage purplesquare1,SCREENW/2-200+lwsp,SCREENH/2-lsp
			SetRotation(0)
			SetColor COL_CUBE_R,COL_CUBE_G,COL_CUBE_B
			DrawString("Cubie the Cube (50/100 pts)",SCREENW/2-120,SCREENH/2-lsp-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 250
			DrawImage bluecircle,SCREENW/2-200-lwsp,SCREENH/2
			SetColor COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B
			DrawString("Sammy the Seeker (10 pts)",SCREENW/2-120,SCREENH/2-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 300
			SetScale .75+Sin(counter*8)*.25,.75+Sin(counter*8)*.25
			DrawImage redcircle,SCREENW/2-200+lwsp,SCREENH/2+lsp
			SetScale 1,1
			SetColor COL_SUN_R,COL_SUN_G,COL_SUN_B
			DrawString("Dwight the Black Hole (150 pts)",SCREENW/2-120,SCREENH/2+lsp-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 350
			For Local tt:Int = 0 To 23
				SetRotation 90-Cos(tt*30+counter)*20
				If tt = 0
					DrawImage snakehead,SCREENW/2-200+lwsp+45-tt*13,SCREENH/2+lsp*2+Sin(tt*30+counter)*16
				Else
					DrawImage snaketail,SCREENW/2-200+lwsp+45-tt*13,SCREENH/2+lsp*2+Sin(tt*30+counter)*16,24-tt
				EndIf
			Next
			SetRotation 0
			SetColor COL_SNAKE_R,COL_SNAKE_G,COL_SNAKE_B
			DrawString("Selena the Snake (100 pts)",SCREENW/2-120,SCREENH/2+lsp*2-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 400
			SetRotation(counter)
			DrawImage redclone,SCREENW/2-200-lwsp,SCREENH/2+lsp*3
			SetRotation(0)
			SetColor COL_CLONE_R,COL_CLONE_G,COL_CLONE_B
			DrawString("Ivan the Interceptor (100 pts)",SCREENW/2-120,SCREENH/2+lsp*3-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 450
			SetRotation(-counter*3)
			DrawImage orangetriangle,SCREENW/2-200+lwsp,SCREENH/2+lsp*4
			SetRotation(0)
			SetColor COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B
			DrawString("Trish the Triangle (150 pts)",SCREENW/2-120,SCREENH/2+lsp*4-10,3)
			SetColor 255,255,255
		EndIf
		If counter > 500
			SetRotation(counter*4)
			DrawImage indigotriangle,SCREENW/2-200-lwsp,SCREENH/2+lsp*5
			SetRotation(0)
			SetColor COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B
			DrawString("Indy the Butterfly (10 pts)",SCREENW/2-120,SCREENH/2+lsp*5-10,3)
			SetColor 255,255,255
		EndIf

		If Rand(0,100) > 94 And counter < 850 Then part.CreateFireworks(1)
		part.UpdateParticles(1)
		part.DrawParticles()
		SetColor 255,255,0
		If counter Mod 50 > 25
			DrawString("Press BOMB Button to Start",SCREENW/2-250,SCREENH-32,4)
		EndIf
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		counter = counter+1
		bombtime:-1
		If bombtime < 0 Then bombtime = 0
		If KeyHit(KEY_ESCAPE) Or ..
			(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)
			If Options(False) Then Return True
		EndIf
		If KeyHit(k_bomb) Or MouseHit(m_bomb) Or ..
			(JoyDown(j_pad_bomb,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_bomb,joyport) And controltype = 0 And bombtime = 0)
			counter = 1000
			playgame = True
		EndIf
	Wend
	Return False
End Function



Function ShowScores:Int(f:Int=-1)
	Local counter:Int = 0, i:Int
	Local ptime$ = GetPlayTime$(gcount)
	Local t:Int, kol:Int
	Local tim:Int,s$,spc:Int
	Local d:Int

	Local colr:Int[10]
	Local colg:Int[10]
	Local colb:Int[10]

	For i:Int = 9 To 0 Step -1
		CycleColours()
		CycleColours()
		colr[i] = rcol
		colg[i] = gcol
		colb[i] = bcol
	Next
	FlushKeys()
	bombtime = 20
	While (counter < 750)
		Cls
		tim = MilliSecs()
		d = counter/250
		If f <> -1 Then d = laststartingdifficulty
		CycleColours()
		CycleColours()
		colr[9] = rcol
		colg[9] = gcol
		colb[9] = bcol
		If counter Mod 4 = 0
			For i= 1 To 9
				colr[i-1] = colr[i]
				colg[i-1] = colg[i]
				colb[i-1] = colb[i]
			Next
		EndIf
		SetColor 0,0,240
		DrawString("TOP SCORES - "+difficulty$[d],SCREENW/2-200,SCREENH/2-220,4)
		SetColor 64,240,64
		DrawString("SCORE",SCREENW/2-250,SCREENH/2-180,3)
		DrawString("NAME",SCREENW/2-100,SCREENH/2-180,3)
		DrawString("TIME",SCREENW/2+130,SCREENH/2-180,3)

		For t = 0 To 9
			SetColor colr[9-t],colg[9-t],colb[9-t]
			If t = f And d = laststartingdifficulty
				SetColor 255,255,0
			EndIf
			If KeyDown(KEY_P)
				s$ = scores[t,d]
				spc= Len(s$)
				DrawString(s$,SCREENW/2-180-spc*14,SCREENH/2-150+t*32,2)
				DrawString(names[t,d],SCREENW/2-120,SCREENH/2-150+t*32,2)
				DrawString((playtimes[t,d]),SCREENW/2+64,SCREENH/2-150+t*32,2)
				s$ = scoresetting[t,d]
				DrawString(s$,SCREENW/2-180-spc*14,SCREENH/2-150+t*32+16,2)
			Else
				s$ = scores[t,d]
				spc= Len(s$)
				DrawString(s$,SCREENW/2-180-spc*14,SCREENH/2-150+t*30,3)
				DrawString(names[t,d],SCREENW/2-120,SCREENH/2-150+t*30,3)
				DrawString((playtimes[t,d]),SCREENW/2+64,SCREENH/2-150+t*30,3)
			EndIf
		Next
		If f = -20
			s$ = pscore
			spc= Len(s$)
			SetColor 255,0,0
			DrawString(s$,SCREENW/2-180+32-spc*14,SCREENH/2-150+11*30,3)
			DrawString(ptime$,SCREENW/2+64-32,SCREENH/2-150+11*30,3)
		EndIf
		If Rand(0,100) > 90 And counter < 700 Then part.CreateFireworks(1)
		part.UpdateParticles(1)
		part.DrawParticles()
		SetColor 255,255,0
		If counter Mod 50 > 25
			DrawString("Press BOMB Button to Start",SCREENW/2-250,SCREENH-32,4)
		EndIf
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		counter = counter+1
		bombtime:-1
		If bombtime < 0 Then bombtime = 0
		If KeyHit(KEY_ESCAPE) Or ..
			(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)
			If Options(False) Then Return True
			bombtime = 20
		EndIf
		If KeyHit(k_bomb) Or MouseHit(m_bomb) Or ..
			(JoyDown(j_pad_bomb,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_bomb,joyport) And controltype = 0 And bombtime = 0)
			counter = 1000
			playgame = True
			bombtime = 20
		EndIf
	Wend
	Return False
End Function



Function ShowTitle:Int()

	Local counter:Int,kol:Int,sc#,st$,ln:Int,xd:Int,yd:Int,z:Int,cc:Int,zz#,b:Int
	Local tim:Int
	Local shrink# = (SCREENW/1024.0)

	nme5.createdisplayeffect(SCREENW/2+Rand(-100,100),SCREENH/2+Rand(-100,100),Rand(12,50))
	nme5.createdisplayeffect(SCREENW/2+Rand(-100,100),SCREENH/2+Rand(-100,100),Rand(12,50))

	SetViewport 0,0,SCREENW,SCREENH
	gxoff = 0
	gyoff = 0
	FlushKeys()
	bombtime = 20
	counter = 0
	st$ = "GridWars 2"
	ln = Len(st$)-1
	While (counter < 900)
		SetLineWidth 2.0
		SetBlend lightblend
		SetAlpha 1
		shrink# = (SCREENW / 1024.0)
		gcount:+1
		Cls
		tim = MilliSecs()
		CycleColours()
		If tcounter > 350
			If Rand(0,100) > 90 And counter < 850 Then part.CreateFireworks(0)
			part.UpdateParticles(1)
			part.DrawParticles()
			BlackholeParticles()
			'red circles
			For Local n5:nme5 = EachIn nme5_list
				n5.UpdateDisplayEffect()
			Next
		EndIf

		kol = 128+tcounter/3 ; If kol > 255 Then kol = 255
		SetColor 0,0,kol
		sc# = tcounter/24.0;If sc# > 20 Then sc#=20
		For z = 0 To tcounter/25
			SetColor rcol,gcol,bcol
			xd = (SCREENW-ln*sc*shrink*5.5)/2+Cos(z*20+counter*2)*(2+tcounter/60)
			yd = (SCREENH-18*sc*shrink)/2-50+Sin(z*20+counter*2)*(2+tcounter/60)+600/8-tcounter/8
			DrawString(st$,xd,yd,sc*shrink)
		Next

		SetColor 64,180,64
		DrawString("Programmed In Blitzmax",SCREENW/2-22/2*5*3.2*shrink,SCREENH-280,3.2*shrink)
		DrawString("By Mark Incitti",SCREENW/2-15/2*5*3.2*shrink,SCREENH-240,3.2*shrink)
		If counter Mod 200 > 99
			DrawString(version$,SCREENW/2-25/2*5*3*shrink,SCREENH-200,3*shrink)
		Else
			DrawString(advert$,SCREENW/2-36/2*5*3*shrink,SCREENH-200,3.1*shrink)
		EndIf

		SetColor 240,32,200
		DrawString("Special Thanks To",SCREENW/2-17/2*5*3.2*shrink,SCREENH-160,3.2*shrink)
		SetColor 200,32,240
		DrawString("Svrman, taumel - Gfx & Effects, Swith - Music, RiK - Mac",SCREENW/2-56/2*5*3.2*shrink,SCREENH-120,3.2*shrink)

		SetColor 255,255,0
		If counter Mod 60 > 29
			DrawString("Press BOMB Button to Start",SCREENW/2-26/2*5*4*shrink,SCREENH-32,4*shrink)
		EndIf
		Flip 1
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		counter = counter+1
		bombtime:-1
		If bombtime < 0 Then bombtime = 0
		tcounter = tcounter+1;If tcounter > 600 Then tcounter = 600

		If KeyHit(KEY_ESCAPE) Or ..
			(JoyDown(j_pad_option,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_option,joyport) And controltype = 0 And bombtime = 0)
			If Options(False) Then Return True
		EndIf
		If KeyHit(k_bomb) Or MouseHit(m_bomb) Or ..
			(JoyDown(j_pad_bomb,joyport) And controltype = 3 And bombtime = 0) Or ..
			(JoyDown(j_d_bomb,joyport) And controltype = 0 And bombtime = 0)
			counter = 1000
			playgame = True
		EndIf
	Wend
	tcounter = 600
	Return False
End Function

















Function CenterPlayer()

	px = PLAYFIELDW/2
	py = PLAYFIELDH/2
	gxoff = (PLAYFIELDW-SCREENW)/2
	gyoff = (PLAYFIELDH-SCREENH)/2

End Function



Function GetReady:Int()

	Local count:Int
	Local i:Int
	Local tim:Int

	CenterPlayer()

	PlaySound2(get_ready_snd)
	count = 0
	While count < 60 And Not KeyDown(KEY_ESCAPE)
		Cls
		tim = MilliSecs()

		gridpoint.UpdateGrid()
		UpdateAll()
		drawall()
'		If KeyDown(KEY_TAB) Then End
'		If Not KeyDown(KEY_F8)
			SetColor 0,55+Abs(Sin(count))*200,0
			DrawString("GET READY",..
			  SCREENW/2-Abs(Sin(count))*19*5*9*.5,..
			  SCREENH/2-Abs(Sin(count))*100,..
			  Abs(Sin(count))*20)

'			DrawString("GET READY", SCREENW/2+60-Abs(Sin(count))*SCREENW/2,SCREENH/2-Abs(Sin(count))*100,Abs(Sin(count))*20)
'		EndIf
		Flip
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf

		count:+1
		If KeyHit(k_bomb) Or MouseHit(m_bomb)
			count = 60
		EndIf
	Wend
	gridpoint.Pull(px,py,20,20)
	count = 0
	While count < 40 And Not KeyDown(KEY_ESCAPE)
		Cls
		tim = MilliSecs()

		gridpoint.UpdateGrid()
		UpdateAll()
		drawall()
'		If KeyDown(KEY_TAB) Then End
'		If Not KeyDown(KEY_F8)
			SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
			If count > 10 Then DrawPlayer(px,py,pr)
			DrawCircle(SCREENW/2,SCREENH/2,300-count*6)
			DrawCircle(SCREENW/2,SCREENH/2,300-count*8)
			DrawCircle(SCREENW/2,SCREENH/2,300-count*12)
'		EndIf
		Flip
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf

		count:+1
		If KeyHit(k_bomb) Or MouseHit(m_bomb)
			count = 40
		EndIf
	Wend
	player_shield = 80
	messtime = 0
	StartMusic(1)
	Score.ResetMultiplier()
	oldmx = 0
	oldmy = 0
	MoveMouse(SCREENW/2,SCREENH/2)

End Function



Function KillPlayer:Int()
	Local tim:Int

	If nokillme Or player_shield> 0 Then Return False

	'only killed once per update
	If dying Then Return False

	dying = True
	StopMusic()

	PlaySound2(player_hit_snd)

	' create explosion
	For Local t:Int = 0 To 255
		part.Create(px,py,0 ,COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B)
	Next

	gridpoint.Pull(px,py,32,64)

	Local s:shot
	For s:shot = EachIn shot_list
		shot_list.remove(s)
	Next

	removeall(False) 'remove all but the killer
	Local count:Int = 0
	While (count < 100)  And Not KeyDown(KEY_ESCAPE)
		Cls
		tim = MilliSecs()

		'gridpoint.UpdateGrid()
		UpdateAll(count)
		drawall()
		Flip
		tim = MilliSecs() - tim
		If tim < 20 And tim > 0
			Delay 20-tim
		EndIf
		count:+1
	Wend
	removeall(True) 'remove killer too

	' reset to center
	numplayers = numplayers - 1
	CenterPlayer()
	gridpoint.ResetAll()

	If numplayers = 0
		gameover = True
		PlaySound2(game_over_snd)
	Else
		' take away a shot, speed and return to forward shooting
		If numshots > 2 Then numshots:-1
		If shotspeed > 3 Then shotspeed:-1
		shot_back = 0
		shot_side = 0
		supershots = 0
		bouncyshots	= 0
		jdfx = 0
		jdfy = 0
		' reset score multiplier to 1X
		score.ResetMultiplier()
		GetReady()
	EndIf

	dying = False
	Cls
	Return True

End Function




Function RemoveAll(all:Int=False)

	Local n:nme
	Local n1:nme1
	Local n2:nme2
	Local n3:nme3
	Local n4:nme4
	Local n5:nme5
	Local n6:nme6
	Local n7:nme7
	Local n8:nme8
	Local g:ge
	Local ll:le
	Local po:pu
	Local sc:score
	Local s:shot
	Local tr:trail

	For tr:trail = EachIn trail_list
		trail_list.Remove(tr)
	Next

	For s:shot = EachIn shot_list
		shot_list.Remove(s)
	Next

	For sc:score = EachIn score_list
		score_list.Remove(sc)
	Next

	If all Then part.ResetAll()

	StopLoopingSounds()

	For n:nme = EachIn nme_list
		If all Or n.killer = False nme_LIST.Remove(n)
	Next
	For n1:nme1 = EachIn nme1_list
		If all Or n1.killer = False nme1_LIST.Remove(n1)
	Next
	For n2:nme2 = EachIn nme2_list
		If all Or n2.killer = False nme2_LIST.Remove(n2)
	Next
	For n3:nme3 = EachIn nme3_list
		If all Or n3.killer = False nme3_LIST.Remove(n3)
	Next
	For n4:nme4 = EachIn nme4_list
		If all Or n4.killer = False nme4_LIST.Remove(n4)
	Next
	For n5:nme5 = EachIn nme5_list
		If all Or n5.killer = False nme5_LIST.Remove(n5)
	Next
	For ll:le = EachIn le_list
		If all Or ll.killer = False le_LIST.Remove(ll)
	Next
	For g:ge = EachIn ge_list
		If all Or g.killer = False ge_list.Remove(g)
	Next
	For po:pu = EachIn pu_list
		pu_list.Remove(po)
	Next
	For n6:nme6 = EachIn nme6_list
		If all Or n6.killer = False nme6_LIST.Remove(n6)
	Next
	For n7:nme7 = EachIn nme7_list
		If all Or n7.killer = False nme7_LIST.Remove(n7)
	Next
	For n8:nme8 = EachIn nme8_list
		If all Or n8.killer = False nme8_LIST.Remove(n8)
	Next

	If all Then gridpoint.ResetAll()

	' reset the spawn counters
	sp_t = 0
	sp_t2 = 0
	sp_t3 = 0
	sp_t4 = 0

End Function




Function DestroyAll()
	Local n:nme
	Local n1:nme1
	Local n2:nme2
	Local n3:nme3
	Local n4:nme4
	Local n5:nme5
	Local n6:nme6
	Local n7:nme7
	Local n8:nme8
	Local g:ge
	Local ll:le
	Local po:pu

	For n:nme = EachIn nme_list
		n.kill(False)
	Next
	For n1:nme1 = EachIn nme1_list
		n1.kill(False)
	Next
	For n2:nme2 = EachIn nme2_list
		n2.kill(False)
	Next
	For n3:nme3 = EachIn nme3_list
		n3.kill(False)
	Next
	For n4:nme4 = EachIn nme4_list
		n4.kill(False)
	Next
	For n5:nme5 = EachIn nme5_list
		n5.kill(False)
	Next
	For n6:nme6 = EachIn nme6_list
		If n6.ishead
			n6.kill(False)
		EndIf
	Next
	For n7:nme7 = EachIn nme7_list
		n7.kill(False)
	Next
	For n8:nme8 = EachIn nme8_list
		n8.kill(False)
	Next
	For ll:le = EachIn le_list
		ll.kill(False,0,0)
	Next
	For g:ge = EachIn ge_list
		g.kill(False)
	Next

End Function


Function ResetGame()

	laststartingdifficulty = startingdifficulty
	gameover = False

	speed_nme#  = 3.1
	speed_nme1# = 2.25
	speed_nme2# = 3.25
	speed_nme3# = 3.0
	speed_nme4# = 4.35
	speed_nme5# = 2.5
	speed_nme6# = 3.5
	speed_nme7# = 4.45
	speed_nme8# = 5.0
	speed_le#   = 2.0

	Select startingdifficulty
		Case 0 ' easy

			upgradetime = 20

			speed_nme#:*  .75
			speed_nme1#:* .75
			speed_nme2#:* .75
			speed_nme3#:* .75
			speed_nme4#:* .75
			speed_nme5#:* .75
			speed_nme6#:* .75
			speed_nme7#:* .75
			speed_nme8#:* .75
			speed_le#:* .75

			numplayers = 4
			numbombs = 4

			numshots = 2
			shotspeed = 4
			gcount = 1

			EXTRABOMB = exbomb[0]  '100000
			EXTRALIFE = exlife[0]   '75000

		Case 1'medium

			upgradetime = 18

			numplayers = 3
			numbombs = 3

			numshots = 2
			shotspeed = 3
			gcount = 1

			EXTRABOMB = exbomb[1]  '150000
			EXTRALIFE = exlife[1]   '100000

		Case 2'hard

			upgradetime = 16

			speed_nme#:*  1.25
			speed_nme1#:* 1.25
			speed_nme2#:* 1.25
			speed_nme3#:* 1.25
			speed_nme4#:* 1.25
			speed_nme5#:* 1.25
			speed_nme6#:* 1.25
			speed_nme7#:* 1.25
			speed_nme8#:* 1.25
			speed_le#:*   1.25

			numplayers = 2
			numbombs = 2

			numshots = 2
			shotspeed = 3
			gcount = 7000

			EXTRABOMB = exbomb[2]  '200000
			EXTRALIFE = exlife[2]   '150000

	End Select

	extralifecount = 1
	shot_back = 0
	shot_side = 0
	supershots = 0
	bouncyshots = 0
	jdfx = 0
	jdfy = 0
	powerupscore = POWERUP
	bombtime = 20
	extrabombcount = 1
	sp_t = 0
	sp_t2 = 0
	sp_t3 = 0
	sp_t4 = 0

	score.ResetScore()
	score.ResetMultiplier()

End Function





Function EnemyType:Int(cnt:Int)

	Local t:Int
	Local sel:Int = cnt/1100
	If sel > 8 Then sel = 8
	Select sel
		Case 0
			t = 0
		Case 1
			t = Rand(0,1)
		Case 2
			t = Rand(0,2)
		Case 3
			t = Rand(0,3)
		Case 4
			t = Rand(0,4)
		Case 5
			t = Rand(0,5)
		Case 6
			t = Rand(0,6)
		Case 7
			t = Rand(0,7)
		Case 8
			t = Rand(0,9)
	End Select

	Return t
End Function



Function Spawn(cnt:Int)

Rem
	If cnt Mod 40 = 0
		CreateEnemy(Rand(1,2),20, Rand(0,12))
	EndIf
	If cnt Mod 40 = 0
		CreateEnemy(5,20, Rand(0,12))
	EndIf
	Return
End Rem
	Local gk:Int,sz:Int,rate:Int

	'single enemy
	If (cnt/350) Mod 2 = 0
		If cnt Mod 33 = 0
			CreateEnemy(EnemyType(cnt),30, Rand(0,12))
		EndIf
	EndIf
	'single generator
	If cnt Mod 444 = 0
		gk = EnemyType(cnt/3+500)+1
		sz = Min(Rand(16+cnt/2000),32)
		rate = 80+Rand(60)-cnt/1000
		If rate < 60 Then rate = 60
		If gk = 9 'no clone generator
			gk = 10 'butterfly geerator
		EndIf
		If gk = 6 'no sun generator
			gk = Rand(3,5) 'green, purp, or blue
		EndIf
		CreateEnemy(10,20,Rand(0,12),rate,gk,sz)
	EndIf
	'whole bunch
	If cnt Mod 777 = 0
		sp_c = Rand(0,12)
		sp_x = EnemyType(cnt/3)
		sp_t = Rand(15,24+(cnt/750))*2
		If sp_t > 100 Then sp_t = 100
		If sp_x = 5
			sp_t = 2*8
		EndIf
	EndIf
	If cnt Mod 1850 = 0
		'whole bunch
		sp_c2 = Rand(0,12)
		sp_x2 = EnemyType(cnt/2)
		sp_t2 = Rand(15,24+(cnt/750))*2
		If sp_t2 > 175 Then sp_t2 = 175
		If sp_x2 = 5
			sp_t2 = 2*8
		EndIf
	EndIf
	If cnt Mod 2900  = 0
		'whole bunch
		sp_c3 = 5 'all 4 corners
		sp_x3 = EnemyType(cnt/2)
		sp_t3 = Rand(20,40+(cnt/750))*3
		If sp_t3 > 100*3 Then sp_t3 = 100*3
		If sp_x3 = 5
			sp_t3 = 3*8
		EndIf
	EndIf
	If ((cnt/4000) Mod 2 = 1) And (cnt Mod 3333 = 0)
		'whole bunch
		sp_c4 = Rand(0,11) 'any corner/s
		sp_x4 = EnemyType(cnt/2)
		sp_t4 = Rand(20,40+(cnt/750))*3
		If sp_t4 > 100*3 Then sp_t4 = 100*3
		If sp_x4 = 5
			sp_t4 = 3*8
		EndIf
	EndIf
	'keep placing the whole bunch
	If sp_t > 0
		sp_t:-1
		If sp_t Mod 2 = 0
			CreateEnemy(sp_x,24,sp_c)
		EndIf
	EndIf
	'keep placing the whole bunch
	If sp_t2 > 0
		sp_t2:-1
		If sp_t2 Mod 2 = 0
			CreateEnemy(sp_x2,24,sp_c2)
		EndIf
	EndIf
	'keep placing the whole bunch
	If sp_t3 > 0
		sp_t3:-1
		If sp_t3 Mod 3 = 0
			If sp_x3 = 9 Then CreateEnemy(sp_x3,20,sp_c3) ' 2X more indigo triangles
			CreateEnemy(sp_x3,20,sp_c3)
		EndIf
	EndIf
	'keep placing the whole bunch
	If sp_t4 > 0
		sp_t4:-1
		If sp_t4 Mod 3 = 0
			If sp_x4 = 9 Then CreateEnemy(sp_x4,20,sp_c4) ' 2X more indigo triangles
			CreateEnemy(sp_x4,20,sp_c4)
		EndIf
	EndIf
	If cnt Mod 50*60 = 1'every minute?
		Local inc# = 0.15+startingdifficulty*0.1
		speed_nme#:+ inc
		speed_nme1#:+ inc
		speed_nme2#:+ inc
		speed_nme3#:+ inc
		speed_nme4#:+ inc
		speed_nme5#:+ inc
		speed_nme6#:+ inc
		speed_nme7#:+ inc
		speed_nme8#:+ inc
		speed_le#:+ inc
	EndIf

End Function



Function CreateEnemy(kind:Int,freeze:Int,corner:Int=0,rate:Int=100,gkind:Int=1,size:Int=20)

	If bombtime > 0 Then Return
	Local x:Int,y:Int,k:Int,sz:Int
	If corner > 4
		Select corner
			Case 5
				corner = Rand(1,4)
			Case 6
				If Rand(1,10) > 5 Then corner = 1 Else corner = 2
			Case 7
				If Rand(1,10) > 5 Then corner = 2 Else corner = 3
			Case 8
				If Rand(1,10) > 5 Then corner = 3 Else corner = 4
			Case 9
				If Rand(1,10) > 5 Then corner = 1 Else corner = 3
			Case 10
				If Rand(1,10) > 5 Then corner = 1 Else corner = 4
			Case 11
				If Rand(1,10) > 5 Then corner = 2 Else corner = 4
		End Select
	EndIf
	Select corner
		Case 0
			x = Rand(30,PLAYFIELDW-30)
			y = Rand(30,PLAYFIELDH-30)
		Case 1
			x = Rand(30,80)
			y = Rand(30,80)
		Case 2
			x = Rand(PLAYFIELDW-80,PLAYFIELDW-30)
			y = Rand(30,80)
		Case 3
			x = Rand(PLAYFIELDW-80,PLAYFIELDW-30)
			y = Rand(PLAYFIELDH-80,PLAYFIELDH-30)
		Case 4
			x = Rand(30,80)
			y = Rand(PLAYFIELDH-80,PLAYFIELDH-30)
		Case 12
			Local dir:Int = Rand(0,360)
			Local mag# = 240
			x = px+Cos(dir)*mag
			y = py+Sin(dir)*mag
	End Select
	Select kind
		Case 0
			nme1.Create(x,y,freeze)
		Case 1
			nme2.Create(x,y,freeze)
		Case 2
			nme.Create(x,y,freeze)
		Case 3
			nme3.Create(x,y,0,freeze)
		Case 4
			nme4.Create(x,y,freeze)
		Case 5
			nme5.Create(x,y,20,freeze)
		Case 6
			le.Create(x,y,freeze)
		Case 7
			nme6.Create(x,y,24,freeze)
		Case 8
			nme7.Create(x,y,freeze)
		Case 9
			nme8.Create(x,y,freeze)
		Case 10
			ge.Create(x,y,gkind,rate,size,freeze)
	End Select

End Function





Function Updateplayer()

	Local xx#,yy#,xy#, jb:Int, i:Int, r:Int	, speed#
	Select controltype

		Case 1 ' mouse
			'bombs
			jb = 0
			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0
			jb = KeyDown(k_bomb) + MouseDown(m_bomb)
			If jb And bombtime = 0 Then shot.SuperBomb()

			'move
			xx = (MouseX()-SCREENW/2)
			yy = (MouseY()-SCREENH/2)
			MoveMouse(SCREENW/2,SCREENH/2)

			jdmx = xx/128*(1+m_sensitivity*5)
			jdmy = yy/128*(1+m_sensitivity*5)
'			xy = Sqr(jdmx*jdmx+jdmy*jdmy)

'			If xy > 10
'				jdmx = jdmx/xy*10
'				jdmy = jdmy/xy*10
'			EndIf

			'fire
			If MouseDown(m_fire)
				'change fire direction
				xy = (jdmx*jdmx+jdmy*jdmy)
				If xy > 0
					jdfx = xx/16
					jdfy = yy/16
				EndIf
			Else
				If Not autofire
					jdfx = 0
					jdfy = 0
				EndIf
			EndIf
			oldmx:*inertia
			oldmy:*inertia
			jdmx:+oldmx
			jdmy:+oldmy
			' stay within screen
			speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
			If speed > (1+m_sensitivity*10)
				jdmx = jdmx/(1+m_sensitivity*10)
				jdmy = jdmy/(1+m_sensitivity*10)
			EndIf
			oldmx = jdmx
			oldmy = jdmy
		Case 0 ' dual analog joy
			'bombs
			jb = 0
			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0
			jb = JoyDown(j_d_bomb,joyport)
			If jb And bombtime = 0 Then shot.SuperBomb()

			'move
			jdmx = GetJoyByAxis(joyport, axis_move_x,axis_move_x_inv,axis_move_x_sc,axis_move_x_center )
			jdmy = GetJoyByAxis(joyport, axis_move_y,axis_move_y_inv,axis_move_y_sc,axis_move_y_center )
'			If Abs(jdmx) < axis_move_x_dz Then jdmx = 0
'			If Abs(jdmy) < axis_move_y_dz Then jdmy = 0
			If Abs(jdmx) < axis_move_x_dz And Abs(jdmy) < axis_move_y_dz Then
				jdmx = 0
				jdmy = 0
			End If

			'fire
			jdfx = GetJoyByAxis(joyport, axis_fire_x,axis_fire_x_inv,axis_fire_x_sc,axis_fire_x_center )
			jdfy = GetJoyByAxis(joyport, axis_fire_y,axis_fire_y_inv,axis_fire_y_sc,axis_fire_y_center )
'			If Abs(jdfx) < axis_fire_x_dz Then jdfx = 0
'			If Abs(jdfy) < axis_fire_y_dz Then jdfy = 0
			If Abs(jdfx) < axis_fire_x_dz And Abs(jdfy) < axis_fire_y_dz Then
				jdfx = 0
				jdfy = 0
			End If
			oldmx:*inertia
			oldmy:*inertia
			jdmx:+oldmx
			jdmy:+oldmy
			' stay within screen
			speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
			If speed > 1
				jdmx = jdmx/speed
				jdmy = jdmy/speed
			EndIf
			oldmx = jdmx
			oldmy = jdmy

		Case 2 'keys
			'bombs
			jb = KeyDown(k_bomb)
			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0
			If jb And bombtime = 0 Then shot.SuperBomb()

			'move
			jdmx = KeyDown(k_move_right) - KeyDown(k_move_left)
			jdmy = KeyDown(k_move_down) - KeyDown(k_move_up)

			'fire
			If autofire
				If KeyDown(k_fire_right)
					jdfx = 1
					jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
				EndIf
				If KeyDown(k_fire_left)
					jdfx = -1
					jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
				EndIf
				If KeyDown(k_fire_down)
					jdfy = 1
					jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
				EndIf
				If KeyDown(k_fire_up)
					jdfy = -1
					jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
				EndIf
			Else
				jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
				jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
			EndIf
			oldmx:*inertia
			oldmy:*inertia
			jdmx:+oldmx
			jdmy:+oldmy
			' stay within screen
			speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
			If speed > 1
				jdmx = jdmx/speed
				jdmy = jdmy/speed
			EndIf
			oldmx = jdmx
			oldmy = jdmy
		Case 3 'joypad
			'bombs
			jb = 0
			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0
			jb = JoyDown(j_pad_bomb,joyport)
			If jb And bombtime = 0 Then shot.SuperBomb()

			Select j_config
				Case 0
					'move
					jdmx = JoyX()
					jdmy = JoyY()

					'fire
					jdfx = JoyDown(j_pad_3, joyport) - JoyDown(j_pad_1, joyport)
					jdfy = JoyDown(j_pad_2, joyport) - JoyDown(j_pad_4, joyport)

				Case 1
					'move
					jdmx = JoyDown(j_pad_3, joyport) - JoyDown(j_pad_1, joyport)
					jdmy = JoyDown(j_pad_2, joyport) - JoyDown(j_pad_4, joyport)

					'fire
					jdfx = JoyX()
					jdfy = JoyY()
			End Select
			If Abs(jdmx) < 0.5 Then jdmx = 0
			If Abs(jdmy) < 0.5 Then jdmy = 0
			If Abs(jdfx) < 0.5 Then jdfx = 0
			If Abs(jdfy) < 0.5 Then jdfy = 0

			oldmx:*inertia
			oldmy:*inertia
			jdmx:+oldmx
			jdmy:+oldmy
			' stay within screen
			speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
			If speed > 1
				jdmx = jdmx/speed
				jdmy = jdmy/speed
			EndIf
			oldmx = jdmx
			oldmy = jdmy
		Case 4 ' hybrid mouse/keys
			'bombs
			jb = KeyDown(k_bomb) + MouseDown(m_bomb)
			bombtime = bombtime - 1
			If bombtime < 0 Then bombtime = 0
			If jb And bombtime = 0 Then shot.SuperBomb()

			Select h_config
				Case 0
					'move
					jdmx = KeyDown(k_move_right) - KeyDown(k_move_left)
					jdmy = KeyDown(k_move_down) - KeyDown(k_move_up)

					mxaim= MouseX()
					myaim= MouseY()
					xx = mxaim-(px-gxoff)
					yy = myaim-(py-gyoff)
					xy = Sqr(xx*xx+yy*yy)
					If xy < 1 Then xy = 1

					'fire
					If MouseDown(m_fire)
						jdfx = xx/xy
						jdfy = yy/xy
					Else
						If Not autofire
							jdfx = 0
							jdfy = 0
						EndIf
					EndIf

					'Draw target
					DrawTarget(mxaim,myaim,gcount)
					oldmx:*inertia
					oldmy:*inertia
					jdmx:+oldmx
					jdmy:+oldmy
					' stay within screen
					speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
					If speed > 1
						jdmx = jdmx/speed
						jdmy = jdmy/speed
					EndIf
					oldmx = jdmx
					oldmy = jdmy
				Case 1
					'move
					xx = (MouseX()-SCREENW/2)
					yy = (MouseY()-SCREENH/2)
					MoveMouse(SCREENW/2,SCREENH/2)

					jdmx = xx/128*(1+m_sensitivity*5)
					jdmy = yy/128*(1+m_sensitivity*5)

					'fire
					If autofire
						If KeyDown(k_fire_right)
							jdfx = 1
							jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
						EndIf
						If KeyDown(k_fire_left)
							jdfx = -1
							jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
						EndIf
						If KeyDown(k_fire_down)
							jdfy = 1
							jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
						EndIf
						If KeyDown(k_fire_up)
							jdfy = -1
							jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
						EndIf
					Else
						jdfx = KeyDown(k_fire_right) - KeyDown(k_fire_left)
						jdfy = KeyDown(k_fire_down) - KeyDown(k_fire_up)
					EndIf
					oldmx:*inertia
					oldmy:*inertia
					jdmx:+oldmx
					jdmy:+oldmy
					' stay within screen
					speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
					If speed > (1+m_sensitivity*10)
						jdmx = jdmx/(1+m_sensitivity*10)
						jdmy = jdmy/(1+m_sensitivity*10)
					EndIf
					oldmx = jdmx
					oldmy = jdmy
				Case 2
					'move
					jdmx = KeyDown(k_move_right) - KeyDown(k_move_left)
					jdmy = KeyDown(k_move_down) - KeyDown(k_move_up)

					xx = (MouseX()-SCREENW/2)
					yy = (MouseY()-SCREENH/2)

					'fire
					If Not autofire
						If MouseDown(m_fire)
							xy = Sqr(xx*xx+yy*yy)
							If xy > 1
								mxaim = xx/xy
								myaim = yy/xy
							EndIf
							jdfx = mxaim
							jdfy = myaim
						Else
'							MoveMouse(SCREENW/2,SCREENH/2)
							jdfx = 0
							jdfy = 0
						EndIf
					Else
						xy = Sqr(xx*xx+yy*yy)
						If xy > 1
							mxaim = xx/xy
							myaim = yy/xy
						EndIf
						jdfx = mxaim
						jdfy = myaim
					EndIf

					If KeyDown(k_fire_up)
						If myaim > -1 Then myaim = myaim -.1
						If mxaim <> 0 Then mxaim = mxaim*.8
						jdfx = mxaim
						jdfy = myaim
					EndIf
					If KeyDown(k_fire_down)
						If myaim < 1 Then myaim = myaim +.1
						If mxaim <> 0 Then mxaim = mxaim*.8
						jdfx = mxaim
						jdfy = myaim
					EndIf
					If KeyDown(k_fire_right)
						If mxaim < 1 Then mxaim = mxaim +.1
						If myaim <> 0 Then myaim = myaim*.8
						jdfx = mxaim
						jdfy = myaim
					EndIf
					If KeyDown(k_fire_left)
						If mxaim > -1 Then mxaim = mxaim -.1
						If myaim <> 0 Then myaim = myaim*.8
						jdfx = mxaim
						jdfy = myaim
					EndIf
					'Draw target
					DrawTarget(px+mxaim*80-gxoff,py+myaim*80-gyoff,gcount)
					oldmx:*inertia
					oldmy:*inertia
					jdmx:+oldmx
					jdmy:+oldmy
					' stay within screen
					speed# = Sqr(jdmx*jdmx + jdmy*jdmy)
					If speed > 1
						jdmx = jdmx/speed
						jdmy = jdmy/speed
					EndIf
					oldmx = jdmx
					oldmy = jdmy

			End Select
	End Select

	px = px + jdmx*MAXPLAYERSPEED
	If px < 16 Or px > PLAYFIELDW-16
		px = px - jdmx*MAXPLAYERSPEED
		oldmx = -oldmx
	EndIf
	py = py + jdmy*MAXPLAYERSPEED
	If py < 16 Or py > PLAYFIELDH-16
		py = py - jdmy*MAXPLAYERSPEED
		oldmy = -oldmy
	EndIf
	If jdmy <> 0 Or jdmx <> 0
		pr = ATan2(jdmy,jdmx)-90
	EndIf

	' create player trail
	If Abs(jdmx) > 0.1 Or Abs(jdmy) > 0.1
		For Local tt:Int = 0 To 2
			trail.create(..
			px-jdmx*12+Sin(gcount*12+tt*45)*8,..
			py-jdmy*12+Cos(gcount*12+tt*45)*8,..
			COL_TRAIL_R,COL_TRAIL_G,COL_TRAIL_B,..
			-jdmx,-jdmy)
		Next
	EndIf


	If scroll
		' scroll the playfield
		Local scr:Int
		scr = px-gxoff
		If scr < 500
			gxoff:-2*(5-scr/100)
			If gxoff < -80
				gxoff = -80
			EndIf
		EndIf
		scr = py-gyoff
		If scr < 500
			gyoff:-2*(5-scr/100)
			If gyoff < -80
				gyoff = -80
			EndIf
		EndIf
		scr = px-gxoff-SCREENW
		If scr > -500
			gxoff:+2*(5-Abs(scr)/100)
			If gxoff > (PLAYFIELDW-SCREENW)+80
				gxoff = (PLAYFIELDW-SCREENW)+80
			EndIf
		EndIf
		scr = py-gyoff-SCREENH
		If scr > -500
			gyoff:+2*(5-Abs(scr)/100)
			If gyoff > (PLAYFIELDH-SCREENH)+80
				gyoff = (PLAYFIELDH-SCREENH)+80
			EndIf
		EndIf
	EndIf

If KeyHit(KEY_F3)
	g_style:+1
	If g_style > numgridstyles Then g_style = 0
	score.create("Grid Style ="+g_style,px-100,py-64,2)
EndIf
If KeyHit(KEY_F4)
	showstars:+100
	If showstars > MAXSTARS Then showstars = 0
	score.create("Number of Stars ="+showstars,px-100,py-64,2)
EndIf
If KeyHit(KEY_F5)
	gravityparticles = 1-gravityparticles
	If gravityparticles
		score.create("Particle Gravity ON",px-100,py-64,2)
	Else
		score.create("Particle Gravity OFF",px-100,py-64,2)
	EndIf
EndIf
If KeyHit(KEY_F6)
	particlestyle:+1;If particlestyle > numparticlestyles Then particlestyle = 0
	score.create("Particle - Style "+particlestyle,px-100,py-64,2)
EndIf
If KeyHit(KEY_F7)
	debug = 1-debug
	If debug
		score.create("Debug ON",px-100,py-64,2)
	Else
		score.create("Debug OFF",px-100,py-64,2)
	EndIf
EndIf

' cheat stuff
If KeyHit(KEY_F1)
	valid = False
	cheat = 1-cheat
	If cheat
		score.create("Cheatmode ON",px-100,py-64,2)
	Else
		score.create("Cheatmode OFF",px-100,py-64,2)
	EndIf
EndIf
If cheat
	If KeyHit(KEY_1) Then shot_back:+ 15*30
	If KeyHit(KEY_2) Then shot_side:+ 15*30
	If KeyHit(KEY_3) Then supershots:+ 15*30
	If KeyHit(KEY_4) Then bouncyshots:+ 15*30
	If KeyHit(KEY_X) Then numshots:+1;If numshots > 4 Then numshots = 4
	If KeyHit(KEY_Z) Then shotspeed:+1;If shotspeed > 5 Then shotspeed = 5
	If KeyHit(KEY_S) Then pu.MakePowerup(6)
	If KeyHit(KEY_F2)
		nokillme = 1-nokillme
		If nokillme
			score.create("God Mode ON",px-100,py-64,2)
		Else
			score.create("God Mode OFF",px-100,py-64,2)
		EndIf
	EndIf
EndIf
'

	' timed upgrades
	If shot_back > 0
		shot_back:-1
	EndIf
	If shot_side > 0
		shot_side:-1
	EndIf
	If player_shield > 0
		player_shield:-1
		If player_shield = 100 Or player_shield = 70 Or player_shield = 40
			playsound2(shieldwarningsnd)
		EndIf
	EndIf
	If supershots > 0
		supershots :-1
	EndIf
	If bouncyshots> 0
		bouncyshots:-1
	EndIf

	' fire!
	shottimer:-1
	If shottimer < 0 Then shottimer = 0
	If shottimer = 0
		If debug
			shottimer = 4
			' evil!
			If numshots = 2 Then shottimer = 8   '4,4,6,6
			If numshots = 3 Then shottimer = 10
			If numshots = 4 Then shottimer = 8
			If jdfx <> 0 Or jdfy <> 0
				Local xr#
				Local yr#
				speed# = Sqr(jdfx*jdfx+jdfy*jdfy)
				jdfx = jdfx/speed
				jdfy = jdfy/speed
				'Local dir2# = ATan2(jdfy,jdfx)
				If numshots = 1
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					'TFormR(0,0,0, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
				EndIf
				If numshots = 2
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,12, xr ,yr )
					shot.create(px+25*xr,py+25*yr,xr,yr,shotspeed*2)
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,-12, xr ,yr )
					shot.create(px+25*xr,py+25*yr,xr,yr,shotspeed*2)
				EndIf
				If numshots = 3
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,3, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
					xr# = jdfx*shotspeed*2.05
					yr# = jdfy*shotspeed*2.05
					TFormR(0,0,2.5, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2.05)
					xr# = jdfx*shotspeed*2.05
					yr# = jdfy*shotspeed*2.05
					TFormR(0,0,0, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2.05)
					xr# = jdfx*shotspeed*2.05
					yr# = jdfy*shotspeed*2.05
					TFormR(0,0,-2.5, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2.05)
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,-3, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
				EndIf
				If numshots = 4
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,-2, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
					xr# = jdfx*shotspeed*2.25
					yr# = jdfy*shotspeed*2.25
'					TFormR(0,0,0, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2.25)
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,2, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
				EndIf
				If shot_back > 0
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,-180, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
				EndIf
				If shot_side > 0
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,90, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
					xr# = jdfx*shotspeed*2
					yr# = jdfy*shotspeed*2
					TFormR(0,0,-90, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*2)
				EndIf
				PlaySound2(shot_born_snd)
				'evil
			EndIf
		Else
			shottimer = 4 + numshots/2
			If jdfx <> 0 Or jdfy <> 0
				Local xr#
				Local yr#
				speed# = Sqr(jdfx*jdfx+jdfy*jdfy)
				jdfx = jdfx/speed
				jdfy = jdfy/speed
				If numshots Mod 2 = 1
					xr# = jdfx*shotspeed*3.2
					yr# = jdfy*shotspeed*3.2
					TFormR(0,0,0, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3.2)
				EndIf
				If numshots > 1
					If numshots Mod 2 = 0 Then r = 2 Else r = 4
					xr# = jdfx*shotspeed*3.15
					yr# = jdfy*shotspeed*3.15
					TFormR(0,0,r, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3.15)
					xr# = jdfx*shotspeed*3.15
					yr# = jdfy*shotspeed*3.15
					TFormR(0,0,-r, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3.15)
				EndIf
				If numshots > 3
					If numshots=4 Then r = 5 Else r = 5
					xr# = jdfx*shotspeed*3.1
					yr# = jdfy*shotspeed*3.1
					TFormR(0,0,r, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3.1)
					xr# = jdfx*shotspeed*3.1
					yr# = jdfy*shotspeed*3.1
					TFormR(0,0,-r, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3.1)
				EndIf
				If shot_back > 0
					xr# = jdfx*shotspeed*3
					yr# = jdfy*shotspeed*3
					TFormR(0,0,-180, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3)
				EndIf
				If shot_side > 0
					xr# = jdfx*shotspeed*3
					yr# = jdfy*shotspeed*3
					TFormR(0,0,90, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3)
					xr# = jdfx*shotspeed*3
					yr# = jdfy*shotspeed*3
					TFormR(0,0,-90, xr ,yr )
					shot.create(px,py,xr,yr,shotspeed*3)
				EndIf
				PlaySound2(shot_born_snd)
			EndIf
		EndIf
	EndIf

	' check triangle bond lines
	Local ll:le
	For ll:le = EachIn le_list
		If ll.attached = True
			If ll.checked = False
				ll.checked = True
				If ll.le2 <> Null
					ll.le2.checked = True
				EndIf
				If linecollide2(ll.x,ll.y,ll.le2.x,ll.le2.y,px,py,12)
					Killplayer()
					Exit
				EndIf
			EndIf
		EndIf
	Next

	' sucked into blackholes
	Local n5:nme5
	For n5:nme5 = EachIn nme5_list
		Local ddx# = n5.x-px
		Local ddy# = n5.y-py
		Local dist# = Sqr(ddx*ddx + ddy*ddy)
		If dist < n5.sz*10  'effect from 4*10 upto 64*10
			ddx# = ddx/dist/30*n5.sz ' pull from 0 to 2.5
			ddy# = ddy/dist/30*n5.sz ' pull from 0 to 2.5
			px = px + ddx
			py = py + ddy
		EndIf
	Next

End Function


Function BlackholeParticles()
	Local st:Int = gcount Mod 2
	Local spin# = 3
	If st = 0 Then spin = -3
	Local p:part
	Local t:Int
	Local n5:nme5
	For n5:nme5 = EachIn nme5_list
		If n5.active
			For t = st To numparticles-1 Step 2
				p:part = partarray[t]
				If p.active > 0
					Local ddx# = n5.x-p.x
					Local ddy# = n5.y-p.y
					Local dist# = Sqr(ddx * ddx + ddy * ddy)
					If dist < n5.sz * 8 And dist > 8
						'towards the gcenter
						If dist < n5.sz / 4
							ddx# = - ddx / dist
							ddy# = - ddy / dist
							p.dx = p.dx + ddx / 2'.75
							p.dy = p.dy + ddy / 2'.75
							p.dx = p.dx + ddy / spin'.75' / dist/4
							p.dy = p.dy - ddx / spin'.75' / dist/4
						Else
							p.active:+ 3
							ddx# = ddx / dist
							ddy# = ddy / dist
							p.dx = p.dx + ddx / 2'.75
							p.dy = p.dy + ddy / 2'.75
							p.dx = p.dx - ddy / spin'.75' / dist/4
							p.dy = p.dy + ddx / spin'.75' / dist/4
						EndIf
						Local speed# = (p.dx*p.dx+ p.dy*p.dy)
						If speed > 12*12
							Local sproot# = Sqr(speed)
							p.dx = p.dx/sproot
							p.dy = p.dy/sproot
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	Next

End Function



Function UpdateAll(cnt:Int = 0)

	Local n:nme
	Local n1:nme1
	Local n2:nme2
	Local n3:nme3
	Local n4:nme4
	Local n5:nme5
	Local n6:nme6
	Local n7:nme7
	Local n8:nme8
	Local g:ge
	Local ll:le
	Local s:shot
	Local pow:pu

	If gravityparticles Then BlackholeParticles()

	CycleColours()
	CycleColours()

	score.UpdatePoints()

	trail.UpdateTrail()

	gridpoint.UpdateGrid()

	If cnt = 0
		part.UpdateParticles()
	Else
		If cnt Mod 2 = 0
			part.UpdateParticles()
		EndIf
	EndIf

	If Not dying
		'generators
		For g:ge = EachIn ge_list
			g.Update()
		Next
		'green squares
		For n:nme = EachIn nme_list
			n.Update()
		Next
		'pink pinwheel
		For n1:nme1 = EachIn nme1_list
			n1.Update()
		Next
		'cyan diamonds
		For n2:nme2 = EachIn nme2_list
			n2.Update()
		Next
		'purple cubes
		For n3:nme3 = EachIn nme3_list
			n3.Update()
		Next
		'blue circles
		For n4:nme4 = EachIn nme4_list
			n4.Update()
		Next
		' purple snakes
		For n6:nme6 = EachIn nme6_list
			n6.Update()
		Next
		' red clone
		For n7:nme7 = EachIn nme7_list
			n7.Update()
		Next
		' blue butterfly
		For n8:nme8 = EachIn nme8_list
			n8.Update()
		Next
		'orange triangles
		For ll:le = EachIn le_list
			ll.Update()
		Next
		'powerups
		For pow:pu = EachIn pu_list
			pow.Update()
		Next
		'red circles
		For n5:nme5 = EachIn nme5_list
			n5.Update()
		Next
		'shots
		For s:shot = EachIn SHOT_list
			s.Update()
		Next
	EndIf

End Function


Function DrawMessage()
	'DrawString(powerupscore, 10,30,3)
	If messtime > 0
		messtime:-1
		If messtime = 90
			mess$ = "Power Up at "+ powerupscore
			mlen = Len(mess$)
		EndIf
		SetColor messtime,255-90+messtime/2,messtime
		DrawString(mess$, SCREENW/2-mlen*7,SCREENH-26,2.8)
	EndIf
End Function


Function Drawall()
'If KeyDown(KEY_TAB) Then End
'If KeyDown(KEY_F8) Then Return

	'Local p:part
	Local n:nme
	Local n1:nme1
	Local n2:nme2
	Local n3:nme3
	Local n4:nme4
	Local n5:nme5
	Local n6:nme6
	Local n7:nme7
	Local n8:nme8
	Local g:ge
	Local ll:le
	Local pow:pu
	Local t:Int

	gridpoint.DrawGrid(g_style)

	SetOrigin 0,0

	DrawStars()

	score.DrawPoints()

	SetViewport 0,0,SCREENW,SCREENH
	SetScale 1,1
	SetAlpha 1

	trail.DrawTrail()

	part.DrawParticles()

	SetLineWidth 2

	For g:ge = EachIn ge_list
		g.Draw()
	Next

	'green squares
	SetColor COL_SQUARE_R,COL_SQUARE_G,COL_SQUARE_B
	For n:nme = EachIn nme_list
		n.Draw()
	Next

	'pink pinwheel
	SetColor COL_PIN_R,COL_PIN_G,COL_PIN_B
	For n1:nme1 = EachIn nme1_list
		n1.Draw()
	Next

	'cyan diamonds
	SetColor COL_DIAMOND_R,COL_DIAMOND_G,COL_DIAMOND_B
	For n2:nme2 = EachIn nme2_list
		n2.Draw()
	Next

	'purple cubes
	SetColor COL_CUBE_R,COL_CUBE_G,COL_CUBE_B
	For n3:nme3 = EachIn nme3_list
		n3.Draw()
	Next

	'blue circles
	SetColor COL_SEEKER_R,COL_SEEKER_G,COL_SEEKER_B
	For n4:nme4 = EachIn nme4_list
		n4.Draw()
	Next

	'red circles
	SetColor COL_SUN_R,COL_SUN_G,COL_SUN_B
	For n5:nme5 = EachIn nme5_list
		n5.Draw()
	Next

	'snake
	For n6:nme6 = EachIn nme6_list
		n6.Draw()
	Next

	'red clone
	SetColor COL_CLONE_R,COL_CLONE_G,COL_CLONE_B
	For n7:nme7 = EachIn nme7_list
		n7.Draw()
	Next

	'blue butterflies
	SetColor COL_BUTTER_R,COL_BUTTER_G,COL_BUTTER_B
	For n8:nme8 = EachIn nme8_list
		n8.Draw()
	Next

	'orange triangles
	SetColor COL_TRIANGLE_R,COL_TRIANGLE_G,COL_TRIANGLE_B
	For ll:le = EachIn le_list
		ll.Draw()
	Next

	' bonds (orange to green)
	For ll:le = EachIn le_list
		ll.DrawBond()
	Next

	'powerups
	For pow:pu = EachIn pu_list
		pow.Draw()
	Next

	SetScale 1,1
	SetLineWidth 2


	' draw player & men left yellow
	If py < 80
		SetAlpha .5+Float(py)/400.0
	Else
		SetAlpha .80
	EndIf
	If numplayers > 1
		SetColor 255,255,255
		DrawImage iconimage,SCREENW/2-16,19,0
		SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
		If numplayers > 2 Then drawstring(numplayers-1,SCREENW/2-48,10,3)
	EndIf
	If numbombs > 0
		SetColor 255,255,255
		DrawImage iconimage,SCREENW/2+16,19,1
		SetColor COL_PLAYER_R,COL_PLAYER_G,COL_PLAYER_B
		If numbombs > 1 Then drawstring(numbombs,SCREENW/2+32,10,3)
	EndIf

	score.DrawScore()

	If py > SCREENH-80
		SetAlpha 1-Float(py-(SCREENH-80))/400.0
	Else
		SetAlpha .80
	EndIf
	drawmessage()

	If Not dying
		DrawPlayer(px,py,pr)
		' draw shots
		shot.DrawAllShots()
	EndIf

	SetScale 1,1
	SetAlpha 1

	' draw border
	SetColor g_red,g_green,g_blue
	SetLineWidth 2.0
	DrawLine -gxoff,-gyoff,PLAYFIELDW-1-gxoff,-gyoff
	DrawLine -gxoff,-gyoff,-gxoff,PLAYFIELDH-1-gyoff
	DrawLine -gxoff,PLAYFIELDH-1-gyoff,PLAYFIELDW-1-gxoff,PLAYFIELDH-1-gyoff
	DrawLine PLAYFIELDW-1-gxoff,PLAYFIELDH-1-gyoff,PLAYFIELDW-1-gxoff,-gyoff


End Function




Function DrawPlayer(x:Int,y:Int,r:Int)

	Local sc#
	If player_shield > 60 Or ((player_shield) Mod 15 > 7)
		SetAlpha 0.48
		sc = 2.75 + Float(player_shield)/128
		SetScale sc,sc
		SetColor rcol,gcol,bcol
		SetOrigin px-gxoff,py-gyoff
		SetBlend ALPHABLEND
		DrawPoly circ
'	Else
'		SetAlpha 0.1
'		sc = .5
'		SetScale sc,sc
	EndIf
	SetOrigin 0,0
	SetScale 1,1
	SetAlpha 1
	SetBlend LIGHTBLEND
	SetColor 255,255,255
	SetRotation r
	DrawImage whiteplayer,x-gxoff,y-gyoff
	SetRotation 0

End Function




Function SafeXY(x# Var,y# Var, plx:Int,ply:Int,range:Int, close:Int = 0)

	Local dx#,dy#,dist#

	If x < 20 Then x = 20
	If y < 20 Then y = 20
	If x > PLAYFIELDW-20 Then x = PLAYFIELDW-20
	If y > PLAYFIELDH-20 Then y = PLAYFIELDH-20

	If 	close = 1
		dx# = plx-x
		dy# = ply-y
		dist# = Sqr(dx*dx + dy*dy) + 0.001
		While dist < range
			x = x - dx/dist*10
			y = y - dy/dist*10
			dx = plx-x
			dy = ply-y
			dist = Sqr(dx*dx + dy*dy)
			If dist < 0.001
				x = plx + Rand(10,20)*(1-2*Rand(10)>5)
				y = ply + Rand(10,20)*(1-2*Rand(10)>5)
				dx = plx-x
				dy = ply-y
				dist = Sqr(dx*dx + dy*dy)
			EndIf
		Wend
	Else
		dx# = plx-x
		dy# = ply-y
		dist# = (dx*dx + dy*dy)
		While dist < range*range
			Local dir# = Rand(0,360*8)/8.0
			x = plx + Sin(dir)*range
			y = ply + Cos(dir)*range
			If x < 20 Then x = 20
			If y < 20 Then y = 20
			If x > PLAYFIELDW-20 Then x = PLAYFIELDW-20
			If y > PLAYFIELDH-20 Then y = PLAYFIELDH-20
			dx = plx-x
			dy = ply-y
			dist = (dx*dx + dy*dy)
		Wend
	EndIf
End Function








