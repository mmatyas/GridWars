Strict

Import BRL.RandomDefault
Import BRL.FileSystem
Import "colordefs.bmx"
Import "utils.bmx"
Import "images.bmx"

Global debug:Int = 0
Global moiAkt:Float=0.0,moiAkt2:Float=0.0
Global numgridstyles:Int = 20

Global windowed:Int = False
Global MAXPARTICLES:Int = 50000
Global MAXPARTICLELIFE:Int = 80
Global numparticles:Int = 2048
Global particlelife:Int = 40
Global gravityparticles:Int = 1
Global particledecay# = .95
Global particlestyle:Int = 0
Global numparticlestyles:Int = 3  '0,1,2,3

Global g_red:Int = 32
Global g_green:Int = 80
Global g_blue:Int = 200
Global g_opacity# = 0.85
Global fullgrid:Int = True
Global showstars:Int = 300
Global MAXSTARS:Int = 10000

Global slotcount:Int '0 to numparticles-1
Global partarray:part[]
partarray = New part[MAXPARTICLES+1]

Global starx:Int[MAXSTARS+1]
Global stary:Int[MAXSTARS+1]
Global stard#[MAXSTARS+1]

Global part_LIST:TList = New TList
Global trail_LIST:TList = New TList

Global gwlow:Int
Global gwhi:Int
Global ghlow:Int
Global ghhi:Int
Global gxoff:Int
Global gyoff:Int

Global scroll:Int = False

Global screensize:Int = 0
Global screensizew:Int = 1024
Global screensizeh:Int = 768
Global playsize:Int = 0
Global playsizew:Int = 1024
Global playsizeh:Int = 768

Global gridsize:Int = 2

Global SCREENW:Int = 1024
Global SCREENH:Int = 768
Global PLAYFIELDW:Int = 1024 '1280  '2^8*5
Global PLAYFIELDH:Int = 768 '1024  '2^8*2*2
Global GRIDWIDTH:Int = 16   '4,5,8,10,16,20,32,40,64
Global GRIDHEIGHT:Int = 16  '4,8,16,32,64,128,256

Const GRIDHILIGHT:Int = 4

Global NUMGPOINTSW:Int = PLAYFIELDW/GRIDWIDTH
Global NUMGPOINTSH:Int = PLAYFIELDH/GRIDHEIGHT

Global grid:gridpoint[,]
grid = New gridpoint[5120/4+2, 4096/4+2] ' maximum size

Local a:Int,b:Int
For a = 0 To 1920/4
	For b = 0 To 1200/4
		grid[a,b] = New gridpoint
	Next
Next

Type gfxmode
	Field w:Int
	Field h:Int
	Field desc$
	Field s$
End Type
Global gfxmodearr:gfxmode[]
gfxmodearr = New gfxmode[100]
Global numgfxmodes:Int = 0

Global playfieldsizes[] = ..
[..
1024,768,..
512,384,..
640,480,..
720,400,..
720,480,..
720,576,..
800,600,..
1024,720,..
1024,768,..
1152,864,..
1152,870,..
1280,720,..
1280,768,..
1280,800,..
1280,854,..
1280,960,..
1280,1024,..
1440,900,..
1400,1050,..
1600,1024,..
1600,1200,..
1600,1280,..
1680,1050,..
1800,1440,..
1920,1080,..
1920,1200,..
2048,768,..
2048,1536,..
2560,1024,..
2560,1600,..
2560,2048,..
3200,2048,..
3200,2400,..
3840,2400,..
5120,4096..
]
Global numplayfieldsizes:Int = 34   '0-33

DefData "USER",   1024, 768
DefData "BWMac",  512,  384
DefData "VGA",    640,  480
DefData "????",   720,  400
DefData "NTSCDVD",720,  480
DefData "PALDVD", 720,  576
DefData "SVGA",   800,  600
DefData "XGA-",   1024, 720
DefData "XGA",    1024, 768
DefData "XGA+",   1152, 864
DefData "XGA++",  1152, 870
DefData "720p",   1280, 720
DefData "WXGA",   1280, 768
DefData "WXGA+" , 1280, 800
DefData "WXGA++" , 1280, 854
DefData "WXGA+++", 1280, 960
DefData "SXGA",   1280, 1024
DefData "WSXGA",  1440, 900
DefData "SXGA+",  1400, 1050
DefData "WSXGA",  1600, 1024
DefData "UXGA",   1600, 1200
DefData "UXGA+",  1600, 1280
DefData "WSXGA+", 1680, 1050
DefData "?????",  1800, 1440
DefData "1080p",  1920, 1080
DefData "WUXGA",  1920, 1200
DefData "DUALW",  2048, 768
DefData "QXGA",   2048, 1536
DefData "DUALW+", 2560, 1024
DefData "WQXGA",  2560, 1600
DefData "QSXGA",  2560, 2048
DefData "WQSXGA", 3200, 2048
DefData "QUXGA",  3200, 2400
DefData "WQUXGA", 3840, 2400
DefData "HSXGA",  5120, 4096
numgfxmodes:Int = 34  ' 0-33


Function GetGfxModes()
	Local desc$,w:Int,h:Int

	For Local cnt:Int = 0 To numgfxmodes
		Local g:gfxmode = New gfxmode
		ReadData desc$,w,h
		g.w = w
		g.h = h
		g.desc$ = desc$
		g.s$ = g.w+"X"+g.h
		gfxmodearr[cnt] = g
	Next
	' set first entry to what the user has in config
	gfxmodearr[0].w = screensizew
	gfxmodearr[0].h = screensizeh

End Function




Function FindSetting()

	screensize = 0 ' pick first one
	playsize = 0 ' use the defaul/file settings
	playfieldsizes[0] = playsizew
	playfieldsizes[1] = playsizeh

	For Local t = 0 To numgfxmodes
		' or find the one that matches file
		If gfxmodearr[t].w = screensizew And gfxmodearr[t].h = screensizeh
			screensize = t
		EndIf
	Next

End Function


Function SetDimensions()

	SCREENW = gfxmodearr[screensize].w
	SCREENH = gfxmodearr[screensize].h

	PLAYFIELDW = playfieldsizes[playsize*2]
	PLAYFIELDH = playfieldsizes[playsize*2+1]

	screensizew = gfxmodearr[screensize].w
	screensizeh = gfxmodearr[screensize].h

	playsizew = PLAYFIELDW
	playsizeh = PLAYFIELDH

End Function


Function SetUp:Int()

	Local ret:Int = True

	SetDimensions()

	If windowed
		If GraphicsModeExists( SCREENW,SCREENH )
			Graphics(SCREENW, SCREENH, 0)
		Else
			Local fh:TStream = WriteFile("errors.txt")
			WriteLine(fh,"Can not set graphics mode: Windowed - "+SCREENW+"X"+SCREENH)
			CloseFile fh
			ret = False
		EndIf
	Else
		Local sucess:Int = False
		For Local dep:Int = 32 To 16 Step -8
			If GraphicsModeExists( SCREENW,SCREENH,dep)
				Graphics(SCREENW, SCREENH, dep, 60)
				sucess = True
				Exit
			EndIf
		Next
		If Not sucess
			Local fh:TStream = WriteFile("errors.txt")
			WriteLine(fh,"Could not set graphics mode: Fullscreen - "+SCREENW+"X"+SCREENH)
			CloseFile fh
			ret = False
		EndIf
	EndIf

	If ret = True
		Select gridsize
			Case 0
				GRIDWIDTH = 4
				GRIDHEIGHT = 4
			Case 1
				GRIDWIDTH = 8
				GRIDHEIGHT = 8
			Case 2
				GRIDWIDTH = 16
				GRIDHEIGHT = 16
			Case 3
				GRIDWIDTH = 32
				GRIDHEIGHT = 32
		End Select

		NUMGPOINTSW = PLAYFIELDW/GRIDWIDTH
		NUMGPOINTSH = PLAYFIELDH/GRIDHEIGHT
		gridpoint.ResetAll()

		LoadImages()
		If PLAYFIELDW > SCREENW Or PLAYFIELDH > SCREENH Then scroll = True
