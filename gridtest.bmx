Framework BRL.GLMax2D

Import "colordefs.bmx"
Import "gridparttrail.bmx"

SetGraphicsDriver GLMax2DDriver()


Graphics 1024,768,0


sz# = 64
amnt = 10


playsizew = 1024
playsizeh = 768
screensizew = 1024
screensizeh = 768
windowed = True

GetGfxModes()
FindSetting()
SetUp()

Local pat:Int = 0

While Not KeyDown(KEY_ESCAPE)

	Cls

	If MouseDown(1)
		gridpoint.Pull(MouseX()+gxoff,MouseY()+gyoff,sz,amnt)
	EndIf

	If MouseDown(2)
		gridpoint.Push(MouseX()+gxoff,MouseY()+gyoff,sz,amnt/4)
	EndIf
	If MouseHit(3) Then pat = (pat + 1) Mod 21
		
	tim = MilliSecs()
	
	gridpoint.UpdateGrid()	
	gridpoint.DrawGrid(pat)	
	SetColor COL_BORDER_R,COL_BORDER_G,COL_BORDER_B
	SetLineWidth(2.0)
	DrawLine -gxoff,-gyoff,PLAYFIELDW-1-gxoff,-gyoff
	DrawLine -gxoff,-gyoff,-gxoff,PLAYFIELDH-1-gyoff
	DrawLine -gxoff,PLAYFIELDH-1-gyoff,PLAYFIELDW-1-gxoff,PLAYFIELDH-1-gyoff
	DrawLine PLAYFIELDW-1-gxoff,PLAYFIELDH-1-gyoff,PLAYFIELDW-1-gxoff,-gyoff
	
	If MouseX() < 100
		gxoff:-10
		If gxoff < -100
			gxoff = -100
		EndIf
	EndIf
	If MouseY() < 100
		gyoff:-10
		If gyoff < -100
			gyoff = -100
		EndIf
	EndIf
	If MouseX() > 1024-100
		gxoff:+10
		If gxoff > PLAYFIELDW-1024+100
			gxoff = PLAYFIELDW-1024+100
		EndIf
	EndIf
	If MouseY() > 768-100
		gyoff:+10
		If gyoff > PLAYFIELDH-768+100
			gyoff = PLAYFIELDH-768+100
		EndIf
	EndIf		
	
	Flip
	tim = MilliSecs() - tim
	If tim < 20 And tim > 0
		Delay 20-tim
	EndIf
	
Wend

	
