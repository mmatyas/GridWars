Strict

Import BRL.RandomDefault
Import BRL.PNGLoader



Global rcol% = 250, rcoldelta# = -3
Global gcol% = 20,  gcoldelta# = 5
Global bcol% = 30,  bcoldelta# = 7


Global keystring$[300]


Function CycleColours(slow#=10)
	rcol = rcol + rcoldelta/10*slow
	If rcol < 0
		rcol = 0
		rcoldelta = Rnd(1,slow)
	ElseIf rcol > 255
		rcol = 255
		rcoldelta = -Rnd(1,slow)
	EndIf
	gcol = gcol + gcoldelta/10*slow
	If gcol < 0
		gcol = 0
		gcoldelta = Rnd(1,slow)
	ElseIf gcol > 255
		gcol = 255
		gcoldelta = -Rnd(1,slow)
	EndIf
	bcol = bcol + bcoldelta/10*slow
	If bcol < 0
		bcol = 0
		bcoldelta = Rnd(1,slow)
	ElseIf bcol > 255
		bcol = 255
		bcoldelta = -Rnd(1,slow)
	EndIf
End Function




Function GetPlayTime$(cnt:Int)
' cnt is 20ms each ie 50 cnts = 1 sec
	Local s$ = ""
	Local secs:Int = Int(cnt/50)
	Local minutes:Int = Int(secs/60)
	Local hours:Int = Int(minutes/60)
	If hours > 0
		s$ = hours + " hr"
		If hours > 1
			s$:+ "s, "
		Else
			s$:+ ", "
		EndIf
	EndIf
	If minutes > 0
		s$:+ (minutes Mod 60) + " mn"
		If minutes > 1
			s$:+ "s, "
		Else
			s$:+ ", "
		EndIf
	EndIf
	If secs > 0
		s$:+ (secs Mod 60) + " sec"
		If secs > 1 Then s$:+ "s"
	EndIf
	Return s$
End Function


Function FitValueToRange#( InValue#, RangeIn_Start#, RangeIn_End#, RangeOut_Start#, RangeOut_End# )

	Local OldRange# = RangeIn_End# - RangeIn_Start#
	Local NewRange# = RangeOut_End# - RangeOut_Start#

	Local OutValue# = ((InValue#-RangeIn_Start) / OldRange#) * NewRange#	+ RangeOut_Start

	Return OutValue#

End Function


Function DrawCircle(xCenter:Int,yCenter:Int,radius:Int)

	Local p%, x%, y%

	x = 0
	y = radius
	Plot xCenter + x, yCenter + y
	Plot xCenter - x, yCenter + y
	Plot xCenter + x, yCenter - y
	Plot xCenter - x, yCenter - y
	Plot xCenter + y, yCenter + x
	Plot xCenter - y, yCenter + x
	Plot xCenter + y, yCenter - x
	Plot xCenter - y, yCenter - x
	p = 1 - radius
	While x < y
		If p < 0
			x = x + 1
		Else
			x = x + 1
			y = y - 1
		EndIf
		If p < 0
			p = p + (x Shl 1) + 1
		Else
			p = p + ((x - y) Shl 1) + 1
		EndIf
		Plot xCenter + x, yCenter + y
		Plot xCenter - x, yCenter + y
		Plot xCenter + x, yCenter - y
		Plot xCenter - x, yCenter - y
		Plot xCenter + y, yCenter + x
		Plot xCenter - y, yCenter + x
		Plot xCenter + y, yCenter - x
		Plot xCenter - y, yCenter - x
	Wend

End Function


Function Rect(x:Int,y:Int,w:Int,h:Int,f:Int=0)
	If f
		'solid
		DrawRect x,y,w,h
	Else
		'outline
		Local x1:Int = x + w
		Local y1:Int = y + h
		DrawLine x,y,x,y1
		DrawLine x,y1,x1,y1
		DrawLine x1,y1,x1,y
		DrawLine x1,y,x,y
	EndIf
End Function





Function RectsOverlap:Int(x1:Int,y1:Int,w1:Int,h1:Int,x2:Int,y2:Int,w2:Int,h2:Int)

	If x1 > x2+w2
		' rec 1 is too far right
		Return False
	Else
		If x1+w1 < x2
			' rec 1 is too far left
			Return False
		Else
			' xs are overlapping - check ys
			If y1 > y2+h2
				' rec 1 is too far down
				Return False
			Else
				If y1+h1 < y2
					' rec 1 is too far above
					Return False
				Else
					' overlap?
					Return True
				EndIf
			EndIf
		EndIf
	EndIf

End Function



' rotate xr,yr around xc,yc
Function TFormR(xc#,yc#, angle:Int, xr# Var,yr# Var)
'	xs$ = xc+" "+yc+" "+xr+" "+yr+" "+angle
'	writedelay(xs$)
	Local x# = (xr-xc)
	Local y# = (yr-yc)
	xr = Cos(angle)*x - Sin(angle)*y
	yr = Sin(angle)*x + Cos(angle)*y
	xr = xc+xr
	yr = yc+yr
'	xs$ = xc+" "+yc+" "+xr+" "+yr+" "+angle
'	writedelay(xs$)
End Function



Function PointInTri:Int(xo#,yo#,x1#,y1#,x2#,y2#,x3#,y3#)
	Local c:Int = True ' point is inside 64 pixels from nme7 - is it in the force field?
	If  (  (  (y1 <= yo) And (yo < y2)  )  Or  (  (y2 <= yo) And (yo < y1)  )  )
		If (y2 - y1) <> 0
			If (xo < (x2 - x1) * (yo - y1) / (y2 - y1) + x1)
				c = Not c
			EndIf
		EndIf
	EndIf
	If  (  (  (y1 <= yo) And (yo < y3)  )  Or  (  (y3 <= yo) And (yo < y3)  )  )
		If (y2 - y1) <> 0
			If (xo < (x3 - x1) * (yo - y1) / (y3 - y1) + x1)
				c = Not c
			EndIf
		EndIf
	EndIf
	Return c
End Function



' not used
'Function IsInTriangle:Int( px#,py#, ax#,ay#,bx#,by#,cx#,cy# )

'	Local bc#,ca#,ab#,ap#,bp#,cp#,abc#

'	bc# = bx*cy - by*cx
'	ca# = cx*ay - cy*ax
'	ab# = ax*by - ay*bx
'	ap# = ax*py - ay*px
'	bp# = bx*py - by*px
'	cp# = cx*py - cy*px
'	abc# = Sgn(bc + ca + ab)

'	If (abc*(bc-bp+cp)>0) And (abc*(ca-cp+ap)>0) And (abc*(ab-ap+bp)>0) Then Return True
'End Function


Function PointToPointDist#(x1#,y1#,x2#,y2#)
	Local dx# = x1-x2
	Local dy# = y1-y2

	Return Sqr(dx*dx + dy*dy)

End Function


Function LineCollide2#(x1#,y1#,x2#,y2#, px#,py#,r:Int)

	If x1 = x2 And y1 = y2
		If PointToPointDist(px,py,x1,y1) <= r Then Return True Else Return False
	EndIf

	Local sx# = x2-x1
	Local sy# = y2-y1

	Local q# = ((px-x1) * (x2-x1) + (py - y1) * (y2-y1)) / (sx*sx + sy*sy)

	If q < 0.0 Then q = 0.0
	If q > 1.0 Then q = 1.0

	If PointToPointDist(px,py,(1-q)*x1+q*x2,(1-q)*y1 + q*y2) <= r Then Return True Else Return False
End Function


' return -1 to -180, or 1 to 180
Function TurnToFace:Int(x#,y#, dx#, dy#, plx#, ply#)

	Local angle1#, angle2#, ret:Int

	angle1 = ATan2(ply-y,plx-x)
	angle2 = ATan2(dy,dx)

	ret = angle1-angle2
	If ret >= 180
		ret = -(360 - ret)
	Else
		If ret <= -180
			ret = ret + 360
		EndIf
	EndIf

	If Abs(ret) < 6 Then ret = 0

    Return ret

End Function



Function SaveScreenshot(f$)
	Local img:TPixmap = GrabPixmap(0,0,GraphicsWidth(),GraphicsHeight())
	SavePixmapPNG(img, f$)
EndFunction


'Key names  -  Falken '05
Function SetupKeyTable()
	Local tempkey$, put_index:Int
	RestoreData key_data
	Repeat
		ReadData tempkey$
		ReadData put_index
		keystring[put_index] = tempkey
	Until put_index=299
End Function

#key_data
DefData "Mouse button (Left)",1
DefData "Mouse button (Right)",2
DefData "Mouse button (Middle)" ,4
DefData "Backspace",8
DefData "Tab",9
DefData "Return",13
DefData "Clear",12
DefData "Enter",13
DefData "Shift",16
DefData "Control",17
DefData "Alt",18
DefData "Pause",19
DefData "Caps Lock",20
DefData "Escape",27
DefData "Space",32
DefData "Page Up",33
DefData "Page Down",34
DefData "End",35
DefData "Home",36
DefData "Cursor (Left)",37
DefData "Cursor (Up)",38
DefData "Cursor (Right)",39
DefData "Cursor (Down)",40
DefData "Select",41
DefData "Print",42
DefData "Execute",43
DefData "Screen",44
DefData "Insert",45
DefData "Delete",46
DefData "Help",47
DefData "0",48
DefData "1",49
DefData "2",50
DefData "3",51
DefData "4",52
DefData "5",53
DefData "6",54
DefData "7",55
DefData "8",56
DefData "9",57
DefData "A",65
DefData "B",66
DefData "C",67
DefData "D",68
DefData "E", 69
DefData "F",70
DefData "G",71
DefData "H",72
DefData "I",73
DefData "J",74
DefData "K",75
DefData "L",76
DefData "M",77
DefData "N",78
DefData "O",79
DefData "P",80
DefData "Q",81
DefData "R",82
DefData "S",83
DefData "T",84
DefData "U",85
DefData "V",86
DefData "W",87
DefData "X",88
DefData "Y", 89
DefData "Z", 90
DefData "Sys key (Left)",91
DefData "Sys key (Right)",92
DefData "Numpad 0",96
DefData "Numpad 1",97
DefData "Numpad 2",98
DefData "Numpad 3",99
DefData "Numpad 4",100
DefData "Numpad 5",101
DefData "Numpad 6",102
DefData "Numpad 7",103
DefData "Numpad 8",104
DefData "Numpad 9",105
DefData "Numpad *",106
DefData "Numpad +",107
DefData "Numpad /",108
DefData "Numpad -",109
DefData "Numpad .",110
DefData "Numpad /",111
DefData "F1",112
DefData "F2",113
DefData "F3",114
DefData "F4",115
DefData "F5",116
DefData "F6",117
DefData "F7",118
DefData "F8",119
DefData "F9",120
DefData "F10",121
DefData "F11", 122
DefData "F12",123
DefData "Num Lock",144
DefData "Scroll Lock",145
DefData "Shift (Left)",160
DefData "Shift (Right)",161
DefData "Control (Left)",162
DefData "Control (Right)",163
DefData "Alt key (Left)",164
DefData "Alt key (Right)",165
DefData "Tilde",192
DefData "Minus",107
DefData "Equals",109
DefData "Bracket (Open)",219
DefData "Bracket (Close)",221
DefData "Backslash",226
DefData "Semi-colon",186
DefData "Quote",222
DefData "Comma",188
DefData "Period",190
DefData "Slash",191
DefData "Hit A Key",299