'		If PLAYFIELDW <= SCREENW And PLAYFIELDH <= SCREENH Then scroll = False
		gxoff = 0
		gyoff = 0

		capturedimg:TImage = CreateImage(SCREENW,SCREENH)
		SetLineWidth 2
?not opengles
		glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST
?

		CreateStars()
	EndIf

	Return ret

End Function


'the background dots
Type gridpoint

	Field ox#,oy#
	Field x#
	Field y#
	Field dx#,dy#
'	Field fx#,fy#

	Method Update(xx#,yy#)

		If Abs(xx-x) > 2 Then dx:+ Sgn(xx-x)
		If Abs(yy-y) > 2 Then dy:+ Sgn(yy-y)

		If Abs(ox-x) > 1
			x = x + Sgn(ox-x)
			dx:+ Sgn(ox-x)/2
		Else
			x = ox
		EndIf
		If Abs(oy-y) > 1
			y = y + Sgn(oy-y)
			dy:+ Sgn(oy-y)/2
		Else
			y = oy
		EndIf

		dx = dx *.899 '.89
		dy = dy *.899 '.89

		x = x + dx
		y = y + dy

	End Method


	Function ResetAll()
		Local a:Int,b:Int

		For a = 0 To NUMGPOINTSW
			For b = 0 To NUMGPOINTSH
				grid[a,b].ox = a*GRIDWIDTH
				grid[a,b].oy = b*GRIDHEIGHT
				grid[a,b].x = a*GRIDWIDTH
				grid[a,b].y = b*GRIDHEIGHT
				grid[a,b].dx = 0
				grid[a,b].dy = 0
			Next
		Next
	End Function

	Method disrupt(xx#,yy#)
			If Abs(xx) > 8 Then xx = xx/16
			If Abs(yy) > 8 Then yy = yy/16
			dx = dx + xx
			dy = dy + yy
			Local speed# = dx*dx+dy*dy
			If speed > 160 ' 128
				dx = dx/speed*128
				dy = dy/speed*128
			EndIf
'		EndIf
	End Method

	Function Pull(x1#,y1#, sz:Int = 4,amnt#=4)

		Local a:Int = x1/GRIDWIDTH
		Local b:Int = y1/GRIDHEIGHT
		For Local xx:Int = -sz To sz
			For Local yy:Int = -sz To sz
				If a+xx > 0
					If a+xx =< NUMGPOINTSW'-2
						If b+yy > 0
							If b+yy =< NUMGPOINTSH'-2
								If xx*xx + yy*yy < sz*sz
									Local diffx# = grid[a+xx,b+yy].x-x1
									Local diffy# = grid[a+xx,b+yy].y-y1
									Local dist# = Sqr(diffx*diffx+diffy*diffy)
									If dist > 0
'									grid[a+xx,b+yy].fx:- diffx*(1-(dist)/(sz*sz*4*256))
'									grid[a+xx,b+yy].fy:- diffy*(1-(dist)/(sz*sz*4*256))
									grid[a+xx,b+yy].dx:- diffx/dist*amnt  '*(1-(dist*dist)/(sz*sz*4*256))
									grid[a+xx,b+yy].dy:- diffy/dist*amnt  '*(1-(dist*dist)/(sz*sz*4*256))
'									grid[a+xx,b+yy].fx = - diffx/dist*(1-(dist*dist)/(sz*sz*4*256))
'									grid[a+xx,b+yy].fy = - diffy/dist*(1-(dist*dist)/(sz*sz*4*256))
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		Next

	End Function


	Function Push(x1#,y1#, sz:Int = 4,amnt#=1)

		Local a:Int = (x1/GRIDWIDTH)
		Local b:Int = (y1/GRIDHEIGHT)
		For Local xx:Int = -sz To sz
			For Local yy:Int = -sz To sz
			'	If (xx*xx + yy*yy) < sz*sz
				If a+xx > 0
					If a+xx =< NUMGPOINTSW '-2
						If b+yy > 0
							If b+yy =< NUMGPOINTSH'-2
								Local diffx# = grid[a+xx,b+yy].ox-x1
								Local diffy# = grid[a+xx,b+yy].oy-y1
								Local diffxo# = grid[a+xx,b+yy].ox-grid[a+xx,b+yy].x
								Local diffyo# = grid[a+xx,b+yy].oy-grid[a+xx,b+yy].y
								Local dist# = diffy*diffy+diffx*diffx
								Local disto# = diffyo*diffyo+diffxo*diffxo
								If dist > 1 And disto < 400
									If dist < 50*50
										grid[a+xx,b+yy].dx:+ diffx*amnt '/dist*amnt
										grid[a+xx,b+yy].dy:+ diffy*amnt '/dist*amnt
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				'EndIf
				EndIf
			Next
		Next

	End Function


	Function UpdateGrid()

		For Local a:Int = 1 To NUMGPOINTSW-1
			For Local b:Int = 1 To NUMGPOINTSH-1
				Local xx# = 0
				xx:+ grid[a-1,b].x
				xx:+ grid[a,b-1].x
				xx:+ grid[a,b+1].x
				xx:+ grid[a+1,b].x
				xx = xx / 4

				Local yy# = 0
				yy:+ grid[a-1,b].y
				yy:+ grid[a,b-1].y
				yy:+ grid[a,b+1].y
				yy:+ grid[a+1,b].y
				yy = yy / 4

				grid[a,b].update(xx,yy)

			Next
		Next
	End Function

	' evil!
	Function BombShockwave(x:Int,y:Int)
		Local a:Int = x/GRIDWIDTH
		Local b:Int = y/GRIDHEIGHT
		For Local xx:Int = -300 To 300
			For Local yy:Int = -300 To 300
				If xx*xx + yy*yy < 100000000
				If a+xx > 0
					If a+xx =< NUMGPOINTSW
						If b+yy > 0
							If b+yy =< NUMGPOINTSH
								grid[a+xx,b+yy].disrupt(.6*(grid[a+xx,b+yy].x-x),.6*(grid[a+xx,b+yy].y-y))
							EndIf
						EndIf
					EndIf
				EndIf
				EndIf
			Next
		Next
	End Function
	' /evil

	Function Shockwave(x:Int,y:Int)
		Local a:Int = x/GRIDWIDTH
		Local b:Int = y/GRIDHEIGHT
		For Local xx:Int = -3 To 3
			For Local yy:Int = -3 To 3
				If xx*xx + yy*yy < 10
				If a+xx > 0
					If a+xx =< NUMGPOINTSW'-1
						If b+yy > 0
							If b + yy =< NUMGPOINTSH'-1
								grid[a+xx,b+yy].disrupt(4*(grid[a+xx,b+yy].x-x),4*(grid[a+xx,b+yy].y-y))
							EndIf
						EndIf
					EndIf
				EndIf
				EndIf
			Next
		Next
	End Function

Function DrawGrid(style:Int,small:Int = False)

		If fullgrid
		        gwlow = 0
		        gwhi = NUMGPOINTSW
		        ghlow = 0
		        ghhi = NUMGPOINTSH
		Else
		        gwlow = Max(gxoff/GRIDWIDTH,0)
		        gwhi = Min(gwlow+(SCREENW/GRIDWIDTH)+GRIDHILIGHT,NUMGPOINTSW)
		        ghlow = Max(gyoff/GRIDHEIGHT,0)
		        ghhi = Min(ghlow+(SCREENH/GRIDHEIGHT)+GRIDHILIGHT,NUMGPOINTSH)
		EndIf
		If small
				 gxoff = -SCREENW/8
				 gyoff = -SCREENH/8
		        gwlow = 0
		        gwhi = -gxoff/GRIDWIDTH*6
		        ghlow = 0
		        ghhi = -gyoff/GRIDHEIGHT*6
		EndIf
		Select style
			Case 0
			        ' points, 1 colour
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridPoints()
			Case 1
			        ' points, rainbow
			        SetAlpha Abs(g_opacity)
			        SetColor rcol,gcol,bcol  'cycled colours
			        SetBlend LIGHTBLEND
			        DrawGridPoints()

			Case 2
			        ' points(bigger), solid
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridPointsC(g_opacity)
			Case 3
			        ' points(bigger), rainbow
			        SetAlpha Abs(g_opacity)
			        SetColor rcol,gcol,bcol  'cycled colours
			        SetBlend LIGHTBLEND
			        DrawGridPointsC(g_opacity)

			Case 4
			        ' Lines, solid
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines()
			Case 5
			        ' Lines, rainbow
			        SetAlpha Abs(g_opacity)
			        SetColor rcol,gcol,bcol  'cycled colours
			        SetBlend LIGHTBLEND
			        DrawGridLines()

			Case 6
			        ' line quads, solid
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines3(g_opacity)
			Case 7
			        ' line quads, rainbow
			        SetAlpha Abs(g_opacity)
			        SetColor rcol,gcol,bcol  'cycled colours
			        SetBlend LIGHTBLEND
			        DrawGridLines3(g_opacity)

			Case 8
					' dense mesh - solid
					SetAlpha Abs(g_opacity)
					SetColor g_red,g_green,g_blue
					SetBlend LIGHTBLEND
					DrawGridLines7b()
			Case 9
					' dense mesh - blue
					SetAlpha Abs(g_opacity)
					SetColor rcol,gcol,bcol
					SetBlend LIGHTBLEND
					DrawGridLines7()


			Case 10
			        ' draw lines [original,blue,stretch]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines6()
			Case 11
			        ' draw lines [grid,blue,stretch]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines4()
			Case 12
			        ' draw lines [diagonal,raspberry,stretch]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines5()
			Case 13
					' draw line_strip [rgb-split]
					SetAlpha Abs(g_opacity)
					SetColor g_red,g_green,g_blue
					SetBlend LIGHTBLEND
					DrawGridLines3c()


			Case 14
			        ' solid quads, 1 colour
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines2b()
			Case 15
			        ' solid quads, rainbow
			        SetAlpha Abs(g_opacity)
			        SetColor rcol,gcol,bcol  'cycled colours
			        SetBlend LIGHTBLEND
			        DrawGridLines2b()
			Case 16
			        ' solid quads [blue,stretch]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines2()
			Case 17
			        ' solid quads [sin colour]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines2c()
			Case 18
			        ' draw triangles [moire]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines8()
			Case 19
			        ' draw line_strip [vcs like]
			        SetAlpha Abs(g_opacity)
			        SetColor g_red,g_green,g_blue
			        SetBlend LIGHTBLEND
			        DrawGridLines3b()
			Case 20
			        'no grid
		End Select

		SetScale 1,1
		SetAlpha 1
		SetLineWidth 2

	End Function

	Function DrawGridPoints()
               Local a:Int,b:Int
               Local boldw:Int
               Local boldh:Int

               boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
               boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

               SetScale 1,1
               SetLineWidth 1
               For a = gwlow To gwhi-1
                       For b = ghlow To ghhi-1
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,2,2
                       Next
               Next
               SetLineWidth 2
               For a = gwlow+boldw To gwhi-1 Step GRIDHILIGHT
                       For b = ghlow To ghhi-1
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,3,3
                       Next
               Next
               For a = gwlow To gwhi-1
                       For b = ghlow+boldh To ghhi-1 Step GRIDHILIGHT
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,3,3
                       Next
               Next
       End Function


       Function DrawGridPointsb()
               Local a:Int,b:Int
               Local boldw:Int
               Local boldh:Int

               boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
               boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

               SetScale 1,1
               SetLineWidth 2

               For a = gwlow+1 To gwhi-1
                       For b = ghlow+1 To ghhi-1
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,2,2
                       Next
               Next
               For a = gwlow+boldw+1 To gwhi-1 Step GRIDHILIGHT
                       For b = ghlow+1 To ghhi-1
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,4,4
                       Next
               Next
               For a = gwlow+1 To gwhi-1
                       For b = ghlow+boldh+1 To ghhi-1 Step GRIDHILIGHT
                               DrawRect grid[a,b].x-gxoff, grid[a,b].y-gyoff,4,4
                       Next
               Next
 End Function

	Function DrawGridPointsC(alpha#)
		Local a:Int,b:Int
		Local boldw:Int
		Local boldh:Int

		boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
		boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

		SetScale 1.5,1.5
		For a = gwlow + 1 To gwhi - 1
			For b = ghlow + 1 To ghhi - 1
				Local alp# = alpha
				If (b+boldh) Mod GRIDHILIGHT = 0
					alp:+ .25
				EndIf
				If (a+boldw) Mod GRIDHILIGHT = 0
					alp:+ .25
				EndIf
				SetAlpha alp
				DrawImage particleimg, grid[a , b].x - gxoff , grid[a , b].y - gyoff
			Next
		Next
		SetScale 1 , 1

	End Function

       Function DrawGridLines()
               Local a:Int,b:Int
               Local boldw:Int
               Local boldh:Int

               boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
               boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

               SetScale 1,1
               SetLineWidth 2
               SetAlpha .9
               For a = gwlow+boldw To gwhi-GRIDHILIGHT Step GRIDHILIGHT
                       'DrawLine grid[a,b].x-gxoff, grid[a,b].y-gyoff, grid[a,b+GRIDHILIGHT].x-gxoff, grid[a,b+GRIDHILIGHT].y-gyoff
?not opengles
                       glBegin GL_LINE_STRIP
                       For b = ghlow+boldh-GRIDHILIGHT To ghhi-GRIDHILIGHT Step GRIDHILIGHT
                               glVertex3f(grid[a,b].x-gxoff, grid[a,b].y-gyoff,     0)
                               glVertex3f(grid[a,b+GRIDHILIGHT].x-gxoff,   grid[a,b+GRIDHILIGHT].y-gyoff,   0)
                       Next
                       glEnd
?
               Next
               For b = ghlow+boldh To ghhi-GRIDHILIGHT Step GRIDHILIGHT
                       '       DrawLine grid[a,b].x-gxoff, grid[a,b].y-gyoff, grid[a+GRIDHILIGHT,b].x-gxoff, grid[a+GRIDHILIGHT,b].y-gyoff
?not opengles
                       glBegin GL_LINE_STRIP
                       For a = gwlow+boldw-GRIDHILIGHT To gwhi-GRIDHILIGHT Step GRIDHILIGHT
                               glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
                               glVertex3f(grid[a+GRIDHILIGHT,b].x-gxoff,   grid[a+GRIDHILIGHT,b].y-gyoff,   0)
                       Next
                       glEnd
?
               Next
       End Function


       Function DrawGridLines2()
               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               SetLineWidth 1
               Local boldw:Int
               Local boldh:Int

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local i:Int=0,delX:Float=0.0,delY:Float=0.0
               Local xy#[8]
               'colAkt=(colAkt+.05) Mod 360.0

               For a = gwlow+boldw-2 To gwhi-1 Step 1
                       For b = ghlow+boldh-2+(a Mod 2) To ghhi-1 Step 2
                               xy[0] = grid[a,b].x-gxoff
                               xy[1] = grid[a,b].y-gyoff

                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff

                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               xy[6] = grid[a,b+1].x-gxoff
                               xy[7] = grid[a,b+1].y-gyoff

                               'colA=50+50*Sin((colAkt*360*a/gwhi*b/ghhi) Mod 360.0)

                               delX=xy[4]-xy[0]-16;delY=xy[5]-xy[1]-16
                               If delX<delY Then delX=delY
                               If delX<0.0 Then delX=0.0
                               If delX>90.0 Then delX=90.0
                               Local colB#=Sin(delX)
                               SetColor(20+235*colB,20+100*colB,180-140*colB)
                               'SetAlpha((1-colB)*.7+0.3)
                               'SetAlpha((1-colB)*.7+0.3-colA/360.0)

                               DrawPoly(xy)
                       Next
               Next

       End Function


       Function DrawGridLines2b()
               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               SetLineWidth 1
               Local boldw:Int
               Local boldh:Int

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local xy#[8]

               For a = gwlow+boldw-2 To gwhi-1 Step 1
                       For b = ghlow+boldh-2+(a Mod 2) To ghhi-1 Step 2
                               xy[0] = grid[a,b].x-gxoff
                               xy[1] = grid[a,b].y-gyoff

                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff

                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               xy[6] = grid[a,b+1].x-gxoff
                               xy[7] = grid[a,b+1].y-gyoff
                               DrawPoly(xy)
                       Next
               Next
       End Function


       Function DrawGridLines2c()
               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               SetLineWidth 1
               Local boldw:Int
               Local boldh:Int

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local xy#[8]
               Local i:Int=0,j:Int=0

               For a = gwlow+boldw-2 To gwhi-1 Step 1
                       j:+1
                       For b = ghlow+boldh-2+(a Mod 2) To ghhi-1 Step 2
                               i:+2
                               xy[0] = grid[a,b].x-gxoff
                               xy[1] = grid[a,b].y-gyoff
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff
                               xy[6] = grid[a,b+1].x-gxoff
                               xy[7] = grid[a,b+1].y-gyoff
                               SetAlpha(g_opacity-.25*(Sin(gcol+i)+Cos(j)))
                               DrawPoly(xy)
                       Next
               Next
       End Function


	Function DrawGridLines3(alpha#)
		Local a:Int,b:Int
		Local boldw:Int
		Local boldh:Int

		boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
		boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

		SetScale 1,1
		SetLineWidth 1
?not opengles
		For a = gwlow To gwhi - 1
			If (a+boldh) Mod GRIDHILIGHT = 0
				SetAlpha alpha+.25
			Else
				SetAlpha alpha
			EndIf
			glBegin GL_LINE_STRIP
			For b = ghlow To ghhi-1
				glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
				glVertex3f(grid[a,b+1].x-gxoff,   grid[a,b+1].y-gyoff,   0)
			Next
			glEnd
		Next
		For b = ghlow To ghhi - 1
			If (b+boldw) Mod GRIDHILIGHT = 0
				SetAlpha alpha+.25
			Else
				SetAlpha alpha
			EndIf
			glBegin GL_LINE_STRIP
			For a = gwlow To gwhi-1
				glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
				glVertex3f(grid[a+1,b].x-gxoff,   grid[a+1,b].y-gyoff,   0)
			Next
			glEnd
		Next
'		SetLineWidth 2.0
'		For a = gwlow+boldw To gwhi-1 Step GRIDHILIGHT
'			glBegin GL_LINE_STRIP
'			For b = ghlow To ghhi-1 '-1
'				glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
'				glVertex3f(grid[a,b+1].x-gxoff,   grid[a,b+1].y-gyoff,   0)
'			Next
'			glEnd
'		Next
'		For b = ghlow+boldh To ghhi-1 Step GRIDHILIGHT
'			glBegin GL_LINE_STRIP
'			For a = gwlow To gwhi-1
'				glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
'			glVertex3f(grid[a+1,b].x-gxoff,   grid[a+1,b].y-gyoff,   0)
'			Next
'			glEnd
'		Next
?
	End Function

       Function DrawGridLines3b()
               Local a:Int,b:Int
               Local boldw:Int
               Local boldh:Int

               boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
               boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

?not opengles
               ' draw grid
               SetScale 1,1
               SetLineWidth 16'glLineWidth(i)
               For b = ghlow+1 To ghhi-1
'               SetAlpha(.46+Rnd(.04))
                       glBegin GL_LINE_STRIP
                       For a = gwlow To gwhi-1
                               glVertex3f(grid[a,b].x-gxoff,     grid[a,b].y-gyoff,     0)
                               glVertex3f(grid[a+1,b].x-gxoff,   grid[a+1,b].y-gyoff,   0)
                       Next
                       glEnd
               Next
?
       End Function


       Function DrawGridLines3c()
               Local a:Int,b:Int
               Local boldw:Int
               Local boldh:Int

               boldw = GRIDHILIGHT-(gwlow Mod GRIDHILIGHT)
               boldh = GRIDHILIGHT-(ghlow Mod GRIDHILIGHT)

               SetTransform 0,1,1'SetScale 1,1
               moiAkt2:+3
               If moiAkt2>=360 Then moiAkt2:-360

'red
               Local xmax:Int=gwhi-1,xmin:Int=gwlow+1
               Local ymax:Int=ghhi-1,ymin:Int=ghlow+1
               Local sinAkt:Float=0.0,sinDel:Float=6.0,sca:Float=0.0
               Local xdel:Float=16,ydel:Float=16
               Local xoff:Float=-4,yoff:Float=-4
               Local rgb:Float=.05,rgbMin:Float=.3,rgbAmp:Float=.2
               Local bor:Float=1.0
               Local anz:Int=ymax*.5-1,i:Int=0,x:Int=0,y:Int=0

?not opengles
               sinAkt=moiAkt2
               SetLineWidth 2'1.5'glLineWidth(2)
               glBegin GL_LINE_STRIP
               For i=0 To anz
                       'rechts
                       For x=xmin To xmax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(sca,rgb,rgb)
                               If Abs(grid[x,ymin].x-x*xdel)>bor Then
                                       glVertex2f(grid[x,ymin].x-gxoff+xoff,grid[x,ymin].y-gyoff+yoff)
                               Else
                                       glVertex2f(grid[x,ymin].x-gxoff,grid[x,ymin].y-gyoff)
                               End If
                       Next
                       ymin:+1
                       'runter
                       For y=ymin To ymax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(sca,rgb,rgb)
                               If Abs(grid[xmax,y].y-y*ydel)>bor Then
                                       glVertex2f(grid[xmax,y].x-gxoff+xoff,grid[xmax,y].y-gyoff+yoff)
                               Else
                                       glVertex2f(grid[xmax,y].x-gxoff,grid[xmax,y].y-gyoff)
                               End If
                       Next
                       'links
                       For x=xmax To xmin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(sca,rgb,rgb)
                               If Abs(grid[x,ymax].x-x*xdel)>bor  Then
                                       glVertex2f(grid[x,ymax].x-gxoff+xoff,grid[x,ymax].y-gyoff+yoff)
                               Else
                                       glVertex2f(grid[x,ymax].x-gxoff,grid[x,ymax].y-gyoff)
                               End If
                       Next
                       xmax:-1
                       ymax:-1
                       'hoch
                       For y=ymax To ymin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(sca,rgb,rgb)
                               If Abs(grid[xmin,y].y-y*ydel)>bor Then
                                       glVertex2f(grid[xmin,y].x-gxoff+xoff,grid[xmin,y].y-gyoff+yoff)
                               Else
                                       glVertex2f(grid[xmin,y].x-gxoff,grid[xmin,y].y-gyoff)
                               End If
                       Next
                       xmin:+1
               Next
               'rechts
               For x=xmin To xmax Step 1
                       sinAkt:+sinDel
                       If sinAkt>=360 Then sinAkt:-360
                       sca=rgbMin+rgbAmp*Sin(sinAkt)
                       glColor3f(sca,rgb,rgb)
                       If Abs(grid[x,ymin].x-x*xdel)>bor Then
                               glVertex2f(grid[x,ymin].x-gxoff+xoff,grid[x,ymin].y-gyoff+yoff)
                       Else
                               glVertex2f(grid[x,ymin].x-gxoff,grid[x,ymin].y-gyoff)
                       End If
               Next
               'ymin:+1
               glEnd
?

'green

?not opengles
               xmax=gwhi-1;xmin=gwlow+1
               ymax=ghhi-1;ymin=ghlow+1
               sinAkt=moiAkt2
               anz=ymax*.5-1;i=0;x=0;y=0

               SetLineWidth 2'1.5
               glBegin GL_LINE_STRIP
               For i=0 To anz
                       'rechts
                       For x=xmin To xmax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,sca,rgb)
                               glVertex2f(grid[x,ymin].x-gxoff,grid[x,ymin].y-gyoff)
                       Next
                       ymin:+1
                       'runter
                       For y=ymin To ymax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,sca,rgb)
                               glVertex2f(grid[xmax,y].x-gxoff,grid[xmax,y].y-gyoff)
                       Next
                       'links
                       For x=xmax To xmin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,sca,rgb)
                               glVertex2f(grid[x,ymax].x-gxoff,grid[x,ymax].y-gyoff)
                       Next
                       xmax:-1
                       ymax:-1
                       'hoch
                       For y=ymax To ymin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,sca,rgb)
                               glVertex2f(grid[xmin,y].x-gxoff,grid[xmin,y].y-gyoff)
                       Next
                       xmin:+1
               Next
               'rechts
               For x=xmin To xmax Step 1
                       sinAkt:+sinDel
                       If sinAkt>=360 Then sinAkt:-360
                       sca=rgbMin+rgbAmp*Sin(sinAkt)
                       glColor3f(rgb,sca,rgb)
                       glVertex2f(grid[x,ymin].x-gxoff,grid[x,ymin].y-gyoff)
               Next
               'ymin:+1
               glEnd
?

'blue

?not opengles
               xmax=gwhi-1;xmin=gwlow+1
               ymax=ghhi-1;ymin=ghlow+1
               sinAkt=moiAkt2
               xoff=0;yoff=0
               anz=ymax*.5-1;i=0;x=0;y=0

               SetLineWidth 2'1.5
               glBegin GL_LINE_STRIP
               For i=0 To anz
                       'rechts
                       For x=xmin To xmax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,rgb,sca)
                               glVertex2f(x*xdel-gxoff+xoff,ymin*ydel-gyoff)
                               'glVertex2f(grid[x,ymin].x-gxoff+xoff,grid[x,ymin].y-gyoff+yoff)
                       Next
                       ymin:+1
                       'runter
                       For y=ymin To ymax Step 1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,rgb,sca)
                               glVertex2f(xmax*xdel-gxoff,y*ydel-gyoff)
                               'glVertex2f(grid[xmax,y].x-gxoff+xoff,grid[xmax,y].y-gyoff+yoff)
                       Next
                       'links
                       For x=xmax To xmin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,rgb,sca)
                               glVertex2f(x*xdel-gxoff,ymax*ydel-gyoff)
                               'glVertex2f(grid[x,ymax].x-gxoff+xoff,grid[x,ymax].y-gyoff+yoff)
                       Next
                       xmax:-1
                       ymax:-1
                       'hoch
                       For y=ymax To ymin Step -1
                               sinAkt:+sinDel
                               If sinAkt>=360 Then sinAkt:-360
                               sca=rgbMin+rgbAmp*Sin(sinAkt)
                               glColor3f(rgb,rgb,sca)
                               glVertex2f(xmin*xdel-gxoff,y*ydel-gyoff)
                               'glVertex2f(grid[xmin,y].x-gxoff+xoff,grid[xmin,y].y-gyoff+yoff)
                       Next
                       xmin:+1
               Next
               'rechts
               For x=xmin To xmax Step 1
                       sinAkt:+sinDel
                       If sinAkt>=360 Then sinAkt:-360
                       sca=rgbMin+rgbAmp*Sin(sinAkt)
                       glColor3f(rgb,rgb,sca)
                       glVertex2f(x*xdel-gxoff,ymin*ydel-gyoff)
                       'glVertex2f(grid[x,ymin].x-gxoff+xoff,grid[x,ymin].y-gyoff+yoff)
               Next
               'ymin:+1
               glEnd
