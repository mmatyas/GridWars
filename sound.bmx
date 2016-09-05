Strict

Import BRL.FreeAudioAudio
Import BRL.WavLoader

?Win32
Import "bass.bmx"
?

Global sfxvol# = 0.5
Global musicvol# = 0.5
?Mac
Global musicchannel:TChannel = Null
?Win32
Global musicchannel:Int = 0
?Linux
Global musicchannel:TChannel = Null
?


Global sunloopchan:TChannel[]
sunloopchan = New TChannel[8]


Global soundset:Int = 0
' snds
Global nme_born_snd:TSound = Null
Global nme1_born_snd:TSound = Null
Global nme2_born_snd:TSound = Null
Global nme3_born_snd:TSound = Null
Global nme4_born_snd:TSound = Null

Global nme5_born_snd:TSound = Null
Global nme5_loop_snd:TSound = Null
Global nme5_shrink_snd:TSound = Null
Global nme5_grow_snd:TSound = Null
Global nme5_explode_snd:TSound = Null
Global nme5_killed_snd:TSound = Null

Global nme6_born_snd:TSound = Null
Global nme6_tailexplode_snd:TSound = Null
Global nme6_tailhit_snd:TSound = Null

Global nme7_born_snd:TSound = Null
Global nme7_shield_snd:TSound = Null

Global nme8_born_snd:TSound = Null

Global ge_born_snd:TSound = Null
Global ge_hit_snd:TSound = Null
Global ge_killed_snd:TSound = Null

Global le_born_snd:TSound = Null
Global le_hit_snd:TSound = Null
Global le_killed_snd:TSound = Null

Global pu_collect_snd:TSound = Null

Global get_ready_snd:TSound = Null

Global player_hit_snd:TSound = Null

Global shot_born_snd:TSound = Null
Global shot_hit_wall_snd:TSound = Null

Global game_over_snd:TSound = Null

Global super_bomb_snd:TSound = Null

Global extra_life_snd:TSound = Null

Global extra_bomb_snd:TSound = Null

Global multiplier_increase_snd:TSound = Null
Global bonus_born_snd:TSound = Null
Global high_score_snd:TSound = Null

Global quarkhitsound:TSound = Null
Global quarkhit2sound:TSound = Null

Global shieldwarningsnd:TSound = Null


Function LoadSounds()
	Local folder$
	
	Select soundset
		Case 1
			folder$ = "sounds/user/"
		Default
			folder$ = "sounds/"
	End Select
	
	nme_born_snd:TSound = Null
	nme1_born_snd:TSound = Null
	nme2_born_snd:TSound = Null
	nme3_born_snd:TSound = Null
	nme4_born_snd:TSound = Null

	nme5_born_snd:TSound = Null
	nme5_loop_snd:TSound = Null
	nme5_shrink_snd:TSound = Null
	nme5_grow_snd:TSound = Null
	nme5_explode_snd:TSound = Null
	nme5_killed_snd:TSound = Null

	nme6_born_snd:TSound = Null
	nme6_tailexplode_snd:TSound = Null
	nme6_tailhit_snd:TSound = Null

	nme7_born_snd:TSound = Null
	nme7_shield_snd:TSound = Null

	nme8_born_snd:TSound = Null

	ge_born_snd:TSound = Null
	ge_hit_snd:TSound = Null
	ge_killed_snd:TSound = Null

	le_born_snd:TSound = Null
	le_hit_snd:TSound = Null
	le_killed_snd:TSound = Null

	pu_collect_snd:TSound = Null

	get_ready_snd:TSound = Null

	player_hit_snd:TSound = Null

	shot_born_snd:TSound = Null
	shot_hit_wall_snd:TSound = Null

	game_over_snd:TSound = Null

	super_bomb_snd:TSound = Null

	extra_life_snd:TSound = Null

	extra_bomb_snd:TSound = Null

	multiplier_increase_snd:TSound = Null
	bonus_born_snd:TSound = Null
	high_score_snd:TSound = Null

	quarkhitsound:TSound = Null
	quarkhit2sound:TSound = Null
	shieldwarningsnd:TSound = Null
		
	' snds
	nme_born_snd:TSound = LoadSound(folder$+"buzz3.wav")			' 
	nme1_born_snd:TSound = LoadSound(folder$+"pop2.wav")			' 
	nme2_born_snd:TSound = LoadSound(folder$+"pop3.wav")			' 
	nme3_born_snd:TSound = LoadSound(folder$+"snake1.wav")			' 
	nme4_born_snd:TSound = LoadSound(folder$+"gruntborn.wav")			' 

	nme5_born_snd:TSound = LoadSound(folder$+"sun1.wav")			' 
	nme5_loop_snd:TSound = LoadSound(folder$+"bondloop.wav",True)			' 
	nme5_shrink_snd:TSound = LoadSound(folder$+"sunhit1.wav")			' 
	nme5_grow_snd:TSound = LoadSound(folder$+"sizzle1.wav")		' 
	nme5_explode_snd:TSound = LoadSound(folder$+"sunexp.wav")			' 
	nme5_killed_snd:TSound = LoadSound(folder$+"Explo1.wav")			' 

	nme6_born_snd:TSound = LoadSound(folder$+"wee.wav")
	nme6_tailexplode_snd:TSound = LoadSound(folder$+"snakehit.wav")
	nme6_tailhit_snd:TSound = LoadSound(folder$+"tailhit.wav")

	nme7_born_snd:TSound = LoadSound(folder$+"warn1.wav")			' 
	nme7_shield_snd:TSound = LoadSound(folder$+"shield1.wav")			' 

	nme8_born_snd:TSound = LoadSound(folder$+"butterfly.wav")			' 

	ge_born_snd:TSound = LoadSound(folder$+"cat.wav")			' 
	ge_hit_snd:TSound = LoadSound(folder$+"genhit1.wav")		
	ge_killed_snd:TSound = LoadSound(folder$+"genkilled1.wav")		'

	le_born_snd:TSound = LoadSound(folder$+"buzz1.wav")			' 
	le_hit_snd:TSound = LoadSound(folder$+"echo1.wav")			
	le_killed_snd:TSound = LoadSound(folder$+"elastic.wav")		'

	pu_collect_snd:TSound = LoadSound(folder$+"bonus1.wav")		' 

	get_ready_snd:TSound = LoadSound(folder$+"startup.wav")			' 

	player_hit_snd:TSound = LoadSound(folder$+"die1.wav")		' 

	shot_born_snd:TSound = LoadSound(folder$+"shotborn.wav")			' 
	shot_hit_wall_snd:TSound = LoadSound(folder$+"shotwall.wav")			' 

	game_over_snd:TSound = LoadSound(folder$+"gameover.wav")			' 

	super_bomb_snd:TSound = LoadSound(folder$+"explo1.wav")			' 

	extra_life_snd:TSound = LoadSound(folder$+"brainborn.wav")			' 

	extra_bomb_snd:TSound = LoadSound(folder$+"buzz2.wav")			' 

	multiplier_increase_snd:TSound = LoadSound(folder$+"bonus2.wav")		' 
	bonus_born_snd:TSound = LoadSound(folder$+"bonusborn.wav")		' 
	high_score_snd:TSound = LoadSound(folder$+"bonus1.wav")		' reused

	quarkhitsound:TSound = LoadSound(folder$+"quarkhit.wav")		' 
	quarkhit2sound:TSound = LoadSound(folder$+"quarkhit2.wav")		' 

	shieldwarningsnd:TSound = LoadSound(folder$+"shieldwarning.wav")		' 

