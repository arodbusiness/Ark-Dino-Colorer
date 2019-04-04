#SingleInstance, Force
#Persistent

SetKeyDelay, -1

Colors := strsplit("FF0000,0000FF,00FF00,FFFF00,00FFFF,FF00FF,C0FFBA,C8CACA,786759,FFB46C,FFFA8A,FF756C,7B7B7B,3B3B3B,593A2A,224900,812118,FFFFFF,FFA8A8,592B2B,FFB694,88532F,CACAA0,94946C,e0FFe0,799479,224122,D9e0FF,394263,e4D9FF,403459,FFe0BA,948575,594e41,595959,FFFFFF,B79683,eADAD5,D0A794,C3B39F,887666,A0664B,CB7956,BC4F00,79846C,909C79,A5A48B,74939C,787496,B0A2C0,6281A7,485C75,5FA4eA,4568D4,eDeDeD,515151", ",")

GoSub, BuildGUI
GoSub, RandomizeFn
CurrentRegion := 0

return



BuildGUI:
	WindowX := 0
	WindowY := 0
	WindowW := 340
	WindowH := 230

	Gui, +e0x80 +LastFound
	Gui, Color, FFFFFF
	hWnd := WinExist()
	hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE) 
	nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu) 
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-6,"Uint","0x400") 
	DllCall("DrawMenuBar","Int",hWnd) 
	
	x := 5, y := 2
	x2 := x+126
	Gui, Add, Checkbox, vAll x%x% y%y%, Color All Regions
	
	
	RegionsY := 22
	w := 150
	h := 30
	
	rowSeperation := 26
	y := RegionsY
	Loop, 6
	{
		Number := A_Index-1
		Check := A_Index=1 ? "Checked1" : "Checked0"
		
		Gui, Add, Radio, gSelectRegion%Number% x%x% y%y% %Check% vRadio%Number%, Region %Number%
		Gui, Add, Checkbox, vRegionCheck%Number% x%x2% y%y% Checked1,
		
		y := y+rowSeperation
	}
	
	x2 := 70	
	y2 := RegionsY-3
	w2 := 50
	h2 := 23
	
	y3 := RegionsY-4
	
	Loop, 6
	{
		Number := A_Index-1
		Gui, Add, Edit, vInputColor%Number% x%x2% y%y2% w%w2% r1
		Gui, 2:Add, Progress, x%x2% y%y3% w%w2% h%h2%  vRegionProgress%Number%, 100
		
		y2 := y2+rowSeperation
		y3 := y3+rowSeperation
	}

	Gui, Add, Button, gRandomizeFn  x%x% y%y%, Randomize Colors

	
	Gui, 2:+e0x80 +LastFound
	TransColor = CCCCCC
	Gui, 2:Color, %transColor%
	hWnd := WinExist()
	hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE) 
	nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu) 
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-6,"Uint","0x400") 
	DllCall("DrawMenuBar","Int",hWnd) 

	w := 25
	h := w
	
	ColorChartX := 160
	
	x := ColorChartX
	y := 2
	
	rowCurrent := 1
	Loop % Colors.MaxIndex()
	{
		Color := Colors[A_Index]
		Gui, Add, Button, gPickColor%A_Index% vColorButton%A_Index% x%x% y%y% w%w% h%h%, %A_Index%
		Gui, 2:Add, Progress, x%x% y%y% w%w% h%h% c%Color%, 100
		if (rowCurrent > 6){
			rowCurrent := 1
			x := ColorChartX	
			y := y+25
		}else{
			rowCurrent := rowCurrent +1
			x := x+25
		}
	}
	
	y := 204
	x := 5
	Gui, Add, Button, gClipIt  x%x% y%y% Default, Copy to Clipboard
	
	x := 224
	Gui, Add, Button, gEnterIt  x%x% y%y%, Enter in Game
	
	Gui, Show, x%WindowX% y%WindowY% w%WindowW% h%WindowH%
	WinGet, k_ID, ID, A
	
	Gui, 2:Show, x%WindowX% y%WindowY% w%WindowW% h%WindowH%
	WinGet, j_ID, ID, A 
	
	WinSet, AlwaysOnTop, On, ahk_id %j_ID%
	
	WinSet, AlwaysOnTop, On, ahk_id %k_ID%
	WinSet, TransColor, %TransColor% 100, ahk_id %k_ID%