?
       End Function


       Function DrawGridLines4()
               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               Local boldw:Int
               Local boldh:Int
               Local colB:Float=0.0

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local delX:Float=0.0,delY:Float=0.0
               Local xy#[8]

               'glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST

               For a = gwlow+boldw-2 To gwhi-1 Step 1
                       For b = ghlow+boldh-2+(a Mod 2) To ghhi-1 Step 2
                               xy[0] = grid[a,b].x-gxoff
                               xy[1] = grid[a,b].y-gyoff
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff
                               xy[6] = grid[a,b+1].x-gxoff
                               xy[7] = grid[a,b+1].y-gyoff

                               delX=xy[4]-xy[0]-16;delY=xy[5]-xy[1]-16
                               If delX<delY Then delX=delY
                               If delX<0 Then
                                       colB=0.0
                               Else If delX>90 Then
                                       colB=1.0
                               Else
                                       colB=Sin(delX)
                               End If

                               SetColor(20+235*colB,20+100*colB,180-140*colB)
                               SetAlpha((1-colB)*.3+0.7)
                               SetLineWidth(1+colB*2)
                               DrawLine(xy[0],xy[1],xy[2],xy[3],0)
                               DrawLine(xy[2],xy[3],xy[4],xy[5],0)
                               DrawLine(xy[4],xy[5],xy[6],xy[7],0)
                               DrawLine(xy[6],xy[7],xy[0],xy[1],0)
                       Next
               Next

       End Function


       Function DrawGridLines5()
               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               Local boldw:Int
               Local boldh:Int
               Local colB:Float=0.0

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local delX:Float=0.0,delY:Float=0.0
               Local xy#[8]

               'glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST

               For a = gwlow+boldw-2 To gwhi-1 Step 1
                       For b = ghlow+boldh-2+(a Mod 2) To ghhi-1 Step 2
                               xy[0] = grid[a,b].x-gxoff
                               xy[1] = grid[a,b].y-gyoff
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff
                               xy[6] = grid[a,b+1].x-gxoff
                               xy[7] = grid[a,b+1].y-gyoff

                               delX=xy[4]-xy[0]-16;delY=xy[5]-xy[1]-16
                               If delX<delY Then delX=delY
                               If delX<0 Then
                                       colB=0.0
                               Else If delX>90 Then
                                       colB=1.0
                               Else
                                       colB=Sin(delX)
                               End If

                               SetColor(128+127*colB,15+105*colB,63-23*colB)
                               SetAlpha(colB*.2+0.6)
                               SetLineWidth(1+colB*1.5)
                               DrawLine(xy[0],xy[1],xy[4],xy[5],0)
                               DrawLine(xy[6],xy[7],xy[2],xy[3],0)
                       Next
               Next

       End Function


       Function DrawGridLines6()

               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               Local boldw:Int
               Local boldh:Int
               Local colB:Float=0.0
               Local alpha:Float=0.0

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local x:Int=0,y:Int=0,delX:Float=0.0,delY:Float=0.0
               Local xy#[8]

               'glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST

               For b = ghlow+boldh-2 To ghhi-1 Step 1
                       y:+1
                       x=0
                       For a = gwlow+boldw-2 To gwhi-1 Step 1
                               x:+1
                               Rem
                               If x>1 Then
                                       xy[6] = xy[4]
                                       xy[7] = xy[5]
                               Else
                                       xy[6] = grid[a,b+1].x-gxoff
                                       xy[7] = grid[a,b+1].y-gyoff
                               End If
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               delX=xy[2]-xy[6]-16;delY=xy[7]-xy[3]-16
                               End Rem
                               If x>1 Then
                                       xy[0] = xy[2]
                                       xy[1] = xy[3]
                                       xy[6] = xy[4]
                                       xy[7] = xy[5]
                               Else
                                       xy[0] = grid[a,b].x-gxoff
                                       xy[1] = grid[a,b].y-gyoff
                                       xy[6] = grid[a,b+1].x-gxoff
                                       xy[7] = grid[a,b+1].y-gyoff
                               End If
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               delX=xy[4]-xy[0]-16;delY=xy[5]-xy[1]-16
                               If delX<delY Then delX=delY
                               If delX<0 Then
                                       colB=0.0
                               Else If delX>90 Then
                                       colB=1.0
                               Else
                                       colB=Sin(delX)
                               End If
                               'colB=Sin(Min(90,Max(0,Max(delX,delY))))

                               SetColor(20+235*colB,20+100*colB,180-140*colB)
                               SetLineWidth(1+colB*1.5)'2?
                               alpha=(1-colB)*.0+.5
                               If a<gwhi-1 Then
                                       If (x Mod 4)>0 Then
                                               SetAlpha(alpha)
                                       Else
                                               SetAlpha(alpha+.5)
                                       End If
                                       DrawLine(xy[2],xy[3],xy[4],xy[5],0)
                               End If
                               If b<ghhi-1 Then
                                       If (y Mod 4)>0 Then
                                               SetAlpha(alpha)
                                       Else
                                               SetAlpha(alpha+.5)
                                       End If
                                       DrawLine(xy[4],xy[5],xy[6],xy[7],0)
                               End If
                       Next
               Next

	End Function

       Function DrawGridLines6b(alpha#)

               Local a:Int,b:Int
               ' draw grid
               Local boldw:Int
               Local boldh:Int

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local x:Int=0,y:Int=0
               Local xy#[8]
				SetLineWidth 2

               For b = ghlow+boldh-2 To ghhi-1 Step 1
                       y:+1
                       x=0
                       For a = gwlow+boldw-2 To gwhi-1 Step 1
                               x:+1
                               If x>1 Then
                                   xy[0] = xy[2]
                                   xy[1] = xy[3]
                                   xy[6] = xy[4]
                                   xy[7] = xy[5]
                               Else
                                   xy[0] = grid[a,b].x-gxoff
                                   xy[1] = grid[a,b].y-gyoff
                                   xy[6] = grid[a,b+1].x-gxoff
                                   xy[7] = grid[a,b+1].y-gyoff
                               End If
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               If a<gwhi-1 Then
'                                       If (x Mod 4)>0 Then
 '                                              SetAlpha (alpha)
  '                                     Else
   '                                            SetAlpha(alpha+.25)
    '                                   End If
                                       DrawLine(xy[2],xy[3],xy[4],xy[5],0)
                               End If
                               If b<ghhi-1 Then
  '                                     If (y Mod 4)>0 Then
   '                                            SetAlpha(alpha)
    '                                   Else
     '                                          SetAlpha(alpha+.25)
      '                                 End If
                                       DrawLine(xy[4],xy[5],xy[6],xy[7],0)
                               End If
                       Next
               Next

	End Function


       Function DrawGridLines7()

               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               Local boldw:Int
               Local boldh:Int
               Local colB:Float=0.0
               Local rgbR:Float=0,rgbG:Float=0,rgbB:Float=0


               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local x:Int=0,y:Int=0,delX:Float=0.0,delY:Float=0.0
               Local xy#[8]

               'glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST

               For b = ghlow+boldh-2 To ghhi-1 Step 1
                       For a = gwlow+boldw-2 To gwhi-1 Step 1
                               If x>1 Then
                                       xy[0] = xy[2]
                                       xy[1] = xy[3]
                                       xy[6] = xy[4]
                                       xy[7] = xy[5]
                               Else
                                       xy[0] = grid[a,b].x-gxoff
                                       xy[1] = grid[a,b].y-gyoff
                                       xy[6] = grid[a,b+1].x-gxoff
                                       xy[7] = grid[a,b+1].y-gyoff
                               End If
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               delX=xy[4]-xy[0]-16;delY=xy[5]-xy[1]-16
                               If delX<delY Then delX=delY
                               If delX<0 Then
                                       colB=0.0
                               Else If delX>90 Then
                                       colB=1.0
                               Else
                                       colB=Sin(delX)
                               End If
                               SetLineWidth(1+colB*1.0)
?not opengles
                               glBegin GL_LINE_LOOP
                                       glColor3f(.005,.05,.3)
                                       'glColor3f(.3,.1,.05)
                                       'glColor3f(.3,.1,.2)
                                       glVertex2f(xy[2],xy[3])
                                       glVertex2f(xy[4],xy[5])
                                       glVertex2f(xy[6],xy[7])
                               glEnd
                               glBegin GL_LINES
                                       glColor3f(.005,.05,.3)
                                       'glColor3f(.3,.1,.05)
                                       'glColor3f(.3,.1,.2)
                                       glVertex2f(xy[0],xy[1])
                                       glVertex2f(xy[4],xy[5])
                               glEnd
?
                       Next
               Next

       End Function


	Function DrawGridLines7b()
		Local a:Int,b:Int
		' draw grid
		SetScale 1,1
		Local boldw:Int
		Local boldh:Int

		boldw = 2-(gwlow Mod 2)
		boldh = 2-(ghlow Mod 2)

'		Local xy#[8]
'		Local xold:Float=0
'		Local dif:Float=0

		'Local rgbR:Int=95,rgbG:Int=23,rgbB:Int=23
'		Local rgbR:Int=104,rgbG:Int=26,rgbB:Int=23
'		Local rgbfR:Float= Float(rgbR/256),rgbfG:Float= Float(rgbG/256),rgbfB:Float= Float(rgbB/256)

		'glEnable GL_LINE_SMOOTH; glHint GL_LINE_SMOOTH, GL_NICEST

'		SetAlpha 1
'		SetColor rgbR,rgbG,rgbB
?not opengles
		glLineWidth(2)
		'horizontal
		For b = ghlow+boldh-2 To ghhi-1 Step 1
			glBegin GL_LINE_STRIP
			For a = gwlow+boldw-2 To gwhi Step 1
				'glColor3f(.005,.05,.3)
				If a>0 Then
'					dif=Min(50,Abs(grid[a,b].x-grid[a-1,b].x-16))*0.02
'					glColor3f(rgbfR+.6*dif,rgbfG+.2*dif,rgbfB-.1*dif)
				End If
				glVertex2f(grid[a,b].x-gxoff,grid[a,b].y-gyoff)
			Next
			glEnd
		Next
		'vertikal
'		SetColor rgbR,rgbG,rgbB
		For a = gwlow+boldw-2 To gwhi-1 Step 1
			glBegin GL_LINE_STRIP
			For b = ghlow+boldh-2 To ghhi Step 1
				'glColor3f(.005,.05,.3)
'				If b>0 Then
'					dif=Min(50,grid[a,b].y-grid[a,b-1].y-16)*0.02
'					glColor3f(rgbfR+.2*dif,rgbfG+.6*dif,rgbfB-.1*dif)
'				End If
				glVertex2f(grid[a,b].x-gxoff,grid[a,b].y-gyoff)
			Next
			glEnd
		Next
		glLineWidth(1.5)
		'diagonal rechts
'		SetColor rgbR,rgbG,rgbB
		Local xmax:Int=gwhi,ymax:Int=ghhi
		Local anz:Int=xmax+ymax,i:Int=0,j:Int=0,anzB:Int=0,xa:Int=0,ya:Int=ymax+1,x:Int=0,y:Int=0
		For i=0 To anz-1
			If i<=ymax Then
				anzB:+1
				ya:-1
			Else
				anzB=Min(ymax+1,xmax-xa)
				xa:+1
			End If
			x=xa
			y=ya
			glBegin GL_LINE_STRIP
			For j=1 To anzB
				'glColor3f(.005,.05,.3)
				glVertex2f(grid[x,y].x-gxoff,grid[x,y].y-gyoff)
				x:+1
				y:+1
			Next
			glEnd
		Next
		'diagonal links
		anzB=0;xa=-1;ya=0;x=0;y=0
		For i=0 To anz-1
			If i<=xmax Then
				anzB=Min(ymax+1,anzB+1)
				xa:+1
			Else
				anzB:-1
				ya:+1
			End If
			x=xa
			y=ya
			glBegin GL_LINE_STRIP
			For j=1 To anzB
				'glColor3f(.005,.05,.3)
				glVertex2f(grid[x,y].x-gxoff,grid[x,y].y-gyoff)
				x:-1
				y:+1
			Next
			glEnd
		Next
?
	End Function


	Function DrawGridLines8()

               Local a:Int,b:Int
               ' draw grid
               SetScale 1,1
               Local boldw:Int
               Local boldh:Int
               Local sca:Float=0.0,sinAkt:Float=0.0

               boldw = 2-(gwlow Mod 2)
               boldh = 2-(ghlow Mod 2)

               Local x:Int=0,y:Int=0,delX:Float=0.0,delY:Float=0.0
               Local xy#[8]

               'glEnable GL_POLYGON_SMOOTH; glHint GL_POLYGON_SMOOTH, GL_NICEST

               moiAkt:+.05
               If moiAkt>=360 Then moiAkt:-360
               sinAkt=36*Sin(moiAkt)
               For b = ghlow+boldh-2 To ghhi-1 Step 1
                       For a = gwlow+boldw-2 To gwhi-1 Step 1
                               If x>1 Then
                                       xy[6] = xy[4]
                                       xy[7] = xy[5]
                               Else
                                       xy[6] = grid[a,b+1].x-gxoff
                                       xy[7] = grid[a,b+1].y-gyoff
                               End If
                               xy[2] = grid[a+1,b].x-gxoff
                               xy[3] = grid[a+1,b].y-gyoff
                               xy[4] = grid[a+1,b+1].x-gxoff
                               xy[5] = grid[a+1,b+1].y-gyoff

                               sca=.5+.25*Sin(sinAkt*a*b)
?not opengles
                               glBegin GL_TRIANGLES
                                       glColor3f(.3,.3,.3)
                                       glVertex2f(xy[2],xy[5]+(xy[3]-xy[5])*sca)
                                       glColor3f(.3,.3,.0)
                                       glVertex2f(xy[4],xy[5])
                                       glColor3f(.3,0,0)
                                       glVertex2f(xy[4]+(xy[6]-xy[4])*sca,xy[7])
                               glEnd
?
                       Next
               Next

       End Function

EndType






'particles
Type part

	Field x#,y#,dx#,dy#,r:Int,g:Int,b:Int
	Field active:Int

	Function CreateAll()
		Local t:Int
		For t = 0 To MAXPARTICLES-1
			partarray[t] = New part
			partarray[t].x = 0
			partarray[t].y = 0
			partarray[t].r = 0
			partarray[t].g = 0
			partarray[t].b = 0
			partarray[t].active = 0
			partarray[t].dx = 0
			partarray[t].dy = 0
			Part_list.addlast( partarray[t] )
		Next
		slotcount = 0
	End Function

	Function Create( x#, y# ,typ:Int, r:Int,g:Int,b:Int, rot:Float = 0, sz:Int = 1)
'	Function Create( x#, y# ,typ:Int, r:Int,g:Int,b:Int, rot:Int = 0, sz:Int = 1)
			Local p:Part
			Local flag:Int
			Local dir:Int, mag#

			p:Part = partarray[slotcount]
			p.x = x
			p.y = y
			p.r = r
			p.g = g
			p.b = b
			p.active = Rand(particlelife-20,particlelife)
			Select typ
				Case 0
					' random
					dir = Rand(0,359)
					mag# = Rnd(3,10)
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
				Case 1
					mag# = 16
					p.dx = Cos(rot)*mag
					p.dy = Sin(rot)*mag
					p.active = 24
				Case 2
					dir = rot
					mag# = 8
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
				Case 8
					' 3 dirs
					dir = 120*Rand(0,2)+rot
					mag# = Rnd(3,10)
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
				Case 3
					' 4 dirs
					dir = 90*Rand(0,3)+rot
					mag# = Rnd(3,10)
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
				Case 6
					' 8 dirs
					dir = 45*Rand(0,7)+rot
					mag# = Rnd(3,10)
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
				Case 7
					' any dir and speed
					mag# = Rnd(.5,1)
					p.dx = Cos(rot)*mag
					p.dy = Sin(rot)*mag
					' evil!
				Case 9
					' bomb internal particles
					dir = Rand(0,359)
					mag# = Rnd(1,13)
					p.dx = Cos(dir)*mag
					p.dy = Sin(dir)*mag
					' /evil
			End Select
			p.dx = p.dx*2
			p.dy = p.dy*2
			p.x:+ p.dx*sz
			p.y:+ p.dy*sz
			slotcount:+1
			If slotcount > numparticles-1 Then slotcount = 0
	EndFunction


	Method UpdateWide()
		If active > 0
			x = x + dx
			y = y + dy
			If x =< dx
				dx = Abs(dx)
				x = x + dx*2
			EndIf
			If x > SCREENW-1-dx
				dx = -Abs(dx)
				x = x + dx*2
			EndIf
			If y =< dy
				dy = Abs(dy)
				y = y + dy*2
			EndIf
			If y > SCREENH-1-dy
				dy = -Abs(dy)
				y = y + dy*2
			EndIf
			dx = dx *particledecay
			dy = dy *particledecay
			active:-1
			If active < 20
				If active < 10
					r:*.8';If r < 0 Then r = 0
					g:*.8';If g < 0 Then g = 0
					b:*.8';If b < 0 Then b = 0
				Else
					r:*.97';If r < 0 Then r = 0
					g:*.97';If g < 0 Then g = 0
					b:*.97';If b < 0 Then b = 0
				EndIf
			ElseIf active > 200
				active = 200
			EndIf
		EndIf
	End Method


	Method Update()
		If active > 0
			x = x + dx
			y = y + dy
			If x =< dx
				dx = Abs(dx)
				x = x + dx*2
			EndIf
			If x > PLAYFIELDW-1-dx
				dx = -Abs(dx)
				x = x + dx*2
			EndIf
			If y =< dy
				dy = Abs(dy)
				y = y + dy*2
			EndIf
			If y > PLAYFIELDH-1-dy
				dy = -Abs(dy)
				y = y + dy*2
			EndIf
			dx = dx *particledecay
			dy = dy *particledecay
			active:-1
			If active < 20
				If active < 10
					r:*.8';If r < 0 Then r = 0
					g:*.8';If g < 0 Then g = 0
					b:*.8';If b < 0 Then b = 0
				Else
					r:*.97';If r < 0 Then r = 0
					g:*.97';If g < 0 Then g = 0
					b:*.97';If b < 0 Then b = 0
				EndIf
			ElseIf active > 200
				active = 200
			EndIf
		EndIf
	End Method


	Function DrawParticles()
		Local p:part
		Local t:Int

		Select particlestyle

			Case 0
				SetBlend lightblend
				SetScale 2,2
				SetAlpha 1
				SetLineWidth 1.0
				For t = 0 To numparticles-1
					p:part = partarray[t]
					If p.active > 0
						Local rr%,gg%,bb%
						rr = p.r*1.25;If rr>255 Then rr = 255
						gg = p.g*1.25;If gg>255 Then gg = 255
						bb = p.b*1.25;If bb>255 Then bb = 255
						SetColor rr,gg,bb
						DrawLine p.x-gxoff,p.y-gyoff,p.x-gxoff+p.dx,p.y-gyoff+p.dy
					EndIf
				Next
				SetAlpha 1
				SetLineWidth 2.0
				SetScale 1,1
			Case 1
				SetBlend lightblend
				SetScale 2,2 '3,3
				SetAlpha .9
				SetLineWidth 2
				For t = 0 To numparticles-1
					p:part = partarray[t]
					If p.active > 0
						Local rr%,gg%,bb%
						rr = p.r*1.25;If rr>255 Then rr = 255
						gg = p.g*1.25;If gg>255 Then gg = 255
						bb = p.b*1.25;If bb>255 Then bb = 255
						SetColor rr,gg,bb
						DrawLine p.x-gxoff,p.y-gyoff,p.x-gxoff+p.dx,p.y-gyoff+p.dy
					EndIf
				Next
				SetAlpha 1
				SetLineWidth 2.0
				SetScale 1,1
			Case 2
				SetBlend lightblend
				SetScale .5,.5
				For t = 0 To numparticles-1
					p:part = partarray[t]
					If p.active > 0
						Local rr%,gg%,bb%
						rr = p.r*1.5;If rr>255 Then rr = 255
						gg = p.g*1.5;If gg>255 Then gg = 255
						bb = p.b*1.5;If bb>255 Then bb = 255
						SetColor rr,gg,bb
						'SetAlpha .7
						'DrawImage particleimg,p.x-gxoff,p.y-gyoff
						SetAlpha 1 '.9
						DrawImage particleimg,p.x-gxoff+p.dx,p.y-gyoff+p.dy
					EndIf
				Next
				SetAlpha 1
				SetScale 1,1
			Case 3  'bloom lines
				Local win:Float,px:Float,py:Float',dx:Float,dy:Float
				Local rr:Int,gg:Int,bb:Int

				SetBlend lightblend
				SetLineWidth 2
				SetAlpha .8
				SetTransform 0,2,2

				For t = 0 To numparticles-1
					p:part = partarray[t]
					If p.active > 0
						rr = p.r*1.25;If rr>255 Then rr = 255
						gg = p.g*1.25;If gg>255 Then gg = 255
						bb = p.b*1.25;If bb>255 Then bb = 255
						SetColor rr,gg,bb
						px=p.x-gxoff;py=p.y-gyoff
						DrawLine px,py,px+p.dx,py+p.dy
					EndIf
				Next
				For t = 0 To numparticles-1
					p:part = partarray[t]
					If p.active > 0
						rr = p.r*1.25;If rr>255 Then rr = 255
						gg = p.g*1.25;If gg>255 Then gg = 255
						bb = p.b*1.25;If bb>255 Then bb = 255
						SetColor rr,gg,bb

						win=ATan(p.dy/p.dx)
						px=p.x-gxoff;py=p.y-gyoff
						SetAlpha .25
						SetTransform win,Sqr(p.dx*p.dx+p.dy*p.dy)*.4,1.2
						DrawImage particleimg,px+p.dx*1.0,py+p.dy*1.0
					EndIf
				Next
				SetAlpha 1
				SetTransform 0,1,1
				SetLineWidth 2.0

		End Select

	End Function


	Function UpdateParticles(ww:Int=0)
		Local p:part,t:Int
		If ww
			For t = 0 To numparticles-1
				p:part = partarray[t]
				If p.active > 0
					p.UpdateWide()
				EndIf
			Next
		Else
			For t = 0 To numparticles-1
				p:part = partarray[t]
				If p.active > 0
					p.Update()
				EndIf
			Next
		EndIf
	End Function


	Function CreateFireWorks(style:Int)
		Local t:Int,x:Int,y:Int,r:Int,g:Int,b:Int
		r = Rand(0,3)*64
		g = Rand(0,3)*64
		b = Rand(0,3)*64
		If style = 1
			If Rand(0,1)
				x = Rand(100,SCREENW-100)
				y = 16
				If Rand(0,1) Then y = SCREENH-16
			Else
				y = Rand(50,SCREENH-50)
				x = 16
				If Rand(0,1) Then x = SCREENW-16
			EndIf
		ElseIf style = 2
			x = SCREENW/2
			y = SCREENH/2
		Else
			x = Rand(100,SCREENW-100)
			y = Rand(50,SCREENH-50)
		EndIf
		For t = 0 To 63
			part.Create(x,y,0,r,g,b)
		Next
	End Function


	Function ResetAll()
		Local p:Part
		Local t:Int

		For t = 0 To MAXPARTICLES-1
			p:Part = partarray[t]
			p.x = 0
			p.y = 0
			p.r = 0
			p.g = 0
			p.b = 0
			p.active = 0
			p.dx = 0
			p.dy = 0
		Next
		slotcount = 0
	End Function

End Type






'trail
Type trail

	Field x#,y#,r:Int,g:Int,b:Int
	Field dx#,dy#
	Field active:Int

	Function Create( x#, y# ,r:Int,g:Int,b:Int,dx#,dy#)
		Local p:trail
			p:trail = New trail
			p.x = x
			p.y = y
			p.dx = dx*1.5
			p.dy = dy*1.5
			p.r = r
			p.g = g
			p.b = b
			p.active = 40
			trail_list.addfirst( p )
	EndFunction

	Method Update()
		active:-1

		If active < 28
			r:*.91
			g:*.88
			b:*.86
			x:+dx
			y:+dy
			dx:*0.999
			dy:*0.999
		EndIf
		If active <= 0 Then trail_LIST.Remove(Self)

	End Method


	Function DrawTrail()

		Local p:trail

		SetBlend lightblend
		SetScale 2,2
		SetAlpha .23
		For p:trail = EachIn trail_list
			SetColor p.r,p.g,p.b
			DrawRect p.x-gxoff,p.y-gyoff,1,1   'p.x-gxoff+p.dx,p.y-gyoff+p.dy
		Next
		For p:trail = EachIn trail_list
			SetColor p.r,p.g,p.b
			DrawImage particleimg,p.x-gxoff,p.y-gyoff
		Next
		SetAlpha 1
		SetScale 1,1

	End Function

	Function UpdateTrail()
		Local p:trail
		For p:trail= EachIn trail_list
			p.Update()
		Next
	End Function

End Type


Function CreateStars()
	Local t:Int
	For t = 0 To MAXSTARS
		starx[t] = Rand(-100,Max(PLAYFIELDW,SCREENW)+100)
		stary[t] = Rand(-100,Max(PLAYFIELDH,SCREENH)+100)
		stard[t] = 2+Float(t Mod 8)/4
	Next
EndFunction

Function DrawStars()

	If showstars > 0
		SetBlend lightblend
		SetScale 2,2
		SetAlpha .8
		SetLineWidth 2.0
		Local t:Int
		For t = 0 To showstars
			SetColor 480/stard[t],480/stard[t],480/stard[t]
			DrawRect starx[t]-gxoff/stard[t],stary[t]-gyoff/stard[t],1,1
		Next
		SetAlpha 1
		SetScale 1,1
	EndIf

End Function