End Function


Function PlaySound2:TChannel(snd:TSound, freq# = 1, pan#=0, vol# = 1)

	Local ch:TChannel = Null
	
	If sfxvol > 0 And snd <> Null
		ch=CueSound(snd)
		If freq <> 1
			SetChannelRate(ch,freq)
		EndIf
		SetChannelPan ch, pan		
		SetChannelVolume ch,sfxvol*vol
		ResumeChannel ch	
	EndIf
	Return ch

End Function


Function SetPanAndVolume(ch:TChannel, pan#, vol#)

	If ch <> Null
		If sfxvol > 0
			SetChannelPan ch, pan		
			SetChannelVolume ch,sfxvol*vol
		EndIf
	EndIf

End Function



Function AdjustVolume()
	Local t:Int
	
	For t = 0 To 7
		If sunloopchan[t] <> Null
			SetChannelVolume sunloopchan[t],sfxvol
		EndIf
	Next

End Function


Function StopLoopingSounds()
	Local t:Int
	
	For t = 0 To 7
		If sunloopchan[t] <> Null
			StopChannel(sunloopchan[t])
			sunloopchan[t] = Null
		EndIf
	Next

End Function


Function StartMusic(song:Int)
?MacOS
'need a way to play tunes on a mac
'ogg maybe?
Rem
	If musicchannel <> Null Then Return
	
	Local f$ = ""

	Select song
		Case 0 'intro
			f$ = "music/Theme0.ogg"
		Case 1 'in game
			f$ = "music/Theme1.ogg"	
		Case 2 'hi score
			f$ = "music/Theme2.ogg"
	End Select
		
	musicchannel = CueSound(LoadSound(f$))
	SetChannelVolume(musicchannel,musicvol)
	ResumeChannel(musicchannel)
EndRem

?Win32
	If musicchannel <> 0 Then Return
	
	Local f$ = ""

	Select song
		Case 0 'intro
			f$ = "music/Theme0.it"
		Case 1 'in game
			f$ = "music/Theme1.it"	
		Case 2 'hi score
			f$ = "music/Theme2.it"
	End Select
		
	BASS_Free()	
	Local dev:Int = BASS_Init(1,44100,0,0,0)
	If dev <> 0
		musicchannel = BASS_MusicLoad(False,f$.toCString(),0,0,BASS_SAMPLE_LOOP Or BASS_MUSIC_RAMPS Or BASS_MUSIC_CALCLEN,0)
		BASS_ChannelSetAttributes(musicchannel,-1,100*musicvol,-1)
		BASS_ChannelPlay(musicchannel,False)
	EndIf
?

?Linux

?	
	
			
End Function


Function StopMusic()
?MacOS
'need a way to play tunes on a mac
'ogg maybe?
Rem
	If musicchannel <> Null
		StopChannel(musicchannel)
		musicchannel = 0
	EndIf
End Rem
?Win32
	If musicchannel <> 0
		BASS_ChannelStop(musicchannel)
		BASS_Free()
		musicchannel = 0
	EndIf
?
?Linux

?	

End Function


Function SetMusicVolume()
?Mac
'need a way to play tunes on a mac
'ogg maybe?
Rem
	If musicchannel <> Null
		SetChannelVolume(musicchannel,musicvol)
	EndIf
End Rem
?Win32
	If musicchannel <>0
		BASS_ChannelSetAttributes(musicchannel,-1,100*musicvol,-1)
	EndIf
?
?Linux

?	

End Function