return


RandomizeFn:
	GuiControlGet, ApplyAll, ,All
	if (ApplyAll=1)
	{
		Random, CurrentColorID, 1, 56
		CurrentColor := Colors[CurrentColorID]
		Loop, 6
		{
			CurrentRegion := A_Index-1
			GuiControl, Text, InputColor%CurrentRegion%, %CurrentColor%  
		
			GuiControl, 2:+c%CurrentColor%,  RegionProgress%CurrentRegion%
		}
	}
	else
	{
		Gui, Submit, nohide
		Loop, 6
		{
			CurrentRegion := A_Index-1
			CurrentCheck := RegionCheck%CurrentRegion%
			if (CurrentCheck){
				Random, CurrentColorID, 1, 56
				CurrentColor := Colors[CurrentColorID]
				GuiControl, Text, InputColor%CurrentRegion%, %CurrentColor%  
			
				GuiControl, 2:+c%CurrentColor%,  RegionProgress%CurrentRegion%
			}
		}
	}
return

ApplyColor:
	GuiControlGet, ApplyAll, ,All
	if (ApplyAll=1)
	{
		Loop, 6
		{
			Number := A_Index-1
			GuiControl, Text, InputColor%Number%, %CurrentColor%  
	
			GuiControl, 2:+c%CurrentColor%,  RegionProgress%Number%
		}
	
	}
	else
	{
		GuiControl, Text, InputColor%CurrentRegion%, %CurrentColor%  
		
		GuiControl, 2:+c%CurrentColor%,  RegionProgress%CurrentRegion%
	}
return


GetIDs:
	Gui, Submit, nohide
	String := ""
	Loop, 6
	{
		Number := A_Index-1
		CurrentCheck := RegionCheck%Number%
		if (CurrentCheck){
			InputColor := InputColor%Number%
			Loop % Colors.MaxIndex()
			{
				if (Colors[A_Index]=InputColor)
				{
					String := String "cheat SetTargetDinoColor " Number " " A_Index "| "
					break
				}
			}
		}
	}
return




ClipIt:
	GoSub, GetIDs
	Clipboard := String
	SoundBeep
return

EnterIt:
	GoSub, GetIDs
	
	WinActive("ahk_class UnrealWindow")
	Sleep 500
	Send {tab}
	Sleep 100
	Send % String
	Sleep 100
	Send {Enter}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SelectRegion0:
	CurrentRegion := 0
return
SelectRegion1:
	CurrentRegion := 1
return
SelectRegion2:
	CurrentRegion := 2
return
SelectRegion3:
	CurrentRegion := 3
return
SelectRegion4:
	CurrentRegion := 4
return
SelectRegion5:
	CurrentRegion := 5
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PickColor1:
	CurrEntColor := "FF0000"
	GoSub, ApplyColor
Return	
PickColor2:
	CurrEntColor := "0000FF"
	GoSub, ApplyColor
Return	
PickColor3:
	CurrEntColor := "00FF00"
	GoSub, ApplyColor
Return	
PickColor4:
	CurrEntColor := "FFFF00"
	GoSub, ApplyColor
Return	
PickColor5:
	CurrEntColor := "00FFFF"
	GoSub, ApplyColor
Return	
PickColor6:
	CurrEntColor := "FF00FF"
	GoSub, ApplyColor
Return	
PickColor7:
	CurrEntColor := "C0FFBA"
	GoSub, ApplyColor
Return	
PickColor8:
	CurrEntColor := "C8CACA"
	GoSub, ApplyColor
Return	
PickColor9:
	CurrEntColor := "786759"
	GoSub, ApplyColor
Return	
PickColor10:
	CurrEntColor := "FFB46C"
	GoSub, ApplyColor
Return	
PickColor11:
	CurrEntColor := "FFFA8A"
	GoSub, ApplyColor
Return	
PickColor12:
	CurrEntColor := "FF756C"
	GoSub, ApplyColor
Return	
PickColor13:
	CurrEntColor := "7B7B7B"
	GoSub, ApplyColor
Return	
PickColor14:
	CurrEntColor := "3B3B3B"
	GoSub, ApplyColor
