Strict

Import BRL.PNGLoader

Global gfxset:Int = 0

' images
Global iconimage:TImage = Null
Global greensquare:Timage = Null
Global purplesquare1:Timage = Null
Global purplesquare2:Timage = Null
Global bluediamond:Timage = Null
Global pinkpinwheel:Timage = Null
Global indigotriangle:Timage = Null
Global bluecircle:Timage = Null
Global redclone:Timage = Null
Global orangetriangle:Timage = Null 
Global redcircle:Timage = Null
Global whiteplayer:Timage = Null
Global yellowshot:Timage = Null
Global whitestar:Timage = Null
Global snaketail:TImage = Null
Global snakehead:TImage = Null
Global powerimage:TImage = Null
Global capturedimg:TImage = Null 
Global particleimg:Timage = Null
Global colourpick:Timage  = Null


Function LoadImages()
	Local path$ = ""

	AutoImageFlags (FILTEREDIMAGE|MIPMAPPEDIMAGE)
	AutoMidHandle(True) 
	iconimage:TImage = Null
	greensquare:Timage = Null
	purplesquare1:Timage = Null
	purplesquare2:Timage = Null
	bluediamond:Timage = Null
	pinkpinwheel:Timage = Null
	indigotriangle:Timage = Null
	bluecircle:Timage = Null
	redclone:Timage = Null
	orangetriangle:Timage = Null
	redcircle:Timage = Null
	whiteplayer:Timage = Null
	yellowshot:Timage = Null
	whitestar:Timage = Null
	snaketail:TImage = Null
	snakehead:TImage = Null	
	powerimage:TImage = Null
	particleimg:Timage = Null
	colourpick:Timage = Null

	Select gfxset
		Case 0 ' solid
			path$= "gfx/solid/"
			iconimage:TImage = LoadAnimImage(path$+"icons.png",64,64,0,2)
			snaketail:TImage = LoadAnimImage(path$+"snaketail.png",56,56,0,24)
			powerimage:TImage = LoadAnimImage(path$+"powerups.png",64,64,0,11)
		Case 1'low
			path$= "gfx/low/"
			iconimage:TImage = LoadAnimImage(path$+"icons.png",24,24,0,2)
			snaketail:TImage = LoadAnimImage(path$+"snaketail.png",32,32,0,24)
			powerimage:TImage = LoadAnimImage(path$+"powerups.png",64,64,0,11)
		Case 2 ' med
			path$= "gfx/med/"
			iconimage:TImage = LoadAnimImage(path$+"icons.png",32,32,0,2)
			snaketail:TImage = LoadAnimImage(path$+"snaketail.png",32,32,0,24)
			powerimage:TImage = LoadAnimImage(path$+"powerups.png",64,64,0,11)		
		Case 3 ' high
			path$= "gfx/high/"
			iconimage:TImage = LoadAnimImage(path$+"icons.png",64,64,0,2)
			snaketail:TImage = LoadAnimImage(path$+"snaketail.png",56,56,0,24)
			powerimage:TImage = LoadAnimImage(path$+"powerups.png",64,64,0,11)
		Case 4 ' user
			path$= "gfx/user/"
			iconimage:TImage = LoadAnimImage(path$+"icons.png",64,64,0,2)
			snaketail:TImage = LoadAnimImage(path$+"snaketail.png",56,56,0,24)
			powerimage:TImage = LoadAnimImage(path$+"powerups.png",64,64,0,11)
	End Select
		
	greensquare:Timage = LoadImage(path$+"greensquare.png")
	purplesquare1:Timage = LoadImage(path$+"purplesquare1.png")
	purplesquare2:Timage = LoadImage(path$+"purplesquare2.png")
	bluediamond:Timage = LoadImage(path$+"bluediamond.png")
	pinkpinwheel:Timage = LoadImage(path$+"pinkpinwheel.png")
	indigotriangle:Timage = LoadImage(path$+"indigotriangle.png")
	bluecircle:Timage = LoadImage(path$+"bluecircle.png")
	redclone:Timage = LoadImage(path$+"redclone.png")
	orangetriangle:Timage = LoadImage(path$+"orangetriangle.png")
	redcircle:Timage = LoadImage(path$+"redcircle.png")
	whiteplayer:Timage = LoadImage(path$+"whiteplayer.png")
	yellowshot:Timage = LoadImage(path$+"yellowshot.png")
	whitestar:Timage = LoadImage(path$+"whitestar.png")
	snakehead:TImage = LoadImage(path$+"snakehead.png")	
	particleimg:Timage = LoadImage(path$+"particle.png")
	
	colourpick:TImage = LoadAnimImage("gfx/colourpick.png",122,9,0,3)
	
End Function