Return	
PickColor15:
	CurrEntColor := "593A2A"
	GoSub, ApplyColor
Return	
PickColor16:
	CurrEntColor := "224900"
	GoSub, ApplyColor
Return	
PickColor17:
	CurrEntColor := "812118"
	GoSub, ApplyColor
Return	
PickColor18:
	CurrEntColor := "FFFFFF"
	GoSub, ApplyColor
Return	
PickColor19:
	CurrEntColor := "FFA8A8"
	GoSub, ApplyColor
Return	
PickColor20:
	CurrEntColor := "592B2B"
	GoSub, ApplyColor
Return	
PickColor21:
	CurrEntColor := "FFB694"
	GoSub, ApplyColor
Return	
PickColor22:
	CurrEntColor := "88532F"
	GoSub, ApplyColor
Return	
PickColor23:
	CurrEntColor := "CACAA0"
	GoSub, ApplyColor
Return	
PickColor24:
	CurrEntColor := "94946C"
	GoSub, ApplyColor
Return	
PickColor25:
	CurrEntColor := "E0FFE0"
	GoSub, ApplyColor
Return	
PickColor26:
	CurrEntColor := "799479"
	GoSub, ApplyColor
Return	
PickColor27:
	CurrEntColor := "224122"
	GoSub, ApplyColor
Return	
PickColor28:
	CurrEntColor := "D9E0FF"
	GoSub, ApplyColor
Return	
PickColor29:
	CurrEntColor := "394263"
	GoSub, ApplyColor
Return	
PickColor30:
	CurrEntColor := "E4D9FF"
	GoSub, ApplyColor
Return	
PickColor31:
	CurrEntColor := "403459"
	GoSub, ApplyColor
Return	
PickColor32:
	CurrEntColor := "FFE0BA"
	GoSub, ApplyColor
Return	
PickColor33:
	CurrEntColor := "948575"
	GoSub, ApplyColor
Return	
PickColor34:
	CurrEntColor := "594E41"
	GoSub, ApplyColor
Return	
PickColor35:
	CurrEntColor := "595959"
	GoSub, ApplyColor
Return	
PickColor36:
	CurrEntColor := "FFFFFF"
	GoSub, ApplyColor
Return	
PickColor37:
	CurrEntColor := "B79683"
	GoSub, ApplyColor
Return	
PickColor38:
	CurrEntColor := "EADAD5"
	GoSub, ApplyColor
Return	
PickColor39:
	CurrEntColor := "D0A794"
	GoSub, ApplyColor
Return	
PickColor40:
	CurrEntColor := "C3B39F"
	GoSub, ApplyColor
Return	
PickColor41:
	CurrEntColor := "887666"
	GoSub, ApplyColor
Return	
PickColor42:
	CurrEntColor := "A0664B"
	GoSub, ApplyColor
Return	
PickColor43:
	CurrEntColor := "CB7956"
	GoSub, ApplyColor
Return	
PickColor44:
	CurrEntColor := "BC4F00"
	GoSub, ApplyColor
Return	
PickColor45:
	CurrEntColor := "79846C"
	GoSub, ApplyColor
Return	
PickColor46:
	CurrEntColor := "909C79"
	GoSub, ApplyColor
Return	
PickColor47:
	CurrEntColor := "A5A48B"
	GoSub, ApplyColor
Return	
PickColor48:
	CurrEntColor := "74939C"
	GoSub, ApplyColor
Return	
PickColor49:
	CurrEntColor := "787496"
	GoSub, ApplyColor
Return	
PickColor50:
	CurrEntColor := "B0A2C0"
	GoSub, ApplyColor
Return	
PickColor51:
	CurrEntColor := "6281A7"
	GoSub, ApplyColor
Return	
PickColor52:
	CurrEntColor := "485C75"
	GoSub, ApplyColor
Return	
PickColor53:
	CurrEntColor := "5FA4EA"
	GoSub, ApplyColor
Return	
PickColor54:
	CurrEntColor := "4568D4"
	GoSub, ApplyColor
Return	
PickColor55:
	CurrEntColor := "EDEDED"
	GoSub, ApplyColor
Return	
PickColor56:
	CurrEntColor := "515151"
	GoSub, ApplyColor
Return	


GuiClose:
	ExitApp
